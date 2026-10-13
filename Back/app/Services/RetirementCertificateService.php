<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\CertificateRepository;
use App\Repositories\ContractingRepository;
use App\Repositories\EmployeeRepository;
use App\Repositories\RetirementRepository;
use Carbon\CarbonImmutable;

class RetirementCertificateService
{
    public const FORMAT_KEY = 'CERTIFICADO_LABORAL_RETIRO';
    public const RENDERER_KEY = 'certificado-laboral-retiro';

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
        $retirement = $this->validRetirement($employeeId, $retirementId);
        $today = $this->today();

        $format = $this->certificates->getFormat(self::FORMAT_KEY, $today);
        if (! $format || ! $this->supported($format)) {
            throw new ApiException('Formato no implementado o no disponible.', 404);
        }

        $identity = [
            'id_empleado' => $employeeId,
            'nombre_completo' => $this->text($retirement['empleado'] ?? null)
                ?? trim(($employee['nombres'] ?? '').' '.($employee['apellidos'] ?? '')),
            'tipo_documento' => $this->text($employee['tipo_documento'] ?? null),
            'numero_documento' => $this->text($retirement['numero_documento'] ?? null)
                ?? $this->text($employee['numero_documento'] ?? null),
            'fecha_ingreso' => $this->date($retirement['fecha_ingreso'] ?? null)
                ?? $this->date($employee['fecha_ingreso'] ?? null),
        ];

        $errors = [];
        foreach (['nombre_completo', 'tipo_documento', 'numero_documento', 'fecha_ingreso'] as $field) {
            if (empty($identity[$field]) || ($field === 'fecha_ingreso' && $identity[$field] > $today)) {
                $errors[$field] = ['Dato oficial obligatorio ausente o inválido.'];
            }
        }

        $retirementDate = $this->date($retirement['fecha_retiro'] ?? null);
        if (! $retirementDate || $retirementDate > $today) {
            $errors['fecha_retiro'] = ['La fecha de retiro debe ser una fecha válida y no futura.'];
        }

        $position = $this->text($retirement['cargo'] ?? null) ?? $this->text($contract['cargo'] ?? null);
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

        $motivoRetiro = $this->text($retirement['motivo_retiro'] ?? null);
        if (! $motivoRetiro) { $errors['motivo_retiro'] = ['Motivo de retiro obligatorio ausente.']; }

        $contract = $this->contracting->getContractGenerationData((int) ($retirement['id_empleado_contrato'] ?? 0));
        if (empty($contract['tipo_contrato']) || empty($contract['salario_base'])) {
            $contracts = $this->contracting->listContracts($employeeId);
            foreach ($contracts as $c) {
                if (($c['estado_contrato'] ?? null) === 'ACTIVO' && ! empty($c['tipo_contrato'])) {
                    $contract = $c;
                    break;
                }
            }
        }
        $tipoContrato = $this->text($contract['tipo_contrato'] ?? null);
        if (! $tipoContrato) { $errors['tipo_contrato'] = ['Complete el tipo del contrato.']; }

        try {
            $salary = (new SalaryTextFormatter)->format($contract['salario_base'] ?? $retirement['salario_base'] ?? null);
        } catch (\InvalidArgumentException $e) {
            $errors['salario_base'] = ['Complete el salario base decimal válido del contrato.'];
            $salary = null;
        }

        $position = $this->text($retirement['cargo'] ?? null) ?? $this->text($contract['cargo'] ?? null);
        if (! $position) { $errors['cargo'] = ['Cargo obligatorio ausente.']; }

        $security = $this->contracting->getSocialSecurity($employeeId) ?? [];
        $affiliations = [];
        foreach (['eps', 'arl', 'fondo_pension', 'caja_compensacion'] as $field) {
            $affiliations[$field] = $this->text($security[$field] ?? null);
            if (! $affiliations[$field]) { $errors[$field] = ['Complete la afiliación '.$field.' del empleado.']; }
        }

        foreach (['fondo_solidaridad', 'retencion_fuente', 'auxilio_transporte'] as $field) {
            $value = $supplied[$field] ?? null;
            if (! is_string($value) || trim($value) === '' || mb_strlen($value) > 200 || preg_match('/[<>\r\n\x00-\x1F\x7F]/u', $value)) {
                $errors[$field] = ['Indique un texto obligatorio de hasta 200 caracteres, sin HTML ni saltos de línea.'];
            } else {
                $affiliations[$field] = trim($value);
            }
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
            throw new ApiException('Faltan datos oficiales o configuración para generar el certificado.', 422, $errors);
        }

        $profile = $this->contracting->getProfile($employeeId);
        $identity['lugar_expedicion_documento'] = $this->text($profile['lugar_expedicion_documento'] ?? null);

        return [
            'empleado' => $identity,
            'retiro' => [
                'id_retiro' => $retirementId,
                'fecha_retiro' => $retirementDate,
                'motivo_retiro' => $motivoRetiro,
            ],
            'contrato' => [
                'tipo_contrato' => $tipoContrato,
                'cargo' => $position,
            ],
            'salario' => $salary,
            'afiliaciones' => $affiliations,
            'empresa' => $company,
            'fecha_expedicion' => $today,
            'formato' => $this->metadata($format),
            'firmantes' => $signers,
            'encabezado_talento_humano' => 'TALENTO HUMANO',
        ];
    }

    private function existingEmployee(int $id): array
    {
        $employee = $this->employees->find($id);
        if (! $employee) { throw new ApiException('Empleado no encontrado.', 404); }
        return $employee;
    }

    private function validRetirement(int $employeeId, int $retirementId): array
    {
        $retirement = $this->retirements->detail($retirementId);
        if (! $retirement['retirement']) {
            throw new ApiException('Proceso de retiro no encontrado.', 404);
        }

        $ret = $retirement['retirement'];
        if ((int) ($ret['id_empleado'] ?? 0) !== $employeeId) {
            throw new ApiException('El retiro no corresponde al empleado.', 404);
        }

        $estado = $ret['estado'] ?? '';
        if ($estado === 'CANCELADO') {
            throw new ApiException('No se puede generar certificado de un retiro cancelado.', 422, ['retiro' => ['Retiro cancelado.']]);
        }

        return $ret;
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
