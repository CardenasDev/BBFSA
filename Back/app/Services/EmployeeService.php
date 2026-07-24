<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\EmployeeRepository;
use DateTimeImmutable;
use DateTimeInterface;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Log;
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
use UnexpectedValueException;

class EmployeeService
{
    public const ACTIVE_REPORT_SHEET = 'PERSONAL EMPRESA ACTIVOS';

    public const ACTIVE_REPORT_COLUMNS = [
        'N. CARPETA' => 'numero_carpeta',
        'GENERO' => 'genero',
        'TIPO DE DOCUMENTO' => 'tipo_documento',
        'DOCUMENTO' => 'documento',
        'FECHA DE EXPEDICION DEL DOCUMENTO' => 'fecha_expedicion_documento',
        'APELLIDO Y NOMBRE COMPLETO' => 'apellido_nombre_completo',
        'AREA' => 'area_cargo',
        'CARGO' => 'cargo_desempenar',
        'MES' => 'mes',
        'FECHA DE INGRESO' => 'fecha_ingreso',
        'COPIA DOCUMENTO - SI' => 'copia_documento_si',
        'COPIA DOCUMENTO - NO' => 'copia_documento_no',
        'FECHA DE NACIMIENTO' => 'fecha_nacimiento',
        'CELULAR' => 'celular',
        'CORREO ELECTRONICO' => 'correo_electronico',
        'CONTRATO FIRMADO - SI' => 'contrato_firmado_si',
        'CONTRATO FIRMADO - NO' => 'contrato_firmado_no',
        'TIPO ULTIMO CONTRATO' => 'tipo_contrato_ultimo',
        'FECHA FINALIZACION CONTRATO' => 'fecha_finalizacion_contrato',
        'SALARIO' => 'salario',
        'ULTIMO EXAMEN MEDICO' => 'ultimo_examen_medico',
        'CONTRATO DE ARRENDAMIENTO' => 'contrato_arrendamiento',
        'DIRECCION VIVIENDA' => 'direccion_vivienda',
        'CUANTAS PERSONAS VIVEN' => 'cuantas_personas_viven',
        'LOS MENORES DE EDAD ESTUDIAN' => 'menores_edad_estudian',
        'EPS - SI' => 'eps_si',
        'EPS - NO' => 'eps_no',
        'EPS - CUAL' => 'eps_cual',
        'PENSION - SI' => 'pension_si',
        'PENSION - NO' => 'pension_no',
        'PENSION - CUAL' => 'pension_cual',
        'ARL - SI' => 'arl_si',
        'ARL - NO' => 'arl_no',
        'ARL - CUAL' => 'arl_cual',
        'ARL - CARNET' => 'arl_carnet',
        'CAJA DE COMPENSACION - SI' => 'caja_compensacion_si',
        'CAJA DE COMPENSACION - NO' => 'caja_compensacion_no',
        'CAJA DE COMPENSACION - CUAL' => 'caja_compensacion_cual',
        'CESANTIAS - SI' => 'cesantias_si',
        'CESANTIAS - NO' => 'cesantias_no',
        'CESANTIAS - CUAL' => 'cesantias_cual',
        'BATERIA RIESGO PSICOSOCIAL' => 'bateria_riesgo_psicosocial',
        'ULTIMA ENTREGA DOTACIONES' => 'ultima_entrega_dotaciones',
        'TALLA OVEROL' => 'talla_overol',
        'TALLA PANTALON' => 'talla_pantalon',
        'TALLA CAMISA' => 'talla_camisa',
        'NUMERO CALZADO' => 'numero_calzado',
        'OBSERVACIONES' => 'observaciones',
        'FINALIZACION CONTRATO' => 'finalizacion_contrato',
        'ESTADO' => 'estado',
    ];

    private const TEXT_COLUMNS = [
        'numero_carpeta',
        'documento',
        'celular',
    ];

    private const DATE_COLUMNS = [
        'fecha_expedicion_documento',
        'fecha_ingreso',
        'fecha_nacimiento',
        'fecha_finalizacion_contrato',
        'ultimo_examen_medico',
        'contrato_arrendamiento',
        'bateria_riesgo_psicosocial',
        'ultima_entrega_dotaciones',
    ];

    public function __construct(
        private readonly EmployeeRepository $employees,
        private readonly AuditService $audit,
    ) {}

    public function list(?string $status, ?int $areaId, ?int $positionId, ?string $search): array
    {
        return $this->employees->list($status, $areaId, $positionId, $search);
    }

    /**
     * @return array{path: string, filename: string}
     */
    public function exportActiveEmployees(): array
    {
        $rows = $this->employees->getActiveEmployeesReport();
        $path = tempnam(sys_get_temp_dir(), 'bbf_empleados_activos_');
        if ($path === false) {
            throw new RuntimeException('No fue posible crear el archivo temporal del reporte.');
        }

        try {
            $this->writeActiveEmployeesWorkbook($path, $rows);
        } catch (\Throwable $exception) {
            @unlink($path);
            throw $exception;
        }

        return [
            'path' => $path,
            'filename' => 'empleados_activos_'.now()->format('Ymd_His').'.xlsx',
        ];
    }

    public function find(int $employeeId): array
    {
        return $this->employees->find($employeeId) ?? throw new ApiException('Empleado no encontrado.', 404);
    }

    public function findByDocument(string $document): array
    {
        return $this->employees->findByDocument($document) ?? throw new ApiException('Empleado no encontrado para el documento indicado.', 404);
    }

    public function create(array $data, int $actorId, array $context): array
    {
        $employeeId = $this->employees->create($data);
        if ($employeeId < 1) {
            throw new ApiException('No fue posible crear el empleado.', 500);
        }

        $employee = $this->find($employeeId);
        $this->audit->record($actorId, 'EMPLEADOS', 'CREAR', 'EMPLEADO', $employeeId, null, $employee, $context);

        return $employee;
    }

    public function update(int $employeeId, array $data, int $actorId, array $context): array
    {
        $before = $this->find($employeeId);
        $this->employees->update($employeeId, $data);
        $after = $this->find($employeeId);
        $this->audit->record($actorId, 'EMPLEADOS', 'ACTUALIZAR', 'EMPLEADO', $employeeId, $before, $after, $context);

        return $after;
    }

    public function uploadPhoto(int $employeeId, UploadedFile $photo): array
    {
        $employee = $this->employees->find($employeeId);
        if (! $employee) {
            throw new ApiException('Empleado no encontrado', 404);
        }

        $directory = public_path('uploads/employees');
        if (! File::isDirectory($directory)) {
            File::makeDirectory($directory, 0755, true);
        }

        $extension = strtolower($photo->getClientOriginalExtension() ?: $photo->extension());
        $filename = sprintf('employee_%d_%s.%s', $employeeId, now()->format('YmdHis'), $extension);
        $photo->move($directory, $filename);

        $photoUrl = '/uploads/employees/'.$filename;

        try {
            $affected = $this->employees->updatePhotoUrl($employeeId, $photoUrl, $employee);
        } catch (\Throwable $exception) {
            $this->deleteUploadedPhoto($photoUrl);
            throw $exception;
        }

        if ($affected < 1) {
            $this->deleteUploadedPhoto($photoUrl);
            throw new ApiException('No fue posible actualizar la foto del empleado.', 422);
        }

        $this->deletePreviousPhoto($employee['foto_url'] ?? null, $photoUrl);

        return [
            'id_empleado' => $employeeId,
            'foto_url' => $photoUrl,
        ];
    }

    public function changeStatus(int $employeeId, string $status, ?string $retirementDate, int $actorId, array $context): array
    {
        $before = $this->find($employeeId);
        $affected = $this->employees->changeStatus($employeeId, $status, $retirementDate);
        if ($affected < 1) {
            throw new ApiException('No fue posible cambiar el estado del empleado.', 422);
        }

        $after = $this->find($employeeId);
        $this->audit->record($actorId, 'EMPLEADOS', 'CAMBIAR_ESTADO', 'EMPLEADO', $employeeId, $before, $after, $context);

        return $after;
    }

    public function deleteLogical(int $employeeId, int $actorId, array $context): array
    {
        $before = $this->find($employeeId);
        $affected = $this->employees->deleteLogical($employeeId);
        if ($affected < 1) {
            throw new ApiException('El empleado no existe o ya fue eliminado.', 404);
        }

        $after = ['id_empleado' => $employeeId, 'eliminado' => true];
        $this->audit->record($actorId, 'EMPLEADOS', 'ELIMINAR', 'EMPLEADO', $employeeId, $before, $after, $context);

        return $after;
    }

    private function deletePreviousPhoto(?string $previousUrl, string $newUrl): void
    {
        if (! $previousUrl || $previousUrl === $newUrl || ! $this->isEmployeeUploadPath($previousUrl)) {
            return;
        }

        $this->deleteUploadedPhoto($previousUrl);
    }

    private function deleteUploadedPhoto(string $photoUrl): void
    {
        if (! $this->isEmployeeUploadPath($photoUrl)) {
            return;
        }

        $path = public_path('uploads/employees/'.basename($photoUrl));
        try {
            if (File::exists($path)) {
                File::delete($path);
            }
        } catch (\Throwable $exception) {
            Log::warning('No fue posible eliminar la foto anterior del empleado.', [
                'path' => $path,
                'error' => $exception->getMessage(),
            ]);
        }
    }

    private function isEmployeeUploadPath(string $photoUrl): bool
    {
        return str_starts_with($photoUrl, '/uploads/employees/')
            || str_starts_with($photoUrl, 'uploads/employees/');
    }

    private function writeActiveEmployeesWorkbook(string $path, array $reportRows): void
    {
        $headerStyle = (new Style())
            ->setFontBold()
            ->setShouldWrapText();
        $dateStyle = (new Style())->setFormat('dd/mm/yyyy');
        $salaryStyle = (new Style())->setFormat('#,##0.00');

        $writer = new Writer();
        $writer->openToFile($path);

        try {
            $sheet = $writer->getCurrentSheet();
            $sheet->setName(self::ACTIVE_REPORT_SHEET);
            $sheet->setSheetView((new SheetView())->setFreezeRow(2));
            $sheet->setAutoFilter(new AutoFilter(0, 1, count(self::ACTIVE_REPORT_COLUMNS) - 1, max(1, count($reportRows) + 1)));
            $sheet->setColumnWidthForRange(18, 1, count(self::ACTIVE_REPORT_COLUMNS));

            foreach ([5, 6, 7, 8, 15, 18, 23, 24, 25, 28, 31, 34, 38, 41, 42, 43, 48, 49] as $wideColumn) {
                $sheet->setColumnWidth(26, $wideColumn);
            }

            $writer->addRow(Row::fromValues(array_keys(self::ACTIVE_REPORT_COLUMNS), $headerStyle));

            foreach ($reportRows as $index => $reportRow) {
                $this->assertExpectedAliases($reportRow, $index);
                $cells = [];

                foreach (self::ACTIVE_REPORT_COLUMNS as $alias) {
                    $cells[] = $this->reportCell($alias, $reportRow[$alias], $dateStyle, $salaryStyle);
                }

                $writer->addRow(new Row($cells));
            }
        } finally {
            $writer->close();
        }
    }

    private function assertExpectedAliases(array $row, int $index): void
    {
        $missing = array_diff(array_values(self::ACTIVE_REPORT_COLUMNS), array_keys($row));
        if ($missing !== []) {
            throw new UnexpectedValueException(sprintf(
                'La fila %d del reporte no contiene los alias esperados: %s.',
                $index + 1,
                implode(', ', $missing),
            ));
        }
    }

    private function reportCell(string $alias, mixed $value, Style $dateStyle, Style $salaryStyle): Cell
    {
        if ($value === null) {
            return Cell::fromValue(null);
        }

        if (in_array($alias, self::TEXT_COLUMNS, true)) {
            return new StringCell((string) $value, null);
        }

        if (in_array($alias, self::DATE_COLUMNS, true)) {
            return new DateTimeCell($this->reportDate($alias, $value), $dateStyle);
        }

        if ($alias === 'salario') {
            if (! is_numeric($value)) {
                throw new UnexpectedValueException("El valor de SALARIO no es numerico: {$value}.");
            }

            return new NumericCell((float) $value, $salaryStyle);
        }

        return Cell::fromValue($value);
    }

    private function reportDate(string $alias, mixed $value): DateTimeInterface
    {
        if ($value instanceof DateTimeInterface) {
            return $value;
        }

        $date = DateTimeImmutable::createFromFormat('!Y-m-d', substr((string) $value, 0, 10));
        $errors = DateTimeImmutable::getLastErrors();
        if ($date === false || ($errors !== false && ($errors['warning_count'] > 0 || $errors['error_count'] > 0))) {
            throw new UnexpectedValueException("El valor de {$alias} no es una fecha valida: {$value}.");
        }

        return $date;
    }
}
