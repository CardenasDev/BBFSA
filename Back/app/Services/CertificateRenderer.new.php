<?php

namespace App\Services;

class CertificateRenderer
{
    public function render(array $data): string
    {
        $stream = $this->pdfContent($data);
        $objects = [
            "<< /Type /Catalog /Pages 2 0 R >>",
            "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
            "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R /F2 5 0 R >> >> /Contents 6 0 R >>",
            "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
            "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>",
            "<< /Length ".strlen($stream)." >>\nstream\n".$stream."\nendstream",
        ];

        $pdf = "%PDF-1.4\n";
        $offsets = [];
        foreach ($objects as $index => $object) {
            $offsets[] = strlen($pdf);
            $pdf .= ($index + 1)." 0 obj\n".$object."\nendobj\n";
        }

        $xrefOffset = strlen($pdf);
        $pdf .= "xref\n0 ".(count($objects) + 1)."\n0000000000 65535 f \n";
        foreach ($offsets as $offset) {
            $pdf .= sprintf("%010d 00000 n \n", $offset);
        }
        $pdf .= "trailer\n<< /Size ".(count($objects) + 1)." /Root 1 0 R >>\nstartxref\n".$xrefOffset."\n%%EOF";

        return $pdf;
    }

    private function pdfContent(array $data): string
    {
        $employee = $data['empleado'] ?? [];
        $contract = $data['contrato'] ?? [];
        $functions = $data['funciones'] ?? [];
        $company = $data['empresa'] ?? [];
        $signer = $data['firmantes'][0] ?? [];
        $format = $data['formato'] ?? [];
        $city = $this->text($employee['lugar_expedicion_documento'] ?? $company['ciudad'] ?? '');
        $date = $this->text($data['fecha_expedicion'] ?? '');

        $commands = [
            '0.08 0.18 0.36 rg 0 0 595 842 re f',
            '0.09 0.18 0.36 rg 0 0 595 842 re S',
            '0.08 0.18 0.36 rg 0 0 595 90 re f',
            '0.94 0.95 0.97 rg 0 0 595 842 re f',
        ];

        $lines = [
            ['GESTION DE TALENTO HUMANO', 22, 52, 770, '/F2'],
            ['BBTH-F-002 | CERTIFICADO LABORAL A COLABORADOR ACTIVO', 9, 52, 749, '/F1'],
            ['CERTIFICADO LABORAL A COLABORADOR ACTIVO', 20, 52, 715, '/F2'],
            ['Codigo: '.($format['codigo_formato'] ?? 'BBTH-F-002'), 10, 52, 690, '/F1'],
            ['SUSCRITA TALENTO HUMANO', 13, 52, 652, '/F2'],
            ['La persona suscrita, responsable del area de Talento Humano', 10, 52, 625, '/F1'],
            ['de la compania '.($company['razon_social'] ?? ''), 10, 52, 609, '/F1'],
            ['CERTIFICA', 13, 52, 566, '/F2'],
            ['Que '.($employee['nombre_completo'] ?? '').', identificado(a) con ', 10, 52, 538, '/F1'],
            [($employee['tipo_documento'] ?? '').' numero '.($employee['numero_documento'] ?? ''), 10, 52, 522, '/F1'],
            ['labora en nuestra compania desde '.($employee['fecha_ingreso'] ?? ''), 10, 52, 506, '/F1'],
            ['cumpliendo funciones correspondientes al cargo de '.($contract['cargo'] ?? ''), 10, 52, 490, '/F1'],
            [$city.($city !== '' && $date !== '' ? ', ' : '').$date, 10, 52, 450, '/F1'],
            ['Cordialmente', 11, 52, 310, '/F2'],
            [$signer['nombre'] ?? '', 10, 52, 286, '/F1'],
            [$signer['cargo'] ?? '', 10, 52, 268, '/F1'],
            ['TEL. '.($signer['telefono'] ?? ''), 9, 52, 250, '/F1'],
            ['Documento generado por BBF SisAdmin | version 01 | '.$date, 8, 52, 62, '/F1'],
            ['Pagina 1 de 1', 8, 510, 62, '/F1'],
        ];

        foreach ($lines as [$text, $size, $x, $y, $font]) {
            $commands[] = "BT $font $size Tf $x $y Td (".$this->pdfText($text).") Tj ET";
        }

        $y = 408;
        foreach (array_slice($functions, 0, 12) as $function) {
            $commands[] = "BT /F1 9 Tf 52 $y Td (- ".$this->pdfText($function).") Tj ET";
            $y -= 18;
        }

        return implode("\n", $commands)."\n";
    }

    private function pdfText(string $value): string
    {
        $value = mb_convert_encoding($value, 'Windows-1252', 'UTF-8');
        return str_replace(['\\', '(', ')'], ['\\\\', '\\(', '\\)'], $value);
    }

    private function text(mixed $value): string
    {
        return is_string($value) && trim($value) !== '' ? trim($value) : '';
    }
}
