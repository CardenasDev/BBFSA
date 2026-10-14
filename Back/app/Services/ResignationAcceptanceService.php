<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\CertificateRepository;
use App\Repositories\ContractingRepository;
use App\Repositories\EmployeeRepository;
use App\Repositories\RetirementRepository;
use Carbon\CarbonImmutable;

class ResignationAcceptanceService
{
    public const FORMAT_KEY = 'ACEPTACION_RENUNCIA';
    public const RENDERER_KEY = 'carta-aceptacion-renuncia';

    public function __construct(
        private CertificateRepository $certificates,
        private EmployeeRepository $employees,
        private ContractingRepository $contracting,
        private RetirementRepository $retirements,
        private CertificateRenderer $renderer,
    ) {}

    public function available(int $employeeId): array
    {
        $this->existingEmployee($employeeId);

        return array_values(array_map(fn (array $row): array => $this->metadata($row),
            array_filter($this->certificates->listAllFormats($this->today()), fn (array $row): bool => $this->supported($row))));
    }

    public function generateDocument(int $employeeId, int $retirementId, array $supplied = []): string
    {
        return $this->renderer->render($this->generationData($employeeId, $retirementId, $supplied));
    }

    public function generationData(int $employeeId, int $retirementId, array $supplied = []): array
    {
        $employee = $this->existingEmployee($employeeId);
        $detail = $this->retirements->detail($retirementId);
        $retirement = $this->validRetirement($employeeId, $retirementId, $detail);
        $today = $this->today();

        $format = $this->certificates->getFormat(self::FORMAT_KEY, $today);
        if (! $format || ! $this->supported($format)) {
            throw new ApiException('Formato no implementado o no disponible.', 404);
        }

        $errors = [];

        $identity = [
            'id_empleado' => $employeeId,
            'nombre_completo' => $this->text($retirement['empleado'] ?? null)
                ?? trim(($employee['nombres'] ?? '').' '.($employee['apellidos'] ?? '')),
            'tipo_documento' => $this->text($employee['tipo_documento'] ?? null),
            'numero_documento' => $this->text($retirement['numero_documento'] ?? null)
                ?? $this->text($employee['numero_documento'] ?? null),
        ];
        if (empty($identity['nombre_completo'])) {
            $errors['nombre_completo'] = ['Dato oficial obligatorio ausente o inválido.'];
        }

        $motivoRetiro = $this->text($retirement['motivo_retiro'] ?? null);
        if (! $motivoRetiro || ! $this->requiresResignation($retirement, $motivoRetiro)) {
            $errors['motivo_retiro'] = ['Este documento solo puede generarse para una renuncia voluntaria registrada.'];
        }

        $presentationDate = $this->suppliedPresentationDate($supplied, $errors);

        $retirementDate = $this->date($retirement['fecha_retiro'] ?? null);
        if (! $retirementDate) {
            $errors['fecha_retiro'] = ['La fecha efectiva de retiro debe ser una fecha válida.'];
        }

        $position = $this->text($retirement['cargo'] ?? null);
        if (! $position) {
            $contracts = $this->contracting->listContracts($employeeId);
            foreach ($contracts as $c) {
                if (($c['estado_contrato'] ?? null) === 'ACTIVO' && ! empty($c['cargo'])) {
                    $position = $this->text($c['cargo']);
                    break;
                }
            }
        }
        if (! $position) { $errors['cargo'] = ['Cargo obligatorio ausente.']; }

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

        $advertencias = [];
        if (! $this->acceptanceCompleted($detail['activities'] ?? [])) {
            $advertencias[] = 'La actividad de aceptación de renuncia no está registrada como completada en el proceso de retiro.';
        }

        return [
            'empleado' => $identity,
            'retiro' => [
                'id_retiro' => $retirementId,
                'fecha_retiro' => $retirementDate,
                'motivo_retiro' => $motivoRetiro,
                'fecha_presentacion_renuncia' => $presentationDate,
            ],
            'contrato' => ['cargo' => $position],
            'empresa' => $company,
            'fecha_expedicion' => $today,
            'formato' => $this->metadata($format),
            'firmantes' => $signers,
            'advertencias' => $advertencias,
        ];
    }

    private function existingEmployee(int $id): array
    {
        $employee = $this->employees->find($id);
        if (! $employee) { throw new ApiException('Empleado no encontrado.', 404); }
        return $employee;
    }

    private function validRetirement(int $employeeId, int $retirementId, array $detail): array
    {
        if (! ($detail['retirement'] ?? null)) {
            throw new ApiException('Proceso de retiro no encontrado.', 404);
        }

        $ret = $detail['retirement'];
        if ((int) ($ret['id_empleado'] ?? 0) !== $employeeId) {
            throw new ApiException('El retiro no corresponde al empleado.', 404);
        }

        if (($ret['estado'] ?? '') === 'CANCELADO') {
            throw new ApiException('No se puede generar documento de un retiro cancelado.', 422, ['retiro' => ['Retiro cancelado.']]);
        }

        return $ret;
    }

    private function requiresResignation(array $retirement, string $motivo): bool
    {
        if ((int) ($retirement['requiere_renuncia'] ?? 0) === 1) {
            return true;
        }
        if ($this->text($retirement['codigo_motivo'] ?? null) === 'RENUNCIA_VOLUNTARIA') {
            return true;
        }

        return mb_stripos($motivo, 'renuncia') !== false;
    }

    private function acceptanceCompleted(array $activities): bool
    {
        foreach ($activities as $activity) {
            if (($activity['codigo'] ?? null) === 'ACEPTACION_RENUNCIA') {
                return ($activity['estado'] ?? null) === 'COMPLETADA';
            }
        }

        return false;
    }

    private function suppliedPresentationDate(array $supplied, array &$errors): ?string
    {
        $value = $supplied['fecha_presentacion_renuncia'] ?? null;
        if (! is_string($value) || trim($value) === '') {
            $errors['fecha_presentacion_renuncia'] = ['Indique la fecha de presentación de la renuncia.'];
            return null;
        }
        $date = $this->date(trim($value));
        if (! $date) {
            $errors['fecha_presentacion_renuncia'] = ['La fecha de presentación debe ser una fecha válida YYYY-MM-DD.'];
            return null;
        }
        if ($date > $this->today()) {
            $errors['fecha_presentacion_renuncia'] = ['La fecha de presentación no puede ser futura.'];
            return null;
        }

        return $date;
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
