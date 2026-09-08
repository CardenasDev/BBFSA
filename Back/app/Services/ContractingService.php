<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\ContractingRepository;
use DateTimeImmutable;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;
use Throwable;

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

    public function minimumSalary(string $date): array
    {
        $parameter = $this->contracting->getCurrentParameter('SALARIO_MINIMO', $date);
        $value = $parameter['valor'] ?? null;

        if (! $parameter || ! is_numeric($value) || (float) $value <= 0) {
            throw new ApiException('No existe un salario minimo vigente parametrizado para la fecha indicada.', 422);
        }

        return [...$parameter, 'valor_numerico' => (float) $value];
    }

    public function createContract(int $employeeId, int $userId, array $data, array $context): array
    {
        $payload = $this->normalizeData($data);
        $minimumSalary = $this->minimumSalary($payload['fecha_inicio'])['valor_numerico'];
        $salary = $payload['salario_base'] ?? null;
        if (! is_numeric($salary) || (float) $salary < $minimumSalary) {
            throw new ApiException('El salario base no puede ser inferior al salario minimo vigente de $'.number_format($minimumSalary, 0, ',', '.').'.', 422);
        }
        $contractNumber = $payload['numero_contrato'] ?? null;
        if ($contractNumber && $this->contracting->contractNumberExists($employeeId, $contractNumber)) {
            throw new ApiException('El numero de contrato ya existe para este empleado.', 422);
        }
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

    public function updateContract(int $employeeId, int $employeeContractId, int $userId, array $data, array $context): array
    {
        $before = $this->contracting->findContract($employeeId, $employeeContractId)
            ?? throw new ApiException('El contrato no existe o no pertenece al empleado.', 404);
        $payload = $this->normalizeData($data);
        $minimumSalary = $this->minimumSalary($payload['fecha_inicio'])['valor_numerico'];
        $salary = $payload['salario_base'] ?? null;
        if (! is_numeric($salary) || (float) $salary < $minimumSalary) {
            throw new ApiException('El salario base no puede ser inferior al salario minimo vigente de $'.number_format($minimumSalary, 0, ',', '.').'.', 422);
        }
        $contractNumber = $payload['numero_contrato'] ?? null;
        if ($contractNumber && $this->contracting->contractNumberExists($employeeId, $contractNumber, $employeeContractId)) {
            throw new ApiException('El numero de contrato ya existe para este empleado.', 422);
        }

        $this->contracting->updateContract($employeeId, $employeeContractId, $payload);
        $updated = collect($this->contracting->listContracts($employeeId))->first(fn (array $row): bool => $this->contractId($row) === $employeeContractId);
        if (! $updated) throw new ApiException('No fue posible consultar el contrato actualizado.', 422);

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_CONTRATO_ACTUALIZAR', 'CONTRATO_EMPLEADO', $employeeContractId, $before, $payload, $context);

        return $updated;
    }

    public function deleteContract(int $employeeId, int $employeeContractId, int $userId, array $context): array
    {
        $before = $this->contracting->findContract($employeeId, $employeeContractId)
            ?? throw new ApiException('El contrato no existe o no pertenece al empleado.', 404);

        if ($this->contracting->deleteContract($employeeId, $employeeContractId) !== 1) {
            throw new ApiException('No fue posible eliminar el contrato.', 422);
        }

        $after = [...$before, 'ESTADO_CONTRATO' => 'ANULADO', 'ELIMINADO' => 1];
        $this->audit->record(
            $userId,
            'CONTRATACION',
            'CONTRATACION_CONTRATO_ELIMINAR',
            'CONTRATO_EMPLEADO',
            $employeeContractId,
            $before,
            $after,
            $context,
        );

        return ['id_empleado_contrato' => $employeeContractId, 'eliminado' => true];
    }

    public function signContract(int $employeeContractId, int $userId, array $data, array $context): array
    {
        $payload = $this->buildSignedContractPayload($employeeContractId, $this->normalizeData($data));
        $storedPath = $payload['archivo_ruta'];

        try {
            $registered = $this->contracting->signContract($employeeContractId, $userId, $payload);
        } catch (Throwable $exception) {
            $this->deleteSignedContractFile($storedPath);
            throw $exception;
        }

        if (! $registered) {
            $this->deleteSignedContractFile($storedPath);
            throw new ApiException('No fue posible registrar el contrato firmado.', 422);
        }

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_CONTRATO_FIRMADO_REGISTRAR', 'CONTRATO_EMPLEADO', $employeeContractId, null, [
            'id_empleado_contrato' => $employeeContractId,
            'fecha_firma' => $payload['fecha_firma'],
            'origen' => $data['origen'],
            'archivo_url' => $payload['archivo_url'],
            'archivo_ruta' => $payload['archivo_ruta'],
            'result' => $registered,
        ], $context);

        return $registered;
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
        $payload = $this->buildMedicalExamPayload($employeeId, $data);

        try {
            $created = $this->contracting->createMedicalExam($employeeId, $payload);
        } catch (Throwable $exception) {
            $this->deleteMedicalExamFile($payload['archivo_local'] ?? null);
            throw $exception;
        }

        if (! $created) {
            $this->deleteMedicalExamFile($payload['archivo_local'] ?? null);
            throw new ApiException('No fue posible registrar el examen medico.', 422);
        }

        unset($payload['archivo_local']);

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_EXAMEN_CREAR', 'EXAMEN_MEDICO_EMPLEADO', $this->nullableInt($created, 'id_empleado_examen_medico'), null, [
            'id_empleado' => $employeeId,
            'request' => $payload,
            'result' => $created,
        ], $context);

        return $created;
    }

    public function updateMedicalExam(int $employeeId, int $examId, int $userId, array $data, array $context): array
    {
        $before = $this->contracting->findMedicalExam($employeeId, $examId)
            ?? throw new ApiException('Examen medico no encontrado.', 404);
        $payload = $this->buildMedicalExamPayload($employeeId, $data);
        $newFile = $payload['archivo_local'] ?? null;
        unset($payload['archivo_local']);
        if (! array_key_exists('archivo_url', $payload)) $payload['archivo_url'] = $before['ARCHIVO_URL'];

        try {
            $this->contracting->updateMedicalExam($employeeId, $examId, $payload);
        } catch (Throwable $exception) {
            $this->deleteMedicalExamFile($newFile);
            throw $exception;
        }

        $updated = collect($this->contracting->listMedicalExams($employeeId))->first(
            fn (array $item): bool => (int) ($item['id_examen_medico'] ?? 0) === $examId
        ) ?? throw new ApiException('No fue posible consultar el examen actualizado.', 422);
        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_EXAMEN_ACTUALIZAR', 'EXAMEN_MEDICO_EMPLEADO', $examId, $before, $updated, $context);
        return $updated;
    }

    public function deleteMedicalExam(int $employeeId, int $examId, int $userId, array $context): array
    {
        $before = $this->contracting->findMedicalExam($employeeId, $examId)
            ?? throw new ApiException('Examen medico no encontrado.', 404);
        if ($this->contracting->deleteMedicalExam($employeeId, $examId) !== 1) {
            throw new ApiException('No fue posible eliminar el examen medico.', 422);
        }
        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_EXAMEN_ELIMINAR', 'EXAMEN_MEDICO_EMPLEADO', $examId, $before, ['eliminado' => true], $context);
        return ['id_examen_medico' => $examId, 'eliminado' => true];
    }

    public function listDocuments(int $employeeId): array
    {
        return $this->contracting->listDocuments($employeeId);
    }

    public function registerDocument(int $employeeId, int $userId, array $data, array $context): array
    {
        $payload = $this->buildEmployeeDocumentPayload($employeeId, $data);

        try {
            $registered = $this->contracting->registerDocument($employeeId, $userId, $payload);
        } catch (Throwable $exception) {
            $this->deleteEmployeeDocumentFile($payload['archivo_local'] ?? null);
            throw $exception;
        }

        if (! $registered) {
            $this->deleteEmployeeDocumentFile($payload['archivo_local'] ?? null);
            throw new ApiException('No fue posible registrar el documento laboral.', 422);
        }

        unset($payload['archivo_local']);

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_DOCUMENTO_REGISTRAR', 'DOCUMENTO_LABORAL_EMPLEADO', $this->nullableInt($registered, 'id_empleado_documento_laboral'), null, [
            'id_empleado' => $employeeId,
            'request' => $payload,
            'result' => $registered,
        ], $context);

        return $registered;
    }

    public function updateDocument(int $employeeId, int $documentId, int $userId, array $data, array $context): array
    {
        $before = $this->contracting->findDocument($employeeId, $documentId)
            ?? throw new ApiException('Documento laboral no encontrado.', 404);
        $payload = $this->buildEmployeeDocumentPayload($employeeId, $data);
        $newFile = $payload['archivo_local'] ?? null;
        unset($payload['archivo_local']);

        if (! isset($payload['archivo_url'])) {
            $payload['archivo_url'] = $before['ARCHIVO_URL'];
            $payload['mime_type'] = $before['MIME_TYPE'];
            $payload['peso_bytes'] = $before['PESO_BYTES'];
        }

        try {
            $updatedCount = $this->contracting->updateDocument($employeeId, $documentId, $payload);
        } catch (Throwable $exception) {
            $this->deleteEmployeeDocumentFile($newFile);
            throw $exception;
        }

        if ($updatedCount !== 1) {
            $this->deleteEmployeeDocumentFile($newFile);
            throw new ApiException('No fue posible actualizar el documento laboral.', 422);
        }

        $updated = collect($this->contracting->listDocuments($employeeId))->first(
            fn (array $item): bool => (int) ($item['id_empleado_documento_laboral'] ?? $item['id_empleado_documento'] ?? 0) === $documentId
        ) ?? throw new ApiException('No fue posible consultar el documento actualizado.', 422);

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_DOCUMENTO_ACTUALIZAR', 'DOCUMENTO_LABORAL_EMPLEADO', $documentId, $before, $updated, $context);
        if ($newFile && is_string($before['ARCHIVO_URL'] ?? null) && str_starts_with($before['ARCHIVO_URL'], 'private://')) {
            $this->deleteEmployeeDocumentFile(substr($before['ARCHIVO_URL'], strlen('private://')));
        }
        return $updated;
    }

    public function deleteDocument(int $employeeId, int $documentId, int $userId, array $context): array
    {
        $before = $this->contracting->findDocument($employeeId, $documentId)
            ?? throw new ApiException('Documento laboral no encontrado.', 404);

        if ($this->contracting->deleteDocument($employeeId, $documentId) !== 1) {
            throw new ApiException('No fue posible eliminar el documento laboral.', 422);
        }

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_DOCUMENTO_ELIMINAR', 'DOCUMENTO_LABORAL_EMPLEADO', $documentId, $before, ['eliminado' => true], $context);
        return ['id_empleado_documento' => $documentId, 'eliminado' => true];
    }

    public function employeeDocumentFile(int $employeeId, int $documentId): array
    {
        $document = collect($this->contracting->listDocuments($employeeId))->first(
            fn (array $item): bool => (int) ($item['id_empleado_documento_laboral'] ?? $item['id_empleado_documento'] ?? 0) === $documentId
        );

        if (! $document) {
            throw new ApiException('Documento laboral no encontrado.', 404);
        }

        $reference = (string) ($document['archivo_url'] ?? '');
        $prefix = "private://employee-documents/{$employeeId}/";
        if (! str_starts_with($reference, $prefix)) {
            throw new ApiException('El documento no corresponde a un archivo almacenado.', 422);
        }

        $storedName = substr($reference, strlen($prefix));
        if ($storedName === '' || basename($storedName) !== $storedName) {
            throw new ApiException('La referencia del documento no es valida.', 422);
        }

        $relativePath = "employee-documents/{$employeeId}/{$storedName}";
        $path = storage_path("app/private/{$relativePath}");
        if (! File::isFile($path)) {
            throw new ApiException('El archivo físico no fue encontrado.', 404);
        }

        return [
            'path' => $path,
            'name' => (string) ($document['nombre_archivo'] ?? basename($path)),
            'mime_type' => $document['mime_type'] ?? null,
        ];
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

    private function buildSignedContractPayload(int $employeeContractId, array $data): array
    {
        $base = [
            'fecha_firma' => $data['fecha_firma'],
            'observaciones' => $this->blankToNull($data['observaciones'] ?? null),
            'nombre_original' => null,
            'archivo_url' => null,
            'archivo_ruta' => null,
            'mime_type' => null,
            'peso_bytes' => null,
        ];

        if ($data['origen'] === 'ARCHIVO') {
            $file = $data['archivo'] ?? null;
            if (! $file instanceof UploadedFile) {
                throw new ApiException('Debe cargar el archivo del contrato firmado.', 422);
            }

            $metadata = $this->storeSignedContractFile($employeeContractId, $file);

            return array_merge($base, $metadata, [
                'nombre_archivo' => $this->blankToNull($data['nombre_archivo'] ?? null) ?? $metadata['nombre_original'],
            ]);
        }

        return array_merge($base, [
            'nombre_archivo' => $this->blankToNull($data['nombre_archivo'] ?? null) ?? 'Contrato firmado',
            'archivo_url' => $this->blankToNull($data['url'] ?? null),
        ]);
    }

    private function buildMedicalExamPayload(int $employeeId, array $data): array
    {
        $payload = $this->normalizeData($data);
        unset($payload['archivo']);

        $file = $data['archivo'] ?? null;
        if (! $file instanceof UploadedFile) {
            return $payload;
        }

        $relativeDirectory = "uploads/medical-exams/{$employeeId}";
        $directory = public_path($relativeDirectory);

        if (! File::isDirectory($directory)) {
            File::makeDirectory($directory, 0755, true);
        }

        $originalName = $file->getClientOriginalName();
        $baseName = pathinfo($originalName, PATHINFO_FILENAME);
        $safeName = Str::slug($baseName) ?: 'examen-medico';
        $extension = strtolower($file->getClientOriginalExtension() ?: $file->extension() ?: 'bin');
        $filename = sprintf('%s_%s_%s.%s', now()->format('Ymd_His'), Str::lower(Str::random(6)), $safeName, $extension);
        $file->move($directory, $filename);

        $relativePath = "{$relativeDirectory}/{$filename}";
        $payload['archivo_url'] = "/{$relativePath}";
        $payload['archivo_local'] = $relativePath;

        return $payload;
    }

    private function buildEmployeeDocumentPayload(int $employeeId, array $data): array
    {
        $payload = $this->normalizeData($data);
        unset($payload['archivo']);

        $file = $data['archivo'] ?? null;
        if (! $file instanceof UploadedFile) {
            return $payload;
        }

        $relativeDirectory = "employee-documents/{$employeeId}";
        $directory = storage_path("app/private/{$relativeDirectory}");
        if (! File::isDirectory($directory)) {
            File::makeDirectory($directory, 0755, true);
        }

        $originalName = $file->getClientOriginalName();
        $safeName = Str::slug(pathinfo($originalName, PATHINFO_FILENAME)) ?: 'documento-laboral';
        $extension = strtolower($file->getClientOriginalExtension() ?: $file->extension() ?: 'bin');
        $filename = sprintf('%s_%s_%s.%s', now()->format('Ymd_His'), Str::lower(Str::random(6)), $safeName, $extension);
        $mimeType = $file->getMimeType();
        $size = $file->getSize();
        $file->move($directory, $filename);

        $relativePath = "{$relativeDirectory}/{$filename}";
        $payload['nombre_archivo'] = $this->blankToNull($payload['nombre_archivo'] ?? null) ?? $originalName;
        $payload['archivo_url'] = "private://{$relativePath}";
        $payload['mime_type'] = $mimeType;
        $payload['peso_bytes'] = $size;
        $payload['archivo_local'] = $relativePath;

        return $payload;
    }

    private function deleteEmployeeDocumentFile(?string $relativePath): void
    {
        if (! $relativePath || ! str_starts_with($relativePath, 'employee-documents/')) {
            return;
        }

        $path = storage_path("app/private/{$relativePath}");
        if (File::exists($path)) {
            File::delete($path);
        }
    }

    private function deleteMedicalExamFile(?string $relativePath): void
    {
        if (! $relativePath || ! str_starts_with($relativePath, 'uploads/medical-exams/')) {
            return;
        }

        $path = public_path($relativePath);
        if (File::exists($path)) {
            File::delete($path);
        }
    }

    private function storeSignedContractFile(int $employeeContractId, UploadedFile $file): array
    {
        $relativeDirectory = "uploads/contracts/{$employeeContractId}/documents";
        $directory = public_path($relativeDirectory);

        if (! File::isDirectory($directory)) {
            File::makeDirectory($directory, 0755, true);
        }

        $originalName = $file->getClientOriginalName();
        $baseName = pathinfo($originalName, PATHINFO_FILENAME);
        $safeName = Str::slug($baseName) ?: 'documento';
        $extension = strtolower($file->getClientOriginalExtension() ?: $file->extension() ?: 'bin');
        $filename = sprintf('%s_%s.%s', now()->format('Ymd_His'), $safeName, $extension);
        $mimeType = $file->getMimeType();
        $size = $file->getSize();

        $file->move($directory, $filename);

        return [
            'nombre_original' => $originalName,
            'archivo_ruta' => "{$relativeDirectory}/{$filename}",
            'mime_type' => $mimeType,
            'peso_bytes' => $size,
        ];
    }

    private function deleteSignedContractFile(?string $relativePath): void
    {
        if (! $relativePath || ! str_starts_with($relativePath, 'uploads/contracts/')) {
            return;
        }

        $path = public_path($relativePath);
        if (File::exists($path)) {
            File::delete($path);
        }
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
