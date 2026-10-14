<?php

namespace Tests\Unit;

use App\Exceptions\ApiException;
use App\Services\CertificateRenderer;
use PHPUnit\Framework\TestCase;

class CertificateRendererTest extends TestCase
{
    public function test_salary_affiliations_continue_without_loss_and_do_not_render_functions(): void
    {
        $data = $this->data();
        $data['formato']['variante'] = 'SALARIO_AFILIACIONES';
        $data['contrato']['tipo_contrato'] = 'Indefinido';
        $data['salario'] = (new \App\Services\SalaryTextFormatter)->format('1750905.25');
        $data['afiliaciones'] = array_fill_keys(['eps', 'arl', 'fondo_pension', 'caja_compensacion', 'fondo_solidaridad', 'retencion_fuente'], str_repeat('Entidad larga de prueba ', 180).'FIN_ENTIDAD');
        $pdf = (new CertificateRenderer)->render($data);
        $this->assertStringContainsString('$1.750.905,25', $pdf);
        $this->assertSame(6, substr_count($pdf, 'FIN_ENTIDAD'));
        $this->assertStringNotContainsString('Desarrollar software', $pdf);
        preg_match('/\/Type \/Pages .*?\/Count (\d+)/', $pdf, $match);
        $this->assertGreaterThan(1, (int) $match[1]);
    }
    public function test_rejects_header_metadata_that_cannot_fit_in_its_cell(): void
    {
        $data = $this->data();
        $data['formato']['titulo'] = str_repeat('Título documental extenso ', 100);
        $this->expectException(ApiException::class);
        $this->expectExceptionMessage('Los metadatos del formato exceden');
        (new CertificateRenderer)->render($data);
    }

    public function test_rejects_footer_that_would_overlap_body_instead_of_emitting_a_broken_pdf(): void
    {
        $data = $this->data();
        $data['formato']['control_documental']['motivo_revision'] = str_repeat('Revisión de prueba ', 1000);
        $this->expectException(ApiException::class);
        $this->expectExceptionMessage('El control documental excede');
        (new CertificateRenderer)->render($data);
    }

    public function test_rejects_unsupported_characters_instead_of_changing_official_names(): void
    {
        $data = $this->data();
        $data['empleado']['nombre_completo'] = 'Ana 李';
        $this->expectException(ApiException::class);
        $this->expectExceptionMessage('Hay caracteres');
        (new CertificateRenderer)->render($data);
    }

    public function test_escapes_pdf_delimiters_in_official_content(): void
    {
        $data = $this->data();
        $data['funciones'] = ['Verificar (calidad) y ruta C:\\documentos.'];
        $pdf = (new CertificateRenderer)->render($data);
        $this->assertStringContainsString('Verificar \\(calidad\\) y ruta C:\\\\documentos.', $pdf);
    }

    public function test_rejects_signature_too_large_to_remain_on_one_page(): void
    {
        $data = $this->data();
        $data['firmantes'][0]['cargo'] = str_repeat('Responsable de talento humano ', 300);
        $this->expectException(ApiException::class);
        $this->expectExceptionMessage('Los datos del firmante exceden');
        (new CertificateRenderer)->render($data);
    }

    public function test_every_text_command_sets_black_explicitly(): void
    {
        $pdf = (new CertificateRenderer)->render($this->data());
        preg_match_all('/(?:^|\n)([^\n]*BT [^\n]* Tj ET)/', $pdf, $matches);
        $this->assertNotEmpty($matches[1]);
        foreach ($matches[1] as $command) {
            $this->assertStringStartsWith('0 0 0 rg BT ', $command);
        }
        $this->assertStringNotContainsString('0.94 0.95 0.97 rg', $pdf);
    }

    public function test_all_functions_continue_on_numbered_pages_with_signature_at_the_end(): void
    {
        $data = $this->data();
        $data['funciones'] = array_map(fn ($i) => 'FUNCION_'.$i.' '.str_repeat('Supervisar los procesos de calidad y reportar novedades. ', 4), range(1, 30));
        $pdf = (new CertificateRenderer)->render($data);
        preg_match('/\/Type \/Pages .*?\/Count (\d+)/', $pdf, $match);
        $count = (int) $match[1];
        $this->assertGreaterThan(1, $count);
        foreach (range(1, 30) as $i) {
            $this->assertStringContainsString('FUNCION_'.$i.' ', $pdf);
        }
        foreach (range(1, $count) as $i) {
            $this->assertStringContainsString(mb_convert_encoding('Página '.$i.' de '.$count, 'Windows-1252', 'UTF-8'), $pdf);
        }
        $this->assertGreaterThan(strpos($pdf, 'FUNCION_30 '), strpos($pdf, 'Firmante de prueba'));
        preg_match_all('/BT \/F[12] 10 Tf ([\d.]+) ([\d.]+) Td/', $pdf, $positions, PREG_SET_ORDER);
        foreach ($positions as $position) {
            $this->assertGreaterThanOrEqual(100, (float) $position[2]);
            $this->assertLessThanOrEqual(646, (float) $position[2]);
        }
    }

    public function test_company_city_and_employee_document_place_are_distinct_and_dates_are_readable(): void
    {
        $data = $this->data();
        $data['empresa']['ciudad'] = 'Gachancipá';
        $data['empleado']['lugar_expedicion_documento'] = 'Riohacha';
        $pdf = (new CertificateRenderer)->render($data);
        $this->assertStringContainsString(mb_convert_encoding('Gachancipá, 9 de octubre de 2026', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString('de Riohacha', $pdf);
        $this->assertStringContainsString('3 de febrero de 2020', $pdf);
        $this->assertStringContainsString('Motivo de la', $pdf);
        $this->assertStringNotContainsString('Yuliana', $pdf);
    }

    private function data(): array
    {
        return [
            'empleado' => ['nombre_completo' => 'Ana Pérez', 'tipo_documento' => 'Cédula', 'numero_documento' => '123', 'fecha_ingreso' => '2020-02-03'],
            'contrato' => ['cargo' => 'Analista'], 'funciones' => ['Desarrollar software'],
            'empresa' => ['razon_social' => 'Empresa de prueba', 'ciudad' => 'Bogotá'],
            'fecha_expedicion' => '2026-10-09', 'formato' => ['codigo_formato' => 'BBTH-F-002'],
            'firmantes' => [['nombre' => 'Firmante de prueba', 'cargo' => 'RRHH', 'telefono' => '123']],
        ];
    }

    public function test_renders_a_pdf_with_the_official_certificate_structure(): void
    {
        $renderer = new CertificateRenderer;
        $content = $renderer->render([
            'empleado' => [
                'nombre_completo' => 'Ana Pérez',
                'tipo_documento' => 'Cédula',
                'numero_documento' => '123',
                'fecha_ingreso' => '2020-02-03',
                'lugar_expedicion_documento' => 'Bogotá',
            ],
            'contrato' => ['cargo' => 'Analista', 'id_empleado_contrato' => 7],
            'funciones' => ['Desarrollar software'],
            'empresa' => ['razon_social' => 'Empresa de prueba', 'ciudad' => 'Bogotá'],
            'fecha_expedicion' => '2026-10-06',
            'solicitud' => 'Se expide a solicitud del colaborador.',
            'formato' => ['codigo_formato' => 'BBTH-F-002', 'nombre' => 'Certificado laboral a colaborador'],
            'firmantes' => [[
                'nombre' => 'Firmante de prueba',
                'cargo' => 'RRHH',
                'telefono' => '123',
            ]],
        ]);

        $this->assertStringStartsWith('%PDF-1.4', $content);
        $this->assertStringEndsWith('%%EOF', $content);
        $this->assertStringContainsString('CERTIFICADO LABORAL A COLABORADOR ACTIVO', $content);
        $this->assertStringContainsString(mb_convert_encoding('Ana Pérez', 'Windows-1252', 'UTF-8'), $content);
        $this->assertStringContainsString(mb_convert_encoding('Analista', 'Windows-1252', 'UTF-8'), $content);
        $this->assertStringContainsString(mb_convert_encoding('Desarrollar software', 'Windows-1252', 'UTF-8'), $content);
        $this->assertStringContainsString(mb_convert_encoding('Empresa de prueba', 'Windows-1252', 'UTF-8'), $content);
        $this->assertStringContainsString(mb_convert_encoding('Firmante de prueba', 'Windows-1252', 'UTF-8'), $content);
        $this->assertStringContainsString('SUSCRITA TALENTO HUMANO', $content);
    }

    public function test_checklist_renders_five_pending_items_with_registered_motive(): void
    {
        $pdf = (new CertificateRenderer)->render($this->checklistData());
        foreach (['Certificado laboral: Documento que certifica el tiempo de servicio', 'Planilla de seguridad social', 'Examen de egreso', 'Entrevista:'] as $item) {
            $this->assertStringContainsString(mb_convert_encoding($item, 'Windows-1252', 'UTF-8'), $pdf);
        }
        $this->assertStringContainsString(mb_convert_encoding('Por medio de la presente, nos permitimos hacer entrega formal', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('Renuncia voluntaria', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('Carta de aceptación de renuncia', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('Reconocemos y agradecemos su compromiso', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString('Para constancia firma,', $pdf);
        $this->assertStringNotContainsString('se encuentra entregada al excolaborador', $pdf);
    }

    public function test_checklist_adapts_termination_reference_to_recorded_motive(): void
    {
        $data = $this->checklistData('Terminación con justa causa');
        $pdf = (new CertificateRenderer)->render($data);
        $this->assertStringContainsString(mb_convert_encoding('Notificación de terminación del contrato', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('Terminación con justa causa', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringNotContainsString(mb_convert_encoding('Carta de aceptación de renuncia', 'Windows-1252', 'UTF-8'), $pdf);
    }

    public function test_acceptance_renders_letter_with_presentation_and_effective_dates(): void
    {
        $pdf = (new CertificateRenderer)->render($this->acceptanceData());
        $this->assertStringContainsString(mb_convert_encoding('RF. Carta de Aceptación de Renuncia', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('acepta la renuncia que usted ha presentado', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('1 de septiembre de 2026', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('1 de octubre de 2026', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('elementos suministrados por la compañía', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('acreencias laborales', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString('Sin otro particular,', $pdf);
        $this->assertStringContainsString('Cordialmente,', $pdf);
    }

    public function test_non_renewal_renders_notice_with_subscription_and_expiry_dates(): void
    {
        $pdf = (new CertificateRenderer)->render($this->nonRenewalData());
        $this->assertStringContainsString(mb_convert_encoding('no renovación de contrato de trabajo', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('NO será prorrogado ni renovado', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString('900747203', $pdf);
        $this->assertStringContainsString(mb_convert_encoding('1 de mayo de 2026', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('1 de agosto de 2026', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString('Cordialmente,', $pdf);
    }

    public function test_cesantias_renders_partial_withdrawal_letter(): void
    {
        $pdf = (new CertificateRenderer)->render($this->cesantiasData());
        $this->assertStringContainsString(mb_convert_encoding('ASUNTO: Retiro parcial', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('el retiro parcial', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString('PORVENIR', $pdf);
        $this->assertStringContainsString(mb_convert_encoding('Reparaciones locativas', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString('$1.500.000,00', $pdf);
        $this->assertStringContainsString(mb_convert_encoding('Firma del Empleador', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('Firma del Trabajador', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString('Cordialmente,', $pdf);
    }

    public function test_cesantias_renders_total_withdrawal_letter(): void
    {
        $data = $this->cesantiasData();
        $data['solicitud']['modalidad'] = 'TOTAL';
        $pdf = (new CertificateRenderer)->render($data);
        $this->assertStringContainsString(mb_convert_encoding('ASUNTO: Retiro total', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('el retiro total de las', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringNotContainsString(mb_convert_encoding('retiro parcial de vivienda', 'Windows-1252', 'UTF-8'), $pdf);
    }

    public function test_cesantias_termination_renders_request_with_period_and_signatures(): void
    {
        $pdf = (new CertificateRenderer)->render($this->cesantiasTerminationData());
        $this->assertStringContainsString(mb_convert_encoding('ASUNTO: Retiro Total de Cesantías', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('Gachancipa, solicita el', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString('PORVENIR', $pdf);
        $this->assertStringContainsString('900747203-1', $pdf);
        $this->assertStringContainsString(mb_convert_encoding('Firma del Empleador', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('Firma del Trabajador', 'Windows-1252', 'UTF-8'), $pdf);
        $this->assertStringContainsString(mb_convert_encoding('debido a la terminación de su contrato', 'Windows-1252', 'UTF-8'), $pdf);
    }

    private function cesantiasTerminationData(): array
    {
        return [
            'empleado' => [
                'nombre_completo' => 'Ana Pérez',
                'tipo_documento' => 'Cédula',
                'numero_documento' => '123',
                'lugar_expedicion_documento' => 'Gachancipa',
            ],
            'fondo_cesantias' => 'PORVENIR',
            'solicitud' => [
                'fecha_desde' => '2024-06-01',
                'fecha_hasta' => '2026-08-12',
                'nit_empresa' => '900747203-1',
                'correo_contacto' => 'contacto@example.com',
                'telefono_contacto' => '3153188486',
            ],
            'empresa' => ['razon_social' => 'Empresa de prueba', 'ciudad' => 'Bogotá'],
            'fecha_expedicion' => '2026-10-06',
            'formato' => ['clave_formato' => 'CESANTIAS_FIN_CONTRATO', 'codigo_formato' => 'BBTH-F-012', 'nombre' => 'Carta de retiro de cesantías por finalización'],
            'firmantes' => [[
                'nombre' => 'Firmante de prueba',
                'cargo' => 'RRHH',
                'telefono' => '123',
            ]],
        ];
    }

    private function cesantiasData(): array
    {
        return [
            'empleado' => [
                'nombre_completo' => 'Ana Pérez',
                'tipo_documento' => 'Cédula',
                'numero_documento' => '123',
            ],
            'fondo_cesantias' => 'PORVENIR',
            'solicitud' => [
                'modalidad' => 'PARCIAL',
                'concepto_retiro' => 'Reparaciones locativas',
                'monto' => ['decimal' => '1500000.00', 'cifra' => '$1.500.000,00', 'letras' => 'un millón quinientos mil pesos colombianos'],
            ],
            'empresa' => ['razon_social' => 'Empresa de prueba', 'ciudad' => 'Bogotá'],
            'fecha_expedicion' => '2026-10-06',
            'formato' => ['clave_formato' => 'CESANTIAS_VIVIENDA', 'codigo_formato' => 'BBTH-F-011', 'nombre' => 'Carta de retiro de cesantías para vivienda'],
            'firmantes' => [[
                'nombre' => 'Firmante de prueba',
                'cargo' => 'RRHH',
                'telefono' => '123',
            ]],
        ];
    }

    private function acceptanceData(): array
    {
        return [
            'empleado' => [
                'nombre_completo' => 'Ana Pérez',
                'tipo_documento' => 'Cédula',
                'numero_documento' => '123',
            ],
            'retiro' => [
                'id_retiro' => 3,
                'fecha_retiro' => '2026-10-01',
                'motivo_retiro' => 'Renuncia voluntaria',
                'fecha_presentacion_renuncia' => '2026-09-01',
            ],
            'contrato' => ['cargo' => 'Supervisor de Calidad'],
            'empresa' => ['razon_social' => 'Empresa de prueba', 'ciudad' => 'Bogotá'],
            'fecha_expedicion' => '2026-10-06',
            'formato' => ['clave_formato' => 'ACEPTACION_RENUNCIA', 'codigo_formato' => 'BBTH-F-005', 'nombre' => 'Carta de aceptación de renuncia'],
            'firmantes' => [[
                'nombre' => 'Firmante de prueba',
                'cargo' => 'RRHH',
                'telefono' => '123',
            ]],
        ];
    }

    private function nonRenewalData(): array
    {
        return [
            'empleado' => ['nombre_completo' => 'Ana Pérez'],
            'contrato' => [
                'id_empleado_contrato' => 7,
                'tipo_contrato' => 'Fijo',
                'fecha_inicio' => '2026-05-01',
                'fecha_fin' => '2026-08-01',
            ],
            'empresa' => ['razon_social' => 'Empresa de prueba', 'ciudad' => 'Bogotá'],
            'nit_empresa' => '900747203',
            'fecha_expedicion' => '2026-10-06',
            'formato' => ['clave_formato' => 'NO_RENOVACION_CONTRATO', 'codigo_formato' => 'BBTH-F-015', 'nombre' => 'Carta de notificación de no renovación'],
            'firmantes' => [[
                'nombre' => 'Firmante de prueba',
                'cargo' => 'RRHH',
                'telefono' => '123',
            ]],
        ];
    }

    private function checklistData(string $motivo = 'Renuncia voluntaria'): array
    {
        return [
            'empleado' => [
                'nombre_completo' => 'Ana Pérez',
                'tipo_documento' => 'Cédula',
                'numero_documento' => '123',
                'fecha_ingreso' => '2023-01-16',
            ],
            'retiro' => ['id_retiro' => 3, 'fecha_retiro' => '2026-10-01', 'motivo_retiro' => $motivo],
            'contrato' => ['tipo_contrato' => null, 'cargo' => 'Supervisor de Calidad'],
            'empresa' => ['razon_social' => 'Empresa de prueba', 'ciudad' => 'Bogotá'],
            'fecha_expedicion' => '2026-10-06',
            'formato' => ['clave_formato' => 'CONSTANCIA_ENTREGA_RETIRO', 'codigo_formato' => 'BBTH-F-004', 'nombre' => 'Check list de retiro'],
            'firmantes' => [[
                'nombre' => 'Firmante de prueba',
                'cargo' => 'RRHH',
                'telefono' => '123',
            ]],
            'encabezado_talento_humano' => 'TALENTO HUMANO',
        ];
    }
}
