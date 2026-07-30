<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\DotationRepository;
use DateTimeImmutable;
use DateTimeInterface;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;
use OpenSpout\Common\Entity\Cell;
use OpenSpout\Common\Entity\Cell\DateTimeCell;
use OpenSpout\Common\Entity\Cell\NumericCell;
use OpenSpout\Common\Entity\Cell\StringCell;
use OpenSpout\Common\Entity\Row;
use OpenSpout\Common\Entity\Style\Style;
use OpenSpout\Writer\AutoFilter;
use OpenSpout\Writer\XLSX\Entity\SheetView;
use OpenSpout\Writer\XLSX\Writer;
use RuntimeException;
use Throwable;
use UnexpectedValueException;

class DotationService
{
    public const QUOTATION_REPORT_SHEET = 'Tallas dotación';

    public const QUOTATION_REPORT_COLUMNS = [
        'Documento' => 'numero_documento',
        'Empleado' => 'nombre_completo',
        'Área' => 'area',
        'Cargo' => 'cargo',
        'Prenda' => 'tipo_dotacion',
        'Talla actual' => 'talla_actual',
        'Fecha última entrega' => 'fecha_ultima_entrega',
        'Talla última entrega' => 'talla_ultima_entrega',
        'Cantidad última entrega' => 'cantidad_ultima_entrega',
        'Tipo de entrega' => 'tipo_ultima_entrega',
        'Estado de información' => 'estado_informacion',
        'Observaciones de talla' => 'observaciones_talla',
        'Observaciones de última entrega' => 'observaciones_ultima_entrega',
    ];

    public function __construct(
        private readonly DotationRepository $dotations,
        private readonly AuditService $audit,
    ) {}

    public function types(bool $onlyActive = true): array
    {
        return array_map(fn (array $row): array => $this->mapType($row), $this->dotations->types($onlyActive));
    }

    public function sizes(?int $dotationTypeId, bool $onlyActive = true): array
    {
        return array_map(fn (array $row): array => $this->mapSize($row), $this->dotations->sizes($dotationTypeId, $onlyActive));
    }

    public function combinations(): array
    {
        return array_map(fn (array $row): array => $this->mapCombination($row), $this->dotations->combinations());
    }

    public function combinationDetails(int $combinationId): array
    {
        return array_map(
            fn (array $row): array => $this->mapCombinationDetail($row),
            $this->dotations->combinationDetails($combinationId),
        );
    }

    public function mySizes(int $userId): array
    {
        return array_map(fn (array $row): array => $this->mapMySize($row), $this->dotations->mySizes($userId));
    }

    public function myDeliveries(int $userId): array
    {
        return array_map(fn (array $row): array => $this->mapDelivery($row), $this->dotations->myDeliveries($userId));
    }

    public function saveMySize(int $userId, array $data, array $context): array
    {
        $saved = $this->dotations->saveMySize(
            $userId,
            (int) $data['id_tipo_dotacion'],
            $this->nullableInt($data, 'id_talla_dotacion'),
            $data['observaciones'] ?? null,
        );

        if (! $saved) {
            throw new ApiException('No fue posible guardar la talla de dotación.', 422);
        }

        $mapped = $this->mapSavedMySize($saved);
        $this->audit->record($userId, 'DOTACIONES', 'DOTACIONES_MI_TALLA_GUARDAR', 'DOTACION_TALLA', $mapped['id_empleado_dotacion_talla'], null, $mapped, $context);

        return $mapped;
    }

    public function employees(?string $search, ?int $areaId, ?int $positionId): array
    {
        return array_map(
            fn (array $row): array => $this->mapEmployeeSummary($row),
            $this->dotations->employees($this->blankToNull($search), $areaId, $positionId),
        );
    }

    /**
     * @return array{path: string, filename: string}
     */
    public function exportQuotation(?int $areaId, ?int $positionId, ?int $employeeId): array
    {
        $rows = $this->dotations->quotationReport($areaId, $positionId, $employeeId);
        if ($rows === []) {
            throw new ApiException('No se encontró información de dotación para los filtros seleccionados.', 404);
        }

        $path = tempnam(sys_get_temp_dir(), 'bbf_tallas_dotacion_');
        if ($path === false) {
            throw new RuntimeException('No fue posible crear el archivo temporal del reporte.');
        }

        try {
            $this->writeQuotationWorkbook($path, $rows);
        } catch (Throwable $exception) {
            @unlink($path);
            throw $exception;
        }

        return [
            'path' => $path,
            'filename' => 'tallas-dotacion-'.now()->format('Ymd-His').'.xlsx',
        ];
    }

    public function exportPurchaseQuotation(?int $areaId, ?int $positionId, ?int $employeeId): array
    {
        $rows = $this->dotations->purchaseQuotationReport($areaId, $positionId, $employeeId);
        if ($rows === []) {
            throw new ApiException('No hay solicitudes por comprar para los filtros seleccionados.', 404);
        }
        $path = tempnam(sys_get_temp_dir(), 'bbf_cotizacion_compra_');
        if ($path === false) {
            throw new RuntimeException('No fue posible crear el archivo temporal de cotización.');
        }
        try {
            $this->writePurchaseQuotationWorkbook($path, $rows);
        } catch (Throwable $exception) {
            @unlink($path);
            throw $exception;
        }

        return ['path' => $path, 'filename' => 'cotizacion-dotacion-'.now()->format('Ymd-His').'.xlsx'];
    }

    public function employeeSizes(int $employeeId): array
    {
        return array_map(fn (array $row): array => $this->mapEmployeeSize($row), $this->dotations->employeeSizes($employeeId));
    }

    public function employeeHistory(int $employeeId): array
    {
        return array_map(fn (array $row): array => $this->mapEmployeeHistory($row), $this->dotations->employeeHistory($employeeId));
    }

    public function createDelivery(array $data, int $registeredBy, array $context): array
    {
        $deliveryType = strtoupper(trim((string) $data['tipo_entrega']));
        $initialStatus = strtoupper(trim((string) ($data['estado_inicial'] ?? 'REGISTRADA')));
        $combinationId = $this->nullableInt($data, 'id_dotacion_combinacion');
        $details = $this->validateDelivery(
            (int) $data['id_empleado'],
            $deliveryType,
            $combinationId,
            $data['detalles'],
        );
        $evidence = $initialStatus === 'POR_COMPRAR' ? $this->emptyEvidencePayload() : $this->buildEvidencePayload($data);

        try {
            $deliveryId = DB::transaction(function () use ($data, $registeredBy, $deliveryType, $initialStatus, $combinationId, $details, $evidence): int {
                $deliveryId = $this->dotations->createDelivery(
                    (int) $data['id_empleado'],
                    (string) $data['fecha_entrega'],
                    $deliveryType,
                    $combinationId,
                    $registeredBy,
                    $data['observaciones'] ?? null,
                    $initialStatus,
                    $evidence['evidencia_nombre_archivo'],
                    $evidence['evidencia_nombre_original'],
                    $evidence['evidencia_url'],
                    $evidence['evidencia_ruta'],
                    $evidence['evidencia_mime_type'],
                    $evidence['evidencia_peso_bytes'],
                );

                if ($deliveryId < 1) {
                    throw new ApiException('No fue posible registrar la entrega de dotación.', 500);
                }

                foreach ($details as $detail) {
                    $this->dotations->addDeliveryDetail(
                        $deliveryId,
                        (int) $detail['id_tipo_dotacion'],
                        $this->nullableInt($detail, 'id_talla_dotacion'),
                        (int) $detail['cantidad'],
                        $detail['observaciones'] ?? null,
                    );
                }

                return $deliveryId;
            });
        } catch (Throwable $exception) {
            $this->deleteEvidenceFile($evidence['evidencia_ruta']);
            throw $exception;
        }

        $result = [
            'id_dotacion_entrega' => $deliveryId,
            'id_empleado' => (int) $data['id_empleado'],
            'fecha_entrega' => (string) $data['fecha_entrega'],
            'tipo_entrega' => $deliveryType,
            'id_dotacion_combinacion' => $combinationId,
            'estado' => $initialStatus,
            ...$this->mapEvidence($evidence),
        ];
        $auditRequest = $data;
        unset($auditRequest['evidencia_archivo']);
        $auditRequest['origen_evidencia'] = $data['origen_evidencia'] ?? null;
        $this->audit->record($registeredBy, 'DOTACIONES', 'DOTACIONES_ENTREGA_CREAR', 'DOTACION_ENTREGA', $deliveryId, null, ['request' => $auditRequest, 'result' => $result], $context);

        return $result;
    }

    public function prepareDelivery(int $deliveryId, array $data, int $userId, array $context): array
    {
        $evidence = $this->buildEvidencePayload($data);
        try {
            $prepared = $this->dotations->prepareDelivery(
                $deliveryId, (string) $data['fecha_entrega'], $userId,
                $evidence['evidencia_nombre_archivo'], $evidence['evidencia_nombre_original'],
                $evidence['evidencia_url'], $evidence['evidencia_ruta'],
                $evidence['evidencia_mime_type'], $evidence['evidencia_peso_bytes'],
            );
            if (! $prepared) {
                throw new ApiException('No fue posible preparar la entrega.', 422);
            }
        } catch (Throwable $exception) {
            $this->deleteEvidenceFile($evidence['evidencia_ruta']);
            throw $exception;
        }
        $result = $this->mapDelivery($prepared);
        $this->audit->record($userId, 'DOTACIONES', 'DOTACIONES_ENTREGA_PREPARAR', 'DOTACION_ENTREGA', $deliveryId, null, [
            'fecha_entrega' => $data['fecha_entrega'], 'estado' => 'REGISTRADA',
        ], $context);

        return $result;
    }

    private function emptyEvidencePayload(): array
    {
        return [
            'evidencia_nombre_archivo' => null, 'evidencia_nombre_original' => null,
            'evidencia_url' => null, 'evidencia_ruta' => null, 'evidencia_mime_type' => null,
            'evidencia_peso_bytes' => null, 'evidencia_fecha_carga' => null,
        ];
    }

    private function buildEvidencePayload(array $data): array
    {
        $base = [
            'evidencia_nombre_original' => null,
            'evidencia_url' => null,
            'evidencia_ruta' => null,
            'evidencia_mime_type' => null,
            'evidencia_peso_bytes' => null,
            'evidencia_fecha_carga' => now()->toDateTimeString(),
        ];

        if (($data['origen_evidencia'] ?? null) === 'ARCHIVO') {
            $file = $data['evidencia_archivo'] ?? null;
            if (! $file instanceof UploadedFile) {
                throw new ApiException('Debe cargar el archivo de evidencia de la entrega.', 422);
            }
            $metadata = $this->storeEvidenceFile($file);

            return array_merge($base, $metadata, [
                'evidencia_nombre_archivo' => $this->blankToNull($data['evidencia_nombre_archivo'] ?? null)
                    ?? $metadata['evidencia_nombre_original'],
            ]);
        }

        return array_merge($base, [
            'evidencia_nombre_archivo' => $this->blankToNull($data['evidencia_nombre_archivo'] ?? null) ?? 'Evidencia entrega',
            'evidencia_url' => $this->blankToNull($data['evidencia_url'] ?? null),
        ]);
    }

    private function storeEvidenceFile(UploadedFile $file): array
    {
        $relativeDirectory = 'uploads/dotations/deliveries';
        $directory = public_path($relativeDirectory);
        if (! File::isDirectory($directory)) {
            File::makeDirectory($directory, 0755, true);
        }

        $originalName = $file->getClientOriginalName();
        $safeName = Str::slug(pathinfo($originalName, PATHINFO_FILENAME)) ?: 'evidencia';
        $extension = strtolower($file->getClientOriginalExtension() ?: $file->extension() ?: 'bin');
        $filename = sprintf('%s_%s_%s.%s', now()->format('Ymd_His'), Str::lower(Str::random(8)), $safeName, $extension);
        $mimeType = $file->getMimeType();
        $size = $file->getSize();
        $file->move($directory, $filename);

        return [
            'evidencia_nombre_original' => $originalName,
            'evidencia_ruta' => "{$relativeDirectory}/{$filename}",
            'evidencia_mime_type' => $mimeType,
            'evidencia_peso_bytes' => $size,
        ];
    }

    private function deleteEvidenceFile(?string $relativePath): void
    {
        if (! $relativePath || ! str_starts_with($relativePath, 'uploads/dotations/deliveries/')) {
            return;
        }
        $path = public_path($relativePath);
        if (File::exists($path)) {
            File::delete($path);
        }
    }

    private function validateDelivery(int $employeeId, string $deliveryType, ?int $combinationId, array $details): array
    {
        if (! in_array($deliveryType, ['ORDINARIA', 'EXTRAORDINARIA'], true)) {
            throw new ApiException('El tipo de entrega no es válido.', 422);
        }

        if ($deliveryType === 'ORDINARIA' && $combinationId === null) {
            throw new ApiException('La entrega ordinaria requiere una combinación.', 422);
        }

        if ($deliveryType === 'EXTRAORDINARIA' && $combinationId !== null) {
            throw new ApiException('La entrega extraordinaria no debe tener una combinación asociada.', 422);
        }

        $employeeSizes = $this->dotations->employeeSizes($employeeId);
        if ($employeeSizes === []) {
            throw new ApiException('El empleado no existe o no se encuentra activo.', 422);
        }

        $detailsByType = [];
        foreach ($details as $detail) {
            $dotationTypeId = (int) $detail['id_tipo_dotacion'];
            if (isset($detailsByType[$dotationTypeId])) {
                throw new ApiException('No se puede duplicar un tipo de dotación dentro de la misma entrega.', 422);
            }
            if ((int) $detail['cantidad'] < 1) {
                throw new ApiException('La cantidad de cada prenda debe ser mayor a cero.', 422);
            }
            $detailsByType[$dotationTypeId] = $detail;
        }

        $activeTypes = [];
        foreach ($this->dotations->types(true) as $type) {
            $activeTypes[(int) $type['id_tipo_dotacion']] = $type;
        }

        $activeSizes = [];
        foreach ($this->dotations->sizes(null, true) as $size) {
            $activeSizes[(int) $size['id_talla_dotacion']] = $size;
        }

        $employeeSizesByType = [];
        foreach ($employeeSizes as $employeeSize) {
            $employeeSizesByType[(int) $employeeSize['id_tipo_dotacion']] = $employeeSize;
        }

        if ($deliveryType === 'ORDINARIA') {
            $combination = $this->dotations->combinationDetails((int) $combinationId);
            if ($combination === []) {
                throw new ApiException('La combinación no existe, no está activa o no contiene prendas activas.', 422);
            }

            $combinationByType = [];
            foreach ($combination as $item) {
                $combinationByType[(int) $item['id_tipo_dotacion']] = $item;
            }

            $missing = array_diff_key($combinationByType, $detailsByType);
            $additional = array_diff_key($detailsByType, $combinationByType);
            if ($missing !== [] || $additional !== []) {
                throw new ApiException('Las prendas enviadas no corresponden a la combinación seleccionada.', 422);
            }

            foreach ($combinationByType as $dotationTypeId => $item) {
                if ((int) $detailsByType[$dotationTypeId]['cantidad'] !== (int) $item['cantidad']) {
                    throw new ApiException("La cantidad de {$item['tipo_dotacion']} no corresponde a la combinación seleccionada.", 422);
                }
            }
        }

        foreach ($detailsByType as $dotationTypeId => $detail) {
            $type = $activeTypes[$dotationTypeId] ?? null;
            if ($type === null) {
                throw new ApiException('Uno de los tipos de dotación no existe o no está activo.', 422);
            }

            $typeName = (string) ($type['nombre'] ?? 'la prenda');
            $sentSizeId = $this->nullableInt($detail, 'id_talla_dotacion');
            $requiresSize = (bool) ($type['requiere_talla'] ?? false);

            if ($requiresSize) {
                $registeredSizeId = $this->nullableInt($employeeSizesByType[$dotationTypeId] ?? [], 'id_talla_dotacion');
                if ($registeredSizeId === null) {
                    throw new ApiException("El empleado no tiene registrada talla para {$typeName}.", 422);
                }
                if ($sentSizeId === null || $sentSizeId !== $registeredSizeId) {
                    throw new ApiException("El empleado no tiene registrada la talla indicada para {$typeName}.", 422);
                }
            }

            if ($sentSizeId !== null) {
                $size = $activeSizes[$sentSizeId] ?? null;
                if ($size === null || (int) $size['id_tipo_dotacion'] !== $dotationTypeId) {
                    throw new ApiException("La talla indicada no es válida para {$typeName}.", 422);
                }
            }
        }

        return array_values($detailsByType);
    }

    public function deliveries(?int $employeeId, ?string $startDate, ?string $endDate): array
    {
        return array_map(
            fn (array $row): array => $this->mapDelivery($row),
            $this->dotations->deliveries($employeeId, $this->blankToNull($startDate), $this->blankToNull($endDate)),
        );
    }

    public function deliveryDetails(int $deliveryId): array
    {
        return array_map(fn (array $row): array => $this->mapDeliveryDetail($row), $this->dotations->deliveryDetails($deliveryId));
    }

    public function deleteDelivery(int $deliveryId, int $userId, ?string $deletionReason): array
    {
        $deleted = $this->dotations->deleteDelivery($deliveryId, $userId, $this->blankToNull($deletionReason));

        if (! $deleted) {
            throw new ApiException('No fue posible eliminar la entrega de dotacion.', 422);
        }

        $mapped = $this->mapDeletedDelivery($deleted);
        $this->audit->record($userId, 'DOTACIONES', 'DOTACIONES_ENTREGA_ELIMINAR', 'DOTACION_ENTREGA', $deliveryId, null, [
            'id_usuario' => $userId,
            'id_dotacion_entrega' => $deliveryId,
            'motivo_eliminacion' => $deletionReason,
        ]);

        return $mapped;
    }

    public function confirmDeliveryReceived(int $userId, int $deliveryId, array $data, array $context): array
    {
        $confirmed = $this->dotations->confirmDeliveryReceived(
            $userId,
            $deliveryId,
            $data['observacion_confirmacion'] ?? null,
            $data['firma_url'] ?? null,
        );

        if (! $confirmed) {
            throw new ApiException('No fue posible confirmar la entrega de dotacion.', 422);
        }

        $mapped = $this->mapConfirmedDelivery($confirmed);
        $this->audit->record($userId, 'DOTACIONES', 'DOTACIONES_ENTREGA_CONFIRMAR_RECIBIDO', 'DOTACION_ENTREGA', $deliveryId, null, [
            'id_usuario' => $userId,
            'id_dotacion_entrega' => $deliveryId,
            'observacion_confirmacion' => $data['observacion_confirmacion'] ?? null,
            'firma_url' => $data['firma_url'] ?? null,
        ], $context);

        return $mapped;
    }

    private function writeQuotationWorkbook(string $path, array $reportRows): void
    {
        $headerStyle = (new Style)->setFontBold()->setShouldWrapText();
        $dateStyle = (new Style)->setFormat('dd/mm/yyyy');
        $observationStyle = (new Style)->setShouldWrapText();
        $writer = new Writer;
        $writer->openToFile($path);

        try {
            $sheet = $writer->getCurrentSheet();
            $sheet->setName(self::QUOTATION_REPORT_SHEET);
            $sheet->setSheetView((new SheetView)->setFreezeRow(2));
            $sheet->setAutoFilter(new AutoFilter(0, 1, count(self::QUOTATION_REPORT_COLUMNS) - 1, count($reportRows) + 1));
            $sheet->setColumnWidthForRange(18, 1, count(self::QUOTATION_REPORT_COLUMNS));

            foreach ([2, 3, 4, 5, 11] as $column) {
                $sheet->setColumnWidth(24, $column);
            }
            foreach ([12, 13] as $column) {
                $sheet->setColumnWidth(38, $column);
            }

            $writer->addRow(Row::fromValues(array_keys(self::QUOTATION_REPORT_COLUMNS), $headerStyle));

            foreach ($reportRows as $index => $reportRow) {
                $this->assertQuotationAliases($reportRow, $index);
                $cells = [];

                foreach (self::QUOTATION_REPORT_COLUMNS as $alias) {
                    $cells[] = $this->quotationCell($alias, $reportRow[$alias], $dateStyle, $observationStyle);
                }

                $writer->addRow(new Row($cells));
            }
        } finally {
            $writer->close();
        }
    }

    private function writePurchaseQuotationWorkbook(string $path, array $rows): void
    {
        $header = (new Style)->setFontBold()->setShouldWrapText();
        $date = (new Style)->setFormat('dd/mm/yyyy');
        $wrappedText = (new Style)->setShouldWrapText();
        $writer = new Writer;
        $writer->openToFile($path);
        try {
            $summary = [];
            foreach ($rows as $row) {
                if (strtoupper((string) ($row['estado'] ?? '')) !== 'POR_COMPRAR') {
                    continue;
                }
                $key = (string) ($row['tipo_dotacion'] ?? '').'|'.(string) ($row['talla'] ?? '');
                $summary[$key] ??= [
                    'prenda' => (string) ($row['tipo_dotacion'] ?? ''),
                    'talla' => (string) ($row['talla'] ?? 'Sin talla'),
                    'cantidad' => 0,
                ];
                $summary[$key]['cantidad'] += (int) ($row['cantidad'] ?? 0);
            }
            if ($summary === []) {
                throw new ApiException('No hay solicitudes por comprar para exportar.', 404);
            }

            $sheet = $writer->getCurrentSheet();
            $sheet->setName('Resumen de compra');
            $sheet->setSheetView((new SheetView)->setFreezeRow(2));
            $sheet->setColumnWidth(28, 1);
            $sheet->setColumnWidth(18, 2, 3);
            $sheet->setAutoFilter(new AutoFilter(0, 1, 2, count($summary) + 1));
            $writer->addRow(Row::fromValues(['Prenda', 'Talla', 'Cantidad total'], $header));
            foreach ($summary as $item) {
                $writer->addRow(new Row([
                    new StringCell($item['prenda'], null),
                    new StringCell($item['talla'], null),
                    new NumericCell($item['cantidad'], null),
                ]));
            }

            $detail = $writer->addNewSheetAndMakeItCurrent();
            $detail->setName('Detalle por empleado');
            $detail->setSheetView((new SheetView)->setFreezeRow(2));
            $headings = ['Documento', 'Empleado', 'Prenda', 'Talla', 'Cantidad', 'ID solicitud', 'Fecha solicitud', 'Fecha requerida', 'Área', 'Cargo', 'Tipo de entrega', 'Combinación', 'Observaciones', 'Observaciones detalle', 'Estado'];
            $detail->setAutoFilter(new AutoFilter(0, 1, count($headings) - 1, count($rows) + 1));
            $detail->setColumnWidthForRange(18, 1, count($headings));
            $detail->setColumnWidth(22, 1);
            $detail->setColumnWidth(32, 2);
            $detail->setColumnWidth(24, 3, 9, 10, 12);
            $detail->setColumnWidth(38, 13, 14);
            $writer->addRow(Row::fromValues($headings, $header));
            foreach ($rows as $row) {
                if (strtoupper((string) ($row['estado'] ?? '')) !== 'POR_COMPRAR') {
                    continue;
                }
                $writer->addRow(new Row([
                    new StringCell((string) $row['numero_documento'], null),
                    new StringCell((string) $row['nombre_completo'], null),
                    new StringCell((string) $row['tipo_dotacion'], null),
                    Cell::fromValue($row['talla'] ?? 'Sin talla'),
                    new NumericCell((int) $row['cantidad'], null),
                    new NumericCell((int) $row['id_dotacion_entrega'], null),
                    new DateTimeCell($this->quotationDate($row['fecha_solicitud']), $date),
                    new DateTimeCell($this->quotationDate($row['fecha_requerida']), $date),
                    Cell::fromValue($row['area'] ?? null), Cell::fromValue($row['cargo'] ?? null),
                    new StringCell((string) $row['tipo_entrega'], null),
                    Cell::fromValue($row['nombre_combinacion'] ?? $row['codigo_combinacion'] ?? null),
                    Cell::fromValue($row['observaciones_solicitud'] ?? null, $wrappedText),
                    Cell::fromValue($row['observaciones_detalle'] ?? null, $wrappedText),
                    new StringCell('POR_COMPRAR', null),
                ]));
            }
        } finally {
            $writer->close();
        }
    }

    private function assertQuotationAliases(array $row, int $index): void
    {
        $missing = array_diff(array_values(self::QUOTATION_REPORT_COLUMNS), array_keys($row));
        if ($missing !== []) {
            throw new UnexpectedValueException(sprintf(
                'La fila %d del reporte de cotización no contiene los alias esperados: %s.',
                $index + 1,
                implode(', ', $missing),
            ));
        }
    }

    private function quotationCell(string $alias, mixed $value, Style $dateStyle, Style $observationStyle): Cell
    {
        if ($alias === 'numero_documento') {
            return new StringCell((string) ($value ?? ''), null);
        }

        if ($alias === 'talla_actual') {
            return Cell::fromValue($value === null || $value === '' ? 'Sin talla registrada' : $value);
        }

        if ($alias === 'fecha_ultima_entrega') {
            return $value === null || $value === ''
                ? Cell::fromValue('Sin entrega previa')
                : new DateTimeCell($this->quotationDate($value), $dateStyle);
        }

        if ($alias === 'cantidad_ultima_entrega') {
            if ($value === null || $value === '') {
                return Cell::fromValue(null);
            }
            if (! is_numeric($value) || (float) $value !== (float) (int) $value) {
                throw new UnexpectedValueException("La cantidad de última entrega no es un entero válido: {$value}.");
            }

            return new NumericCell((int) $value, null);
        }

        if (in_array($alias, ['observaciones_talla', 'observaciones_ultima_entrega'], true)) {
            return Cell::fromValue($value, $observationStyle);
        }

        return Cell::fromValue($value);
    }

    private function quotationDate(mixed $value): DateTimeInterface
    {
        if ($value instanceof DateTimeInterface) {
            return $value;
        }

        $date = DateTimeImmutable::createFromFormat('!Y-m-d', substr((string) $value, 0, 10));
        $errors = DateTimeImmutable::getLastErrors();
        if ($date === false || ($errors !== false && ($errors['warning_count'] > 0 || $errors['error_count'] > 0))) {
            throw new UnexpectedValueException("La fecha de última entrega no es válida: {$value}.");
        }

        return $date;
    }

    private function mapType(array $row): array
    {
        return [
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'requiere_talla' => (bool) ($row['requiere_talla'] ?? false),
            'activo' => (bool) ($row['activo'] ?? false),
        ];
    }

    private function mapSize(array $row): array
    {
        return [
            'id_talla_dotacion' => (int) ($row['id_talla_dotacion'] ?? 0),
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'talla' => (string) ($row['talla'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'orden' => $this->nullableInt($row, 'orden'),
            'activo' => (bool) ($row['activo'] ?? false),
        ];
    }

    private function mapCombination(array $row): array
    {
        return [
            'id_dotacion_combinacion' => (int) ($row['id_dotacion_combinacion'] ?? 0),
            'codigo' => (string) ($row['codigo'] ?? ''),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'activo' => (bool) ($row['activo'] ?? false),
        ];
    }

    private function mapCombinationDetail(array $row): array
    {
        return [
            'id_dotacion_combinacion_detalle' => (int) ($row['id_dotacion_combinacion_detalle'] ?? 0),
            'id_dotacion_combinacion' => (int) ($row['id_dotacion_combinacion'] ?? 0),
            'codigo_combinacion' => (string) ($row['codigo_combinacion'] ?? ''),
            'combinacion' => (string) ($row['combinacion'] ?? ''),
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'tipo_dotacion' => (string) ($row['tipo_dotacion'] ?? ''),
            'requiere_talla' => (bool) ($row['requiere_talla'] ?? false),
            'cantidad' => (int) ($row['cantidad'] ?? 0),
            'orden' => (int) ($row['orden'] ?? 0),
            'activo' => (bool) ($row['activo'] ?? false),
        ];
    }

    private function mapMySize(array $row): array
    {
        return [
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'tipo_dotacion' => (string) ($row['tipo_dotacion'] ?? ''),
            'tipo_dotacion_descripcion' => $row['tipo_dotacion_descripcion'] ?? null,
            'requiere_talla' => (bool) ($row['requiere_talla'] ?? false),
            'id_empleado_dotacion_talla' => $this->nullableInt($row, 'id_empleado_dotacion_talla'),
            'id_empleado' => $this->nullableInt($row, 'id_empleado'),
            'id_talla_dotacion' => $this->nullableInt($row, 'id_talla_dotacion'),
            'talla' => $row['talla'] ?? null,
            'talla_descripcion' => $row['talla_descripcion'] ?? null,
            'observaciones' => $row['observaciones'] ?? null,
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null,
        ];
    }

    private function mapSavedMySize(array $row): array
    {
        return [
            'id_empleado_dotacion_talla' => $this->nullableInt($row, 'id_empleado_dotacion_talla'),
            'id_empleado' => $this->nullableInt($row, 'id_empleado'),
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'tipo_dotacion' => (string) ($row['tipo_dotacion'] ?? ''),
            'id_talla_dotacion' => $this->nullableInt($row, 'id_talla_dotacion'),
            'talla' => $row['talla'] ?? null,
            'observaciones' => $row['observaciones'] ?? null,
        ];
    }

    private function mapEmployeeSummary(array $row): array
    {
        return [
            'id_empleado' => (int) ($row['id_empleado'] ?? 0),
            'numero_documento' => (string) ($row['numero_documento'] ?? ''),
            'nombre_completo' => (string) ($row['nombre_completo'] ?? ''),
            'correo' => $row['correo'] ?? null,
            'telefono' => $row['telefono'] ?? null,
            'id_area' => $this->nullableInt($row, 'id_area'),
            'area' => $row['area'] ?? null,
            'id_cargo' => $this->nullableInt($row, 'id_cargo'),
            'cargo' => $row['cargo'] ?? null,
            'estado_empleado' => (string) ($row['estado_empleado'] ?? ''),
            'resumen_tallas' => $row['resumen_tallas'] ?? null,
            'total_entregas' => $this->nullableInt($row, 'total_entregas'),
            'entregas_pendientes_confirmacion' => $this->nullableInt($row, 'entregas_pendientes_confirmacion'),
            'ultima_fecha_entrega' => $row['ultima_fecha_entrega'] ?? null,
        ];
    }

    private function mapEmployeeSize(array $row): array
    {
        return [
            'id_empleado' => (int) ($row['id_empleado'] ?? 0),
            'numero_documento' => (string) ($row['numero_documento'] ?? ''),
            'nombre_completo' => (string) ($row['nombre_completo'] ?? ''),
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'tipo_dotacion' => (string) ($row['tipo_dotacion'] ?? ''),
            'id_empleado_dotacion_talla' => $this->nullableInt($row, 'id_empleado_dotacion_talla'),
            'id_talla_dotacion' => $this->nullableInt($row, 'id_talla_dotacion'),
            'talla' => $row['talla'] ?? null,
            'observaciones' => $row['observaciones'] ?? null,
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null,
        ];
    }

    private function mapEmployeeHistory(array $row): array
    {
        return [
            'id_dotacion_entrega' => (int) ($row['id_dotacion_entrega'] ?? 0),
            'id_empleado' => (int) ($row['id_empleado'] ?? 0),
            'numero_documento' => (string) ($row['numero_documento'] ?? ''),
            'nombre_completo' => (string) ($row['nombre_completo'] ?? ''),
            'area' => $row['area'] ?? null,
            'cargo' => $row['cargo'] ?? null,
            'fecha_entrega' => (string) ($row['fecha_entrega'] ?? ''),
            'tipo_entrega' => (string) ($row['tipo_entrega'] ?? 'ORDINARIA'),
            'id_dotacion_combinacion' => $this->nullableInt($row, 'id_dotacion_combinacion'),
            'codigo_combinacion' => $row['codigo_combinacion'] ?? null,
            'nombre_combinacion' => $row['nombre_combinacion'] ?? null,
            'fecha_confirmacion' => $row['fecha_confirmacion'] ?? null,
            'estado' => (string) ($row['estado'] ?? ''),
            'observaciones_entrega' => $row['observaciones_entrega'] ?? null,
            'observacion_confirmacion' => $row['observacion_confirmacion'] ?? null,
            'firma_url' => $row['firma_url'] ?? null,
            'id_registrado_por' => $this->nullableInt($row, 'id_registrado_por'),
            'registrado_por' => $row['registrado_por'] ?? null,
            'id_confirmado_por' => $this->nullableInt($row, 'id_confirmado_por'),
            'confirmado_por' => $row['confirmado_por'] ?? null,
            'id_dotacion_entrega_detalle' => (int) ($row['id_dotacion_entrega_detalle'] ?? 0),
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'tipo_dotacion' => (string) ($row['tipo_dotacion'] ?? ''),
            'id_talla_dotacion' => $this->nullableInt($row, 'id_talla_dotacion'),
            'talla' => $row['talla'] ?? null,
            'cantidad' => (int) ($row['cantidad'] ?? 0),
            'observaciones_detalle' => $row['observaciones_detalle'] ?? null,
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null,
            ...$this->mapEvidence($row),
        ];
    }

    private function mapDelivery(array $row): array
    {
        return [
            'id_dotacion_entrega' => (int) ($row['id_dotacion_entrega'] ?? 0),
            'id_empleado' => (int) ($row['id_empleado'] ?? 0),
            'numero_documento' => (string) ($row['numero_documento'] ?? ''),
            'nombre_completo' => (string) ($row['nombre_completo'] ?? ''),
            'fecha_entrega' => (string) ($row['fecha_entrega'] ?? ''),
            'tipo_entrega' => (string) ($row['tipo_entrega'] ?? 'ORDINARIA'),
            'id_dotacion_combinacion' => $this->nullableInt($row, 'id_dotacion_combinacion'),
            'codigo_combinacion' => $row['codigo_combinacion'] ?? null,
            'nombre_combinacion' => $row['nombre_combinacion'] ?? null,
            'fecha_confirmacion' => $row['fecha_confirmacion'] ?? null,
            'estado' => (string) ($row['estado'] ?? ''),
            'observaciones' => $row['observaciones'] ?? null,
            'observacion_confirmacion' => $row['observacion_confirmacion'] ?? null,
            'firma_url' => $row['firma_url'] ?? null,
            'id_registrado_por' => $this->nullableInt($row, 'id_registrado_por'),
            'registrado_por' => $row['registrado_por'] ?? null,
            'id_confirmado_por' => $this->nullableInt($row, 'id_confirmado_por'),
            'confirmado_por' => $row['confirmado_por'] ?? null,
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null,
            ...$this->mapEvidence($row),
        ];
    }

    private function mapConfirmedDelivery(array $row): array
    {
        return [
            'id_dotacion_entrega' => (int) ($row['id_dotacion_entrega'] ?? 0),
            'id_empleado' => (int) ($row['id_empleado'] ?? 0),
            'fecha_entrega' => (string) ($row['fecha_entrega'] ?? ''),
            'fecha_confirmacion' => $row['fecha_confirmacion'] ?? null,
            'estado' => (string) ($row['estado'] ?? ''),
            'observaciones' => $row['observaciones'] ?? null,
            'observacion_confirmacion' => $row['observacion_confirmacion'] ?? null,
            'firma_url' => $row['firma_url'] ?? null,
            'id_confirmado_por' => $this->nullableInt($row, 'id_confirmado_por'),
        ];
    }

    private function mapDeletedDelivery(array $row): array
    {
        return [
            'id_dotacion_entrega' => (int) ($row['id_dotacion_entrega'] ?? 0),
            'eliminado' => (bool) ($row['eliminado'] ?? false),
            'estado' => (string) ($row['estado'] ?? ''),
            'fecha_eliminacion' => $row['fecha_eliminacion'] ?? null,
        ];
    }

    private function mapDeliveryDetail(array $row): array
    {
        return [
            'id_dotacion_entrega_detalle' => (int) ($row['id_dotacion_entrega_detalle'] ?? 0),
            'id_dotacion_entrega' => (int) ($row['id_dotacion_entrega'] ?? 0),
            'id_empleado' => $this->nullableInt($row, 'id_empleado'),
            'fecha_entrega' => $row['fecha_entrega'] ?? null,
            'tipo_entrega' => (string) ($row['tipo_entrega'] ?? 'ORDINARIA'),
            'id_dotacion_combinacion' => $this->nullableInt($row, 'id_dotacion_combinacion'),
            'codigo_combinacion' => $row['codigo_combinacion'] ?? null,
            'nombre_combinacion' => $row['nombre_combinacion'] ?? null,
            'estado' => $row['estado'] ?? null,
            'observaciones_entrega' => $row['observaciones_entrega'] ?? null,
            'fecha_confirmacion' => $row['fecha_confirmacion'] ?? null,
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'tipo_dotacion' => (string) ($row['tipo_dotacion'] ?? ''),
            'requiere_talla' => (bool) ($row['requiere_talla'] ?? false),
            'id_talla_dotacion' => $this->nullableInt($row, 'id_talla_dotacion'),
            'talla' => $row['talla'] ?? null,
            'cantidad' => (int) ($row['cantidad'] ?? 0),
            'observaciones' => $row['observaciones'] ?? null,
            'created_at' => $row['created_at'] ?? null,
            ...$this->mapEvidence($row),
        ];
    }

    private function mapEvidence(array $row): array
    {
        $externalUrl = $row['evidencia_url'] ?? null;
        $relativePath = $row['evidencia_ruta'] ?? null;

        return [
            'evidencia_nombre_archivo' => $row['evidencia_nombre_archivo'] ?? null,
            'evidencia_nombre_original' => $row['evidencia_nombre_original'] ?? null,
            'evidencia_url' => $externalUrl,
            'evidencia_ruta' => $relativePath,
            'evidencia_url_publica' => $externalUrl ?: ($relativePath ? '/'.ltrim((string) $relativePath, '/') : null),
            'evidencia_mime_type' => $row['evidencia_mime_type'] ?? null,
            'evidencia_peso_bytes' => $this->nullableInt($row, 'evidencia_peso_bytes'),
            'evidencia_fecha_carga' => $row['evidencia_fecha_carga'] ?? null,
        ];
    }

    private function nullableInt(array $row, string $key): ?int
    {
        if (! array_key_exists($key, $row) || $row[$key] === null || $row[$key] === '') {
            return null;
        }

        return (int) $row[$key];
    }

    private function blankToNull(?string $value): ?string
    {
        if ($value === null || trim($value) === '') {
            return null;
        }

        return $value;
    }
}
