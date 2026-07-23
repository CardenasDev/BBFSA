<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\ContractingRepository;
use DateTimeImmutable;

class ContractingService
{
    public function __construct(
        private readonly ContractingRepository $contracting,
        private readonly AuditService $audit,
    ) {}

    public function listEmployees(?string $search, ?int $areaId, ?int $positionId, ?string $status): array
    {
        return $this->contracting->listEmployees($this->blankToNull($search), $areaId, $positionId, $this->blankToNull($status));
    }

    public function getProfile(int $employeeId): ?array
    {
        return $this->contracting->getProfile($employeeId);
    }

    public function listContractTemplates(array $filters): array
    {
        return $this->contracting->listContractTemplates([
            'id_tipo_contrato' => $this->nullableScalarInt($filters['id_tipo_contrato'] ?? null),
            'tipo_cargo_contrato' => $this->blankToNull($filters['tipo_cargo_contrato'] ?? null),
            'solo_activas' => array_key_exists('solo_activas', $filters) ? (int) filter_var($filters['solo_activas'], FILTER_VALIDATE_BOOLEAN) : 1,
        ]);
    }

    public function getContractTemplate(int $templateId): array
    {
        return $this->contracting->getContractTemplate($templateId)
            ?? throw new ApiException('Plantilla de contrato no encontrada.', 404);
    }

    public function getContractTemplateByType(int $contractTypeId, ?string $positionType): array
    {
        return $this->contracting->getContractTemplateByType($contractTypeId, $this->blankToNull($positionType))
            ?? throw new ApiException('No se encontro una plantilla para el tipo de contrato indicado.', 404);
    }

    public function saveProfile(int $employeeId, int $userId, array $data, array $context): array
    {
        $payload = $this->normalizeData($data);
        $saved = $this->contracting->saveProfile($employeeId, $payload);

        if (! $saved) {
            throw new ApiException('No fue posible guardar la ficha de contratacion.', 422);
        }

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_FICHA_GUARDAR', 'CONTRATACION_FICHA', $employeeId, null, [
            'id_empleado' => $employeeId,
            'request' => $payload,
            'result' => $saved,
        ], $context);

        return $saved;
    }

    public function listContracts(int $employeeId): array
    {
        return $this->contracting->listContracts($employeeId);
    }

    public function createContract(int $employeeId, int $userId, array $data, array $context): array
    {
        $payload = $this->normalizeData($data);
        $created = $this->contracting->createContract($employeeId, $userId, $payload);

        if (! $created) {
            throw new ApiException('No fue posible crear el contrato del empleado.', 422);
        }

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_CONTRATO_CREAR', 'CONTRATO_EMPLEADO', $this->contractId($created), null, [
            'id_empleado' => $employeeId,
            'id_tipo_contrato' => $payload['id_tipo_contrato'] ?? null,
            'id_plantilla_contrato' => $payload['id_plantilla_contrato'] ?? null,
            'numero_contrato' => $payload['numero_contrato'] ?? null,
            'tipo_cargo_contrato' => $payload['tipo_cargo_contrato'] ?? null,
            'fecha_inicio' => $payload['fecha_inicio'] ?? null,
            'fecha_fin' => $payload['fecha_fin'] ?? null,
            'request' => $payload,
            'result' => $created,
        ], $context);

        return $created;
    }

    public function getContractGenerationData(int $employeeContractId): array
    {
        $row = $this->contracting->getContractGenerationData($employeeContractId)
            ?? throw new ApiException('Contrato no encontrado para generacion.', 404);

        $defaults = $this->arrayValue($row['valores_default'] ?? null);
        $signatureDate = $this->firstValue($row, $defaults, ['fecha_firma']) ?: now()->toDateString();
        $companyDefaults = config('company.contracting', []);

        return [
            'empresa' => [
                'razonSocial' => $this->text(
                    $this->firstNonEmpty([
                        $companyDefaults['razon_social'] ?? null,
                        $row['razon_social'] ?? null,
                        $row['nombre_empresa'] ?? null,
                    ])
                ),
                'nit' => $this->text(
                    $this->firstNonEmpty([
                        $companyDefaults['nit'] ?? null,
                        $row['nit'] ?? null,
                        $row['numero_documento_empresa'] ?? null,
                    ])
                ),
                'domicilio' => $this->text(
                    $this->firstNonEmpty([
                        $companyDefaults['domicilio'] ?? null,
                        $row['direccion_empresa'] ?? null,
                    ])
                ),
                'correo' => $this->text(
                    $this->firstNonEmpty([
                        $companyDefaults['correo'] ?? null,
                        $row['correo_empresa'] ?? null,
                    ])
                ),
            ],
            'empleado' => $this->onlyPresent($row, [
                'id_empleado',
                'id_tipo_documento',
                'tipo_documento',
                'numero_documento',
                'nombres',
                'apellidos',
                'nombre_completo',
                'correo',
                'telefono',
                'fecha_ingreso',
                'estado_empleado',
                'fecha_nacimiento',
                'lugar_nacimiento',
                'departamento_nacimiento',
                'nacionalidad',
                'ciudad_residencia',
                'departamento_residencia',
                'direccion_residencia',
                'telefono_alterno',
                'correo_personal',
                'estado_civil',
                'nivel_educativo',
                'personas_a_cargo',
                'numero_hijos',
            ]),
            'contrato' => $this->onlyPresent($row, [
                'id_empleado_contrato',
                'id_contrato_empleado',
                'id_empleado',
                'id_tipo_contrato',
                'id_plantilla_contrato',
                'id_area',
                'id_cargo',
                'fecha_inicio',
                'fecha_fin',
                'duracion_meses',
                'salario_base',
                'auxilio_transporte',
                'periodo_pago',
                'lugar_labores',
                'numero_contrato',
                'tipo_cargo_contrato',
                'objeto_obra_labor',
                'prorroga_dias',
                'clausula_funciones',
                'jornada_laboral',
                'periodo_prueba_dias',
                'estado_contrato',
                'archivo_contrato_url',
                'observaciones',
                'tipo_contrato',
                'nombre_tipo_contrato',
                'cargo',
                'nombre_cargo',
                'area',
                'nombre_area',
            ]),
            'firmas' => $this->onlyPresent([
                'ciudad_firma' => $this->firstValue($row, $defaults, ['ciudad_firma']) ?: 'Gachancipá, Cundinamarca',
                'fecha_firma' => $signatureDate,
                'fecha_firma_texto' => $this->formatDateText($signatureDate),
                'nombre_representante_legal' => $row['nombre_representante_legal'] ?? null,
                'cargo_representante_legal' => $row['cargo_representante_legal'] ?? null,
            ], [
                'ciudad_firma',
                'fecha_firma',
                'fecha_firma_texto',
                'nombre_representante_legal',
                'cargo_representante_legal',
            ]),
            'parametros' => [
                'plantilla' => $this->onlyPresent($row, [
                    'id_plantilla_contrato',
                    'id_tipo_contrato',
                    'tipo_contrato',
                    'nombre_plantilla',
                    'codigo_formato',
                    'version_formato',
                    'fecha_vigencia',
                    'tipo_cargo_contrato',
                    'descripcion',
                    'archivo_plantilla_url',
                    'formato_salida_default',
                    'config_campos',
                    'valores_default',
                    'activo',
                    'created_at',
                    'updated_at',
                ]),
                'fecha_generacion' => $row['fecha_generacion'] ?? null,
                'reemplazos' => $this->buildContractReplacements($row, $defaults),
            ],
        ];
    }

    public function getSocialSecurity(int $employeeId): ?array
    {
        return $this->contracting->getSocialSecurity($employeeId);
    }

    public function saveSocialSecurity(int $employeeId, int $userId, array $data, array $context): array
    {
        $payload = $this->normalizeData($data);
        $saved = $this->contracting->saveSocialSecurity($employeeId, $payload);

        if (! $saved) {
            throw new ApiException('No fue posible guardar la seguridad social del empleado.', 422);
        }

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_SEGURIDAD_SOCIAL_GUARDAR', 'SEGURIDAD_SOCIAL_EMPLEADO', $employeeId, null, [
            'id_empleado' => $employeeId,
            'request' => $payload,
            'result' => $saved,
        ], $context);

        return $saved;
    }

    public function listMedicalExams(int $employeeId): array
    {
        return $this->contracting->listMedicalExams($employeeId);
    }

    public function createMedicalExam(int $employeeId, int $userId, array $data, array $context): array
    {
        $payload = $this->normalizeData($data);
        $created = $this->contracting->createMedicalExam($employeeId, $payload);

        if (! $created) {
            throw new ApiException('No fue posible registrar el examen medico.', 422);
        }

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_EXAMEN_CREAR', 'EXAMEN_MEDICO_EMPLEADO', $this->nullableInt($created, 'id_empleado_examen_medico'), null, [
            'id_empleado' => $employeeId,
            'request' => $payload,
            'result' => $created,
        ], $context);

        return $created;
    }

    public function listDocuments(int $employeeId): array
    {
        return $this->contracting->listDocuments($employeeId);
    }

    public function registerDocument(int $employeeId, int $userId, array $data, array $context): array
    {
        $payload = $this->normalizeData($data);
        $registered = $this->contracting->registerDocument($employeeId, $userId, $payload);

        if (! $registered) {
            throw new ApiException('No fue posible registrar el documento laboral.', 422);
        }

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_DOCUMENTO_REGISTRAR', 'DOCUMENTO_LABORAL_EMPLEADO', $this->nullableInt($registered, 'id_empleado_documento_laboral'), null, [
            'id_empleado' => $employeeId,
            'request' => $payload,
            'result' => $registered,
        ], $context);

        return $registered;
    }

    public function listAlerts(?int $days): array
    {
        return $this->contracting->listAlerts($days ?? 30);
    }

    private function normalizeData(array $data): array
    {
        return array_map(function (mixed $value): mixed {
            if (is_array($value)) {
                return $this->normalizeData($value);
            }

            return is_string($value) ? $this->blankToNull($value) : $value;
        }, $data);
    }

    private function nullableInt(array $row, string $key): ?int
    {
        if (! array_key_exists($key, $row) || $row[$key] === null || $row[$key] === '') {
            return null;
        }

        return (int) $row[$key];
    }

    private function nullableScalarInt(mixed $value): ?int
    {
        if ($value === null || $value === '') {
            return null;
        }

        return (int) $value;
    }

    private function onlyPresent(array $row, array $keys): array
    {
        return array_filter(
            array_intersect_key($row, array_flip($keys)),
            static fn (mixed $value): bool => $value !== null,
        );
    }

    private function contractId(array $row): ?int
    {
        return $this->nullableInt($row, 'id_empleado_contrato')
            ?? $this->nullableInt($row, 'id_contrato_empleado');
    }

    private function blankToNull(?string $value): ?string
    {
        if ($value === null || trim($value) === '') {
            return null;
        }

        return $value;
    }

    private function buildContractReplacements(array $row, array $defaults): array
    {
        $salaryBase = $this->formatCurrency($row['salario_base'] ?? null);
        $salaryText = $this->firstValue($row, $defaults, ['salario_texto', 'salario_texto_default']);
        $signatureDate = $this->firstValue($row, $defaults, ['fecha_firma']) ?: now()->toDateString();
        $resolvedEndDate = $this->resolveContractEndDate($row, $defaults);

        return $this->onlyPresent([
            'NOMBRE_COMPLETO' => $this->text($row['nombre_completo'] ?? null),
            'TIPO_DOCUMENTO' => $this->text($row['tipo_documento'] ?? null),
            'NUMERO_DOCUMENTO' => $this->text($row['numero_documento'] ?? null),
            'CORREO_PERSONAL' => $this->text($row['correo_personal'] ?? $row['correo'] ?? null),
            'CORREO' => $this->text($row['correo'] ?? $row['correo_personal'] ?? null),
            'TELEFONO' => $this->text($row['telefono'] ?? null),
            'TELEFONO_ALTERNO' => $this->text($row['telefono_alterno'] ?? $row['telefono'] ?? null),
            'DIRECCION_RESIDENCIA' => $this->text($row['direccion_residencia'] ?? null),
            'LUGAR_NACIMIENTO' => $this->text($row['lugar_nacimiento'] ?? null),
            'FECHA_NACIMIENTO_TEXTO' => $this->formatDateText($row['fecha_nacimiento'] ?? null),
            'NACIONALIDAD' => $this->text($row['nacionalidad'] ?? null),
            'CARGO' => $this->text($row['cargo'] ?? $row['nombre_cargo'] ?? null),
            'SALARIO_TEXTO' => $this->text($salaryText ?: $salaryBase),
            'SALARIO_BASE' => $salaryBase,
            'AUXILIO_TRANSPORTE_TEXTO' => $this->formatBooleanText($row['auxilio_transporte'] ?? null),
            'PERIODO_PAGO' => $this->text($row['periodo_pago'] ?? null),
            'FECHA_INICIO_TEXTO' => $this->formatDateText($row['fecha_inicio'] ?? null),
            'FECHA_FIN_TEXTO' => $this->formatDateText($resolvedEndDate),
            'LUGAR_LABORES' => $this->text($row['lugar_labores'] ?? null),
            'TERMINO_INICIAL_CONTRATO' => $this->text($this->firstValue($row, $defaults, ['termino_inicial_contrato'])),
            'NUMERO_CONTRATO' => $this->text($row['numero_contrato'] ?? null),
            'CIUDAD_FIRMA' => $this->text($this->firstValue($row, $defaults, ['ciudad_firma']) ?: 'Gachancipá, Cundinamarca'),
            'FECHA_FIRMA_TEXTO' => $this->formatDateText($signatureDate),
            'JORNADA_LABORAL' => $this->text($row['jornada_laboral'] ?? null),
            'PERIODO_PRUEBA_DIAS' => $this->text($row['periodo_prueba_dias'] ?? null),
            'OBJETO_OBRA_LABOR' => $this->text($row['objeto_obra_labor'] ?? null),
            'PRORROGA_DIAS' => $this->text($row['prorroga_dias'] ?? null),
            'CLAUSULA_FUNCIONES' => $this->text($row['clausula_funciones'] ?? null),
            'NOMBRE_PLANTILLA' => $this->text($row['nombre_plantilla'] ?? null),
            'CODIGO_FORMATO' => $this->text($row['codigo_formato'] ?? null),
            'VERSION_FORMATO' => $this->text($row['version_formato'] ?? null),
            'FECHA_VIGENCIA' => $this->text($row['fecha_vigencia'] ?? null),
            'AREA' => $this->text($row['area'] ?? $row['nombre_area'] ?? null),
            'TIPO_CONTRATO' => $this->text($row['tipo_contrato'] ?? $row['nombre_tipo_contrato'] ?? null),
            'FECHA_VIGENCIA_TEXTO' => $this->formatDateText($row['fecha_vigencia'] ?? null),
        ], [
            'NOMBRE_COMPLETO',
            'TIPO_DOCUMENTO',
            'NUMERO_DOCUMENTO',
            'CORREO_PERSONAL',
            'CORREO',
            'TELEFONO',
            'TELEFONO_ALTERNO',
            'DIRECCION_RESIDENCIA',
            'LUGAR_NACIMIENTO',
            'FECHA_NACIMIENTO_TEXTO',
            'NACIONALIDAD',
            'CARGO',
            'SALARIO_TEXTO',
            'SALARIO_BASE',
            'AUXILIO_TRANSPORTE_TEXTO',
            'PERIODO_PAGO',
            'FECHA_INICIO_TEXTO',
            'FECHA_FIN_TEXTO',
            'LUGAR_LABORES',
            'TERMINO_INICIAL_CONTRATO',
            'NUMERO_CONTRATO',
            'CIUDAD_FIRMA',
            'FECHA_FIRMA_TEXTO',
            'JORNADA_LABORAL',
            'PERIODO_PRUEBA_DIAS',
            'OBJETO_OBRA_LABOR',
            'PRORROGA_DIAS',
            'CLAUSULA_FUNCIONES',
            'NOMBRE_PLANTILLA',
            'CODIGO_FORMATO',
            'VERSION_FORMATO',
            'FECHA_VIGENCIA',
            'AREA',
            'TIPO_CONTRATO',
            'FECHA_VIGENCIA_TEXTO',
        ]);
    }

    private function resolveContractEndDate(array $row, array $defaults): ?string
    {
        $explicitEndDate = $this->blankToNull(is_string($row['fecha_fin'] ?? null) ? $row['fecha_fin'] : null);
        $computedEndDate = $this->computeContractEndDate($row, $defaults);

        if ($explicitEndDate === null) {
            return $computedEndDate;
        }

        if ($computedEndDate === null || $computedEndDate === $explicitEndDate) {
            return $explicitEndDate;
        }

        return $computedEndDate;
    }

    private function computeContractEndDate(array $row, array $defaults): ?string
    {
        $startDate = $this->safeDate(is_string($row['fecha_inicio'] ?? null) ? $row['fecha_inicio'] : null);
        if ($startDate === null) {
            return null;
        }

        $term = $this->resolveContractTerm($row, $defaults);
        if ($term === null) {
            return null;
        }

        $quantity = $term['quantity'];
        if ($quantity <= 0) {
            return null;
        }

        $interval = sprintf('+%d %s', $quantity, $term['unit']);

        return $startDate->modify($interval)?->format('Y-m-d');
    }

    /**
     * @return array{quantity:int, unit:string}|null
     */
    private function resolveContractTerm(array $row, array $defaults): ?array
    {
        $durationMonths = $row['duracion_meses'] ?? $defaults['duracion_meses'] ?? null;
        if (is_numeric($durationMonths) && (int) $durationMonths > 0) {
            return ['quantity' => (int) $durationMonths, 'unit' => 'months'];
        }

        $termText = $this->firstValue($row, $defaults, ['termino_inicial_contrato']);
        if (! is_string($termText) || trim($termText) === '') {
            return null;
        }

        if (! preg_match('/(\d+)/', $termText, $matches)) {
            return null;
        }

        $quantity = (int) $matches[1];
        $normalizedTerm = mb_strtolower($termText);

        if (str_contains($normalizedTerm, 'dia')) {
            return ['quantity' => $quantity, 'unit' => 'days'];
        }

        if (str_contains($normalizedTerm, 'año') || str_contains($normalizedTerm, 'ano')) {
            return ['quantity' => $quantity, 'unit' => 'years'];
        }

        if (str_contains($normalizedTerm, 'mes')) {
            return ['quantity' => $quantity, 'unit' => 'months'];
        }

        return null;
    }

    private function arrayValue(mixed $value): array
    {
        if (is_array($value)) {
            return $value;
        }

        if (is_object($value)) {
            return (array) $value;
        }

        if (is_string($value) && trim($value) !== '') {
            $decoded = json_decode($value, true);
            if (is_array($decoded)) {
                return $decoded;
            }
        }

        return [];
    }

    private function firstValue(array $data, array $defaults, array $keys): mixed
    {
        foreach ($keys as $key) {
            if (($value = $this->blankToNull(is_string($data[$key] ?? null) ? $data[$key] : null)) !== null) {
                return $value;
            }

            if (($value = $this->blankToNull(is_string($defaults[$key] ?? null) ? $defaults[$key] : null)) !== null) {
                return $value;
            }
        }

        return null;
    }

    private function firstNonEmpty(array $values): ?string
    {
        foreach ($values as $value) {
            if (($normalized = $this->blankToNull(is_string($value) ? $value : null)) !== null) {
                return $normalized;
            }
        }

        return null;
    }

    private function text(mixed $value): string
    {
        return (string) ($value ?? '');
    }

    private function formatDateText(?string $date): string
    {
        if (! $date) {
            return '';
        }

        $timestamp = strtotime($date);
        if ($timestamp === false) {
            return $date;
        }

        $months = [
            1 => 'enero',
            2 => 'febrero',
            3 => 'marzo',
            4 => 'abril',
            5 => 'mayo',
            6 => 'junio',
            7 => 'julio',
            8 => 'agosto',
            9 => 'septiembre',
            10 => 'octubre',
            11 => 'noviembre',
            12 => 'diciembre',
        ];

        return (int) date('d', $timestamp).' de '.$months[(int) date('n', $timestamp)].' de '.date('Y', $timestamp);
    }

    private function safeDate(?string $date): ?DateTimeImmutable
    {
        if ($date === null || trim($date) === '') {
            return null;
        }

        $parsed = DateTimeImmutable::createFromFormat('!Y-m-d', $date);

        return $parsed ?: null;
    }

    private function formatBooleanText(mixed $value): string
    {
        if ($value === null || $value === '') {
            return '';
        }

        return filter_var($value, FILTER_VALIDATE_BOOLEAN) ? 'SI' : 'NO';
    }

    private function formatCurrency(mixed $value): string
    {
        if ($value === null || $value === '') {
            return '';
        }

        $normalized = $value;
        if (is_string($value)) {
            $normalized = trim(str_replace(['$', ' '], '', $value));
            if (str_contains($normalized, ',') && str_contains($normalized, '.')) {
                $normalized = str_replace(['.', ','], ['', '.'], $normalized);
            } elseif (str_contains($normalized, ',')) {
                $normalized = str_replace(',', '.', $normalized);
            }
        }

        if (! is_numeric($normalized)) {
            return (string) $value;
        }

        return '$'.number_format((float) $normalized, 0, ',', '.');
    }
}
