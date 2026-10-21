<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\CertificateRepository;
use App\Repositories\ContractingRepository;
use App\Repositories\EmployeeRepository;
use Carbon\CarbonImmutable;

class ContractNonRenewalService
{
    public const FORMAT_KEY = 'NO_RENOVACION_CONTRATO';
    public const RENDERER_KEY = 'carta-no-renovacion-contrato';

    public function __construct(
        private CertificateRepository $certificates,
        private EmployeeRepository $employees,
        private ContractingRepository $contracting,
        private CertificateRenderer $renderer,
    ) {}

    public function available(int $employeeId): array
    {
        $this->existingEmployee($employeeId);

        return array_values(array_map(fn (array $row): array => $this->metadata($row),
            array_filter($this->certificates->listAllFormats($this->today()), fn (array $row): bool => $this->supported($row))));
    }

    public function generateDocument(int $employeeId, int $contractId, array $supplied = []): string
    {
        return $this->renderer->render($this->generationData($employeeId, $contractId, $supplied));
    }

    public function generationData(int $employeeId, int $contractId, array $supplied = []): array
    {
        $employee = $this->existingEmployee($employeeId);
        $today = $this->today();

        $format = $this->certificates->getFormat(self::FORMAT_KEY, $today);
        if (! $format || ! $this->supported($format)) {
            throw new ApiException('Formato no implementado o no disponible.', 404);
        }

        $errors = [];

        $identity = [
            'id_empleado' => $employeeId,
            'nombre_completo' => trim(($employee['nombres'] ?? '').' '.($employee['apellidos'] ?? '')),
        ];
        $identity['nombre_completo'] = $this->text($employee['nombre_completo'] ?? null) ?? ($identity['nombre_completo'] !== '' ? $identity['nombre_completo'] : null);
        if (empty($identity['nombre_completo'])) {
            $errors['nombre_completo'] = ['Dato oficial obligatorio ausente o inválido.'];
        }

        $contract = $this->contracting->getContractGenerationData($contractId);
        if (! $contract || (int) ($contract['id_empleado'] ?? 0) !== $employeeId) {
            throw new ApiException('Contrato no encontrado para el empleado.', 404);
        }
        // Allow any contract state for any employee state; only validate dates are coherent
        $fechaInicio = $this->date($contract['fecha_inicio'] ?? null);
        $fechaFin = $this->date($contract['fecha_fin'] ?? null);
        $today = $this->today();
        if (! $fechaInicio || $fechaInicio > $today || ($fechaFin && $fechaFin < $fechaInicio)) {
            throw new ApiException('El contrato debe tener fechas de inicio y fin coherentes.', 422, ['contrato' => ['Fechas de contrato inválidas.']]);
        }
        $tipoContrato = $this->text($contract['tipo_contrato'] ?? null);
        if (! $tipoContrato || mb_stripos($tipoContrato, 'fijo') === false) {
            $errors['tipo_contrato'] = ['Este documento solo aplica a contratos de trabajo a término fijo.'];
        }
        $fechaInicio = $this->date($contract['fecha_inicio'] ?? null);
        if (! $fechaInicio) {
            $errors['fecha_inicio'] = ['El contrato debe tener fecha de suscripción válida.'];
        }
        $fechaFin = $this->date($contract['fecha_fin'] ?? null);
        if (! $fechaFin) {
            $errors['fecha_fin'] = ['El contrato debe tener fecha de vencimiento válida.'];
        }

        $nit = $this->text($supplied['nit_empresa'] ?? null);
        if (! $nit || mb_strlen($nit) > 20 || ! preg_match('/^\d{5,12}(-\d)?$/', $nit)) {
            $errors['nit_empresa'] = ['Indique el NIT de la empresa con formato de dígitos y dígito de verificación opcional (ejemplo: 900747203).'];
        }

        $company = [
            'razon_social' => $this->parameter('DOC_EMPRESA_RAZON_SOCIAL', 'TEXTO', $today, $errors),
            'ciudad' => $this->parameter('DOC_EMPRESA_CIUDAD', 'TEXTO', $today, $errors),
        ];

        $references = $this->json($format['firmantes_json'] ?? null);
        $signers = [];
        if (! is_array($references) || ! array_is_list($references) || ! $references) {
            $errors['firmantes_json'] = ['Se requiere un arreglo no vacío de referencias a firmantes.'];
        } else {
            foreach ($references as $reference) {
                $code = is_array($reference) ? $this->text($reference['codigo_parametro'] ?? null) : null;
                if (! $code || ! preg_match('/^DOC_FIRMANTE_[A-Z0-9_]+$/', $code)) {
                    $errors['firmantes_json'] = ['El firmante debe referenciar un código DOC_FIRMANTE_ válido.'];
                    continue;
                }
                $signer = $this->parameter($code, 'JSON', $today, $errors);
                if (! is_array($signer) || array_is_list($signer)) {
                    $errors[$code] = ['El parámetro debe contener un objeto JSON de firmante.'];
                    continue;
                }
                $selected = [];
                foreach (['nombre', 'cargo', 'telefono'] as $field) {
                    $selected[$field] = $this->text($signer[$field] ?? null);
                    if (! $selected[$field]) { $errors[$code.'.'.$field] = ['Campo obligatorio del firmante ausente.']; }
                }
                $signers[] = $selected;
            }
        }

        if ($errors) {
            throw new ApiException('Faltan datos oficiales o configuración para generar el documento.', 422, $errors);
        }

        return [
            'empleado' => $identity,
            'contrato' => [
                'id_empleado_contrato' => $contractId,
                'tipo_contrato' => $tipoContrato,
                'fecha_inicio' => $fechaInicio,
                'fecha_fin' => $fechaFin,
            ],
            'empresa' => $company,
            'nit_empresa' => $nit,
            'fecha_expedicion' => $today,
            'formato' => $this->metadata($format),
            'firmantes' => $signers,
        ];
    }

    private function existingEmployee(int $id): array
    {
        $employee = $this->employees->find($id);
        if (! $employee) { throw new ApiException('Empleado no encontrado.', 404); }
        return $employee;
    }

    private function supported(array $row): bool
    {
        return ($row['clave_formato'] ?? null) === self::FORMAT_KEY
            && ($row['clave_renderizador'] ?? null) === self::RENDERER_KEY;
    }

    private function metadata(array $row): array
    {
        $data = array_intersect_key($row, array_flip(['id_documento_formato', 'clave_formato', 'codigo_formato', 'nombre',
            'variante', 'version_formato', 'titulo', 'proceso', 'vigencia_desde', 'vigencia_hasta', 'clave_renderizador']));
        $control = $this->json($row['control_documental_json'] ?? null);
        if (is_array($control)) { $data['control_documental'] = $control; }
        return $data;
    }

    private function parameter(string $code, string $type, string $date, array &$errors): mixed
    {
        $row = $this->contracting->getCurrentParameter($code, $date);
        $value = $type === 'JSON' ? $this->json($row['valor'] ?? null) : $this->text($row['valor'] ?? null);
        if (($row['tipo_dato'] ?? null) !== $type || $value === null) {
            $errors[$code] = ['Parámetro vigente obligatorio ausente o inválido ('.$type.').'];
            return null;
        }
        return $value;
    }

    private function text(mixed $value): ?string
    {
        return is_string($value) && trim($value) !== '' ? trim($value) : null;
    }

    private function json(mixed $value): mixed
    {
        return is_string($value) ? json_decode($value, true) : $value;
    }

    private function date(mixed $value): ?string
    {
        if (! is_string($value) || ! preg_match('/^\d{4}-\d{2}-\d{2}$/', $value)) { return null; }
        [$year, $month, $day] = array_map('intval', explode('-', $value));
        return checkdate($month, $day, $year) ? $value : null;
    }

    private function today(): string
    {
        return CarbonImmutable::now('America/Bogota')->toDateString();
    }
}
