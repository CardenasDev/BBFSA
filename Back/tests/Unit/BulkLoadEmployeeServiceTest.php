<?php

namespace Tests\Unit;

use App\Exceptions\ApiException;
use App\Repositories\BulkLoadEmployeeRepository;
use App\Services\AuditService;
use App\Services\BulkLoadEmployeeService;
use DateTimeImmutable;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Mockery;
use OpenSpout\Common\Entity\Row;
use OpenSpout\Reader\XLSX\Reader;
use OpenSpout\Writer\XLSX\Writer;
use Tests\TestCase;

class BulkLoadEmployeeServiceTest extends TestCase
{
    public function test_template_uses_the_exact_51_column_compatible_contract(): void
    {
        [$service, $repository] = $this->service();
        $repository->shouldReceive('catalogs')->twice()->andReturn($this->catalogs());
        $repository->shouldReceive('existingDocuments')->once()->andReturn([]);

        $template = $service->template();
        try {
            $this->assertSame(array_keys(BulkLoadEmployeeService::COLUMNS), $this->headers($template['path']));
            $this->assertCount(51, $this->headers($template['path']));
            $this->assertSame('N. CARPETA', $this->headers($template['path'])[0]);
            $this->assertSame(['NOMBRES', 'APELLIDOS'], array_slice($this->headers($template['path']), 5, 2));

            $result = $service->validate($this->uploaded($template['path']));
            $this->assertSame(1, $result['total']);
            $this->assertSame(1, $result['valid'], json_encode($result['errors'], JSON_UNESCAPED_UNICODE));
            $this->assertSame(0, $result['invalid']);
        } finally {
            @unlink($template['path']);
        }
    }

    public function test_validation_maps_folder_gender_excel_dates_month_and_four_sizes(): void
    {
        [$service, $repository] = $this->service();
        $repository->shouldReceive('catalogs')->once()->andReturn($this->catalogs());
        $repository->shouldReceive('existingDocuments')->once()->andReturn([]);
        $file = $this->workbook([$this->row([
            'numero_carpeta' => '0007',
            'genero' => 'f',
            'fecha_expedicion_documento' => new DateTimeImmutable('2020-02-03'),
            'fecha_ingreso' => '01/08/2026',
            'mes' => 'AGOSTO',
            'fecha_nacimiento' => new DateTimeImmutable('1995-05-20'),
            'talla_overol' => 'M',
            'talla_pantalon' => '30',
            'talla_camisa' => 'S',
            'talla_calzado' => '37',
        ])]);

        try {
            $result = $service->validate($file);
            $this->assertSame(0, $result['invalid'], json_encode($result['errors'], JSON_UNESCAPED_UNICODE));
            $mapped = $result['_rows'][0];
            $this->assertSame('0007', $mapped['numero_carpeta']);
            $this->assertSame('F', $mapped['genero']);
            $this->assertSame('2026-08-01', $mapped['fecha_ingreso']);
            $this->assertCount(4, $mapped['_sizes']);
            $this->assertEqualsCanonicalizing([5, 6, 7, 8], array_column($mapped['_sizes'], 'id'));
        } finally {
            @unlink($file->getRealPath());
        }
    }

    public function test_month_must_match_entry_date_when_supplied(): void
    {
        [$service, $repository] = $this->service();
        $repository->shouldReceive('catalogs')->once()->andReturn($this->catalogs());
        $repository->shouldReceive('existingDocuments')->once()->andReturn([]);
        $file = $this->workbook([$this->row(['fecha_ingreso' => '01/08/2026', 'mes' => 'JULIO'])]);

        try {
            $result = $service->validate($file);
            $this->assertSame(1, $result['invalid']);
            $this->assertTrue(collect($result['errors'])->contains(
                fn ($error) => $error['field'] === 'mes' && str_contains($error['message'], 'AGOSTO')
            ));
        } finally {
            @unlink($file->getRealPath());
        }
    }

    public function test_old_50_column_export_has_a_specific_names_split_error(): void
    {
        [$service] = $this->service();
        $file = $this->workbook([], BulkLoadEmployeeService::LEGACY_COLUMNS);

        try {
            $service->validate($file);
            $this->fail('The old contract should be rejected.');
        } catch (ApiException $exception) {
            $this->assertStringContainsString('50 columnas', $exception->getMessage());
            $this->assertStringContainsString('NOMBRES y APELLIDOS', $exception->getMessage());
            $this->assertStringContainsString('no reordenes', mb_strtolower($exception->getMessage()));
        } finally {
            @unlink($file->getRealPath());
        }
    }

    public function test_informational_columns_are_accepted_with_warnings(): void
    {
        [$service, $repository] = $this->service();
        $repository->shouldReceive('catalogs')->once()->andReturn($this->catalogs());
        $repository->shouldReceive('existingDocuments')->once()->andReturn([]);
        $file = $this->workbook([$this->row([
            'copia_documento_si' => 'OK',
            'salario' => 2500000,
            'ultimo_examen_medico' => '24/07/2026',
            'finalizacion_contrato' => 'NO',
        ])]);

        try {
            $result = $service->validate($file);
            $this->assertSame(0, $result['invalid']);
            $this->assertCount(4, $result['warnings']);
            $this->assertTrue(collect($result['warnings'])->every(
                fn ($warning) => str_contains($warning['message'], 'no se persiste')
            ));
        } finally {
            @unlink($file->getRealPath());
        }
    }

    public function test_social_ok_x_pattern_uses_cual_and_rejects_an_obvious_contradiction(): void
    {
        [$service, $repository] = $this->service();
        $repository->shouldReceive('catalogs')->once()->andReturn($this->catalogs());
        $repository->shouldReceive('existingDocuments')->once()->andReturn([]);
        $file = $this->workbook([
            $this->row(['numero_documento' => '001', 'eps_si' => 'OK', 'eps' => 'Nueva EPS']),
            $this->row(['numero_documento' => '002', 'eps_si' => 'X', 'eps_no' => 'X']),
        ]);

        try {
            $result = $service->validate($file);
            $this->assertSame(1, $result['invalid']);
            $this->assertSame(1, $result['_rows'][0]['id_eps']);
            $this->assertTrue(collect($result['errors'])->contains(
                fn ($error) => str_contains($error['message'], 'mismo tiempo')
            ));
        } finally {
            @unlink($file->getRealPath());
        }
    }

    public function test_safe_numeric_document_is_converted_to_text_with_a_warning(): void
    {
        [$service, $repository] = $this->service();
        $repository->shouldReceive('catalogs')->once()->andReturn($this->catalogs());
        $repository->shouldReceive('existingDocuments')->once()->with(['1075676060'])->andReturn([]);
        $file = $this->workbook([$this->row(['numero_documento' => 1075676060])]);

        try {
            $result = $service->validate($file);
            $this->assertSame(0, $result['invalid']);
            $this->assertSame(1, $result['valid']);
            $this->assertSame('1075676060', $result['_rows'][0]['numero_documento']);
            $this->assertCount(1, $result['warnings']);
            $this->assertSame('numero_documento', $result['warnings'][0]['field']);
            $this->assertStringContainsString('llegó como número', $result['warnings'][0]['message']);
            $this->assertStringContainsString('ceros iniciales', $result['warnings'][0]['message']);
        } finally {
            @unlink($file->getRealPath());
        }
    }

    public function test_numeric_document_warning_is_added_to_the_seven_historical_warnings(): void
    {
        [$service, $repository] = $this->service();
        $repository->shouldReceive('catalogs')->once()->andReturn($this->catalogs());
        $repository->shouldReceive('existingDocuments')->once()->andReturn([]);
        $file = $this->workbook([$this->row([
            'numero_documento' => 1075676060,
            'copia_documento_si' => 'OK',
            'contrato_firmado_si' => 'OK',
            'fecha_finalizacion_contrato' => '15/08/2026',
            'salario' => 2500000,
            'ultimo_examen_medico' => '01/07/2026',
            'ultima_entrega_dotaciones' => 'UNICA',
            'finalizacion_contrato' => 'NO',
        ])]);

        try {
            $result = $service->validate($file);
            $this->assertSame(1, $result['valid']);
            $this->assertSame(0, $result['invalid']);
            $this->assertCount(8, $result['warnings']);
            $this->assertCount(1, collect($result['warnings'])->filter(
                fn ($warning) => $warning['field'] === 'numero_documento'
            ));
        } finally {
            @unlink($file->getRealPath());
        }
    }

    public function test_text_document_preserves_leading_zeroes_without_conversion_warning(): void
    {
        [$service, $repository] = $this->service();
        $repository->shouldReceive('catalogs')->once()->andReturn($this->catalogs());
        $repository->shouldReceive('existingDocuments')->once()->with(['0012345678'])->andReturn([]);
        $file = $this->workbook([$this->row(['numero_documento' => '0012345678'])]);

        try {
            $result = $service->validate($file);
            $this->assertSame(0, $result['invalid']);
            $this->assertSame('0012345678', $result['_rows'][0]['numero_documento']);
            $this->assertFalse(collect($result['warnings'])->contains(
                fn ($warning) => $warning['field'] === 'numero_documento'
            ));
        } finally {
            @unlink($file->getRealPath());
        }
    }

    public function test_alphanumeric_document_remains_valid(): void
    {
        [$service, $repository] = $this->service();
        $repository->shouldReceive('catalogs')->once()->andReturn($this->catalogs());
        $repository->shouldReceive('existingDocuments')->once()->with(['AB-123X'])->andReturn([]);
        $file = $this->workbook([$this->row(['numero_documento' => 'AB-123X'])]);

        try {
            $result = $service->validate($file);
            $this->assertSame(0, $result['invalid']);
            $this->assertSame('AB-123X', $result['_rows'][0]['numero_documento']);
        } finally {
            @unlink($file->getRealPath());
        }
    }

    public function test_decimal_numeric_document_is_rejected_as_potentially_altered(): void
    {
        $this->assertUnsafeNumericDocument(1075676060.5);
    }

    public function test_negative_numeric_document_is_rejected_as_potentially_altered(): void
    {
        $this->assertUnsafeNumericDocument(-1075676060);
    }

    public function test_numeric_document_over_15_digits_is_rejected_as_potentially_imprecise(): void
    {
        $this->assertUnsafeNumericDocument(1234567890123456);
    }

    public function test_duplicates_are_detected_after_numeric_document_normalization(): void
    {
        [$service, $repository] = $this->service();
        $repository->shouldReceive('catalogs')->once()->andReturn($this->catalogs());
        $repository->shouldReceive('existingDocuments')->once()->with(['1075676060'])->andReturn([]);
        $repository->shouldNotReceive('createEmployee');
        $file = $this->workbook([
            $this->row(['numero_documento' => 1075676060]),
            $this->row(['numero_documento' => '1075676060', 'nombres' => 'LUIS']),
        ]);

        try {
            $result = $service->validate($file);
            $this->assertSame(2, $result['invalid']);
            $this->assertCount(2, collect($result['errors'])->filter(
                fn ($error) => str_contains($error['message'], 'duplicado')
            ));
        } finally {
            @unlink($file->getRealPath());
        }
    }

    public function test_validation_rejects_existing_document_and_unknown_catalog_without_writing(): void
    {
        [$service, $repository] = $this->service();
        $repository->shouldReceive('catalogs')->once()->andReturn($this->catalogs());
        $repository->shouldReceive('existingDocuments')->once()->andReturn(['0099']);
        $repository->shouldNotReceive('createEmployee');
        $file = $this->workbook([$this->row(['numero_documento' => '0099', 'area' => 'Área inexistente'])]);

        try {
            $result = $service->validate($file);
            $this->assertSame(1, $result['invalid']);
            $this->assertTrue(collect($result['errors'])->contains(fn ($error) => str_contains($error['message'], 'Ya existe')));
            $this->assertTrue(collect($result['errors'])->contains(fn ($error) => $error['field'] === 'area'));
        } finally {
            @unlink($file->getRealPath());
        }
    }

    public function test_import_maps_only_supported_tables_and_does_not_create_histories(): void
    {
        [$service, $repository, $audit] = $this->service();
        $repository->shouldReceive('catalogs')->once()->andReturn($this->catalogs());
        $repository->shouldReceive('existingDocuments')->once()->andReturn([]);
        $repository->shouldReceive('createEmployee')->once()->with(Mockery::on(
            fn ($row) => $row['numero_documento'] === '1075676060'
                && $row['numero_carpeta'] === '9'
                && $row['genero'] === 'M'
                && $row['estado_empleado'] === 'ACTIVO'
                && $row['id_tipo_contrato'] === 2
        ))->andReturn(55);
        $repository->shouldReceive('saveProfile')->once()->with(55, Mockery::type('array'));
        $repository->shouldReceive('saveSocialSecurity')->once()->with(55, Mockery::type('array'));
        $repository->shouldReceive('saveSize')->once()->with(55, 1, 5, 9);
        $audit->shouldReceive('record')->once();
        DB::shouldReceive('transaction')->once()->andReturnUsing(fn ($callback) => $callback());
        $file = $this->workbook([$this->row([
            'numero_documento' => 1075676060,
            'numero_carpeta' => '9',
            'genero' => 'M',
            'tipo_contrato' => 'Indefinido',
            'eps_si' => 'OK',
            'eps' => 'Nueva EPS',
            'talla_camisa' => 'S',
            'salario' => 2500000,
            'contrato_firmado_si' => 'OK',
        ])]);

        try {
            $this->assertSame(1, $service->import($file, 9, ['ip' => '127.0.0.1'])['created']);
        } finally {
            @unlink($file->getRealPath());
        }
    }

    public function test_import_with_errors_performs_no_transaction_or_writes(): void
    {
        [$service, $repository] = $this->service();
        $repository->shouldReceive('catalogs')->once()->andReturn($this->catalogs());
        $repository->shouldReceive('existingDocuments')->once()->andReturn([]);
        $repository->shouldNotReceive('createEmployee');
        DB::shouldReceive('transaction')->never();
        $file = $this->workbook([$this->row(['nombres' => null])]);

        try {
            $this->expectException(ApiException::class);
            $service->import($file, 9, []);
        } finally {
            @unlink($file->getRealPath());
        }
    }

    private function service(): array
    {
        $repository = Mockery::mock(BulkLoadEmployeeRepository::class);
        $audit = Mockery::mock(AuditService::class);

        return [new BulkLoadEmployeeService($repository, $audit), $repository, $audit];
    }

    private function assertUnsafeNumericDocument(int|float $document): void
    {
        [$service, $repository] = $this->service();
        $repository->shouldReceive('catalogs')->once()->andReturn($this->catalogs());
        $repository->shouldReceive('existingDocuments')->once()->andReturn([]);
        $file = $this->workbook([$this->row(['numero_documento' => $document])]);

        try {
            $result = $service->validate($file);
            $this->assertSame(1, $result['invalid']);
            $this->assertTrue(collect($result['errors'])->contains(
                fn ($error) => $error['field'] === 'numero_documento'
                    && str_contains($error['message'], 'Excel pudo alterar')
                    && str_contains($error['message'], 'máximo 15 dígitos')
            ));
        } finally {
            @unlink($file->getRealPath());
        }
    }

    private function workbook(array $rows, ?array $headers = null): UploadedFile
    {
        $path = tempnam(sys_get_temp_dir(), 'bulk_test_');
        $writer = new Writer;
        $writer->openToFile($path);
        $writer->getCurrentSheet()->setName(BulkLoadEmployeeService::DATA_SHEET);
        $writer->addRow(Row::fromValues($headers ?? array_keys(BulkLoadEmployeeService::COLUMNS)));
        foreach ($rows as $row) {
            $writer->addRow(Row::fromValues($row));
        }
        $writer->addNewSheetAndMakeItCurrent()->setName(BulkLoadEmployeeService::INSTRUCTIONS_SHEET);
        $writer->addRow(Row::fromValues(['INSTRUCCIONES']));
        $writer->close();

        return $this->uploaded($path);
    }

    private function uploaded(string $path): UploadedFile
    {
        return new UploadedFile(
            $path,
            'empleados.xlsx',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            null,
            true
        );
    }

    private function row(array $changes = []): array
    {
        $row = array_fill_keys(array_values(BulkLoadEmployeeService::COLUMNS), null);
        $row = array_replace($row, [
            'tipo_documento' => 'Cédula de ciudadanía',
            'numero_documento' => '00123',
            'nombres' => 'ANA',
            'apellidos' => 'PÉREZ',
            'estado_empleado' => 'ACTIVO',
        ], $changes);

        return array_values($row);
    }

    private function headers(string $path): array
    {
        $reader = new Reader;
        $reader->open($path);
        try {
            foreach ($reader->getSheetIterator() as $sheet) {
                if ($sheet->getName() !== BulkLoadEmployeeService::DATA_SHEET) {
                    continue;
                }
                foreach ($sheet->getRowIterator() as $row) {
                    return array_map(fn ($cell) => (string) $cell->getValue(), $row->getCells());
                }
            }
        } finally {
            $reader->close();
        }

        return [];
    }

    private function catalogs(): array
    {
        return [
            'document_types' => [['id' => 2, 'name' => 'Cédula de ciudadanía']],
            'areas' => [['id' => 1, 'name' => 'Administración']],
            'positions' => [['id' => 1, 'name' => 'Analista']],
            'contract_types' => [['id' => 2, 'name' => 'Indefinido']],
            'social_security' => [['id' => 1, 'name' => 'Nueva EPS', 'type' => 'EPS']],
            'dotation_sizes' => [
                ['id' => 5, 'type_id' => 1, 'type' => 'Camisa', 'name' => 'S'],
                ['id' => 6, 'type_id' => 2, 'type' => 'Pantalón', 'name' => '30'],
                ['id' => 7, 'type_id' => 3, 'type' => 'Calzado', 'name' => '37'],
                ['id' => 8, 'type_id' => 4, 'type' => 'Overol', 'name' => 'M'],
            ],
        ];
    }
}
