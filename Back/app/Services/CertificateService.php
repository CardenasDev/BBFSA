<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\CertificateRepository;
use App\Repositories\ContractingRepository;
use App\Repositories\EmployeeRepository;
use Carbon\CarbonImmutable;

class CertificateService
{
    public const FORMAT_KEY = 'CERTIFICADO_LABORAL_ACTIVO';
    public const RENDERER_KEY = 'certificado-laboral-activo-funciones';

    public function __construct(
        private CertificateRepository $certificates,
        private EmployeeRepository $employees,
        private ContractingRepository $contracting,
        private CertificateRenderer $renderer,
    ) {}

    public function available(int $employeeId): array
    {
        $this->activeEmployee($employeeId);

        return array_values(array_map(fn (array $row): array => $this->metadata($row),
            array_filter($this->certificates->listFormats($this->today()), fn (array $row): bool => $this->supported($row))));
    }

    public function generateDocument(int $employeeId, string $key, int $contractId): string
    {
        return $this->renderer->render($this->generationData($employeeId, $key, $contractId));
    }

    public function generationData(int $employeeId, string $key, int $contractId): array
    {
        if ($key !== self::FORMAT_KEY) {
            throw new ApiException('Formato no implementado.', 404);
        }
        $employee = $this->activeEmployee($employeeId);
        $contract = $this->contracting->getContractGenerationData($contractId);
        if (! $contract || (int) ($contract['id_empleado'] ?? 0) !== $employeeId) {
            throw new ApiException('Contrato no encontrado para el empleado.', 404);
        }
        $today = $this->today();
        $start = $this->date($contract['fecha_inicio'] ?? null);
        $end = $this->date($contract['fecha_fin'] ?? null);
        if (($contract['estado_contrato'] ?? null) !== 'ACTIVO' || ! $start || $start > $today
            || (! empty($contract['fecha_fin']) && (! $end || $end < $today))) {
            throw new ApiException('El contrato debe estar activo y vigente.', 422, ['contrato' => ['Contrato inactivo o fuera de vigencia.']]);
        }
        $format = $this->certificates->getFormat($key, $today);
        if (! $format || ! $this->supported($format)) {
            throw new ApiException('Formato no implementado o no disponible.', 404);
        }
        $identity = [
            'id_empleado' => $employeeId,
            'nombre_completo' => trim(($employee['nombres'] ?? '').' '.($employee['apellidos'] ?? '')),
            'tipo_documento' => $this->text($employee['tipo_documento'] ?? null),
            'numero_documento' => $this->text($employee['numero_documento'] ?? null),
            'fecha_ingreso' => $this->date($employee['fecha_ingreso'] ?? null),
        ];
        $identity['nombre_completo'] = $this->text($employee['nombre_completo'] ?? null) ?? $identity['nombre_completo'];
        $functions = $this->functions($contract['clausula_funciones'] ?? null);
        $position = $this->text($contract['cargo'] ?? null);
        $errors = [];
        foreach (['nombre_completo', 'tipo_documento', 'numero_documento', 'fecha_ingreso'] as $field) {
            if (empty($identity[$field]) || ($field === 'fecha_ingreso' && $identity[$field] > $today)) {
                $errors[$field] = ['Dato oficial obligatorio ausente o inválido.'];
            }
        }
        if (! $position) { $errors['cargo'] = ['Cargo obligatorio ausente.']; }
        if (! $functions) { $errors['funciones'] = ['Funciones obligatorias ausentes.']; }
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
        if ($errors) { throw new ApiException('Faltan datos oficiales o configuración para generar el certificado.', 422, $errors); }
        $profile = $this->contracting->getProfile($employeeId);
        $identity['lugar_expedicion_documento'] = $this->text($profile['lugar_expedicion_documento'] ?? null);

        return [
            'empleado' => $identity,
            'contrato' => ['id_empleado_contrato' => $contractId, 'cargo' => $position],
            'funciones' => $functions,
            'empresa' => $company,
            'fecha_expedicion' => $today,
            'solicitud' => 'Se expide a solicitud del colaborador.',
            'formato' => $this->metadata($format),
            'firmantes' => $signers,
        ];
    }

    private function activeEmployee(int $id): array
    {
        $employee = $this->employees->find($id);
        if (! $employee) { throw new ApiException('Empleado no encontrado.', 404); }
        if (($employee['estado_empleado'] ?? null) !== 'ACTIVO') {
            throw new ApiException('El empleado debe estar ACTIVO para este certificado.', 422, ['estado_empleado' => ['El empleado no está activo.']]);
        }
        return $employee;
    }

    private function supported(array $row): bool
    {
        return ($row['clave_formato'] ?? null) === self::FORMAT_KEY
            && ($row['variante'] ?? null) === 'GENERAL'
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

    private function functions(mixed $value): array
    {
        if (! is_string($value)) { return []; }
        return array_values(array_filter(array_map(static function (string $line): string {
            return trim(preg_replace('/^\s*(?:[-*•]\s*|\d+[.)]\s+|[a-zA-Z][.)]\s+)/u', '', $line));
        }, preg_split('/\R/u', $value) ?: []), static fn (string $line): bool => $line !== '' && ! preg_match('/^(?:sin dato|funciones\.?)$/iu', $line)));
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
