<?php

namespace App\Services;

use Exception;
use ZipArchive;

class CertificateRenderer
{
    public function render(array $data): string
    {
        $content = $this->pdfContent($data);
        $objects = [
            "<< /Type /Catalog /Pages 2 0 R >>",
            "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
            "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R /F2 5 0 R >> >> /Contents 6 0 R >>",
            "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
            "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>",
            "<< /Length ".strlen($content)." >>\nstream\n".$content."\nendstream",
        ];

        $pdf = "%PDF-1.4\n";
        $offsets = [];
        foreach ($objects as $index => $object) {
            $offsets[] = strlen($pdf);
            $pdf .= ($index + 1)." 0 obj\n".$object."\nendobj\n";
        }

        $xref = strlen($pdf);
        $pdf .= "xref\n0 ".(count($objects) + 1)."\n0000000000 65535 f \n";
        foreach ($offsets as $offset) {
            $pdf .= sprintf("%010d 00000 n \n", $offset);
        }
        $pdf .= "trailer\n<< /Size ".(count($objects) + 1)." /Root 1 0 R >>\nstartxref\n".$xref."\n%%EOF";

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
        $city = $city !== '' ? $city : $this->text($company['ciudad'] ?? '');

        $commands = [
            '0.08 0.18 0.36 rg',
            '0 0 595 842 re f',
            '0.09 0.18 0.36 rg',
            '0 0 595 842 re S',
            '0.08 0.18 0.36 rg',
            '0 0 595 90 re f',
            '0.94 0.95 0.97 rg',
            '0 0 595 842 re f',
        ];

        $commands[] = '0.08 0.18 0.36 rg';
        $commands[] = 'BT /F2 22 Tf 52 770 Td ('.$this->pdfText('GESTIÓN DE TALENTO HUMANO').') Tj ET';
        $commands[] = 'BT /F1 9 Tf 52 749 Td ('.$this->pdfText('BBTH-F-002 | CERTIFICADO LABORAL A COLABORADOR ACTIVO').') Tj ET';
        $commands[] = 'BT /F2 20 Tf 52 715 Td ('.$this->pdfText('CERTIFICADO LABORAL A COLABORADOR ACTIVO').') Tj ET';
        $commands[] = 'BT /F1 10 Tf 52 690 Td ('.$this->pdfText('Código: '.$this->text($format['codigo_formato'] ?? 'BBTH-F-002')).') Tj ET';
        $commands[] = 'BT /F2 13 Tf 52 652 Td ('.$this->pdfText('SUSCRITA TALENTO HUMANO').') Tj ET';
        $commands[] = 'BT /F1 10 Tf 52 625 Td ('.$this->pdfText('La persona suscrita, responsable del área de Talento Humano').') Tj ET';
        $commands[] = 'BT /F1 10 Tf 52 609 Td ('.$this->pdfText('de la compañía '.$this->text($company['razon_social'] ?? '') . '.').') Tj ET';
        $commands[] = 'BT /F2 13 Tf 52 566 Td ('.$this->pdfText('CERTIFICA').') Tj ET';
        $commands[] = 'BT /F1 10 Tf 52 538 Td ('.$this->pdfText('Que '.$this->text($employee['nombre_completo'] ?? '') . ', identificado(a) con ').') Tj ET';
        $commands[] = 'BT /F1 10 Tf 52 522 Td ('.$this->pdfText($this->text($employee['tipo_documento'] ?? '').' número '.$this->text($employee['numero_documento'] ?? '')).') Tj ET';
        $commands[] = 'BT /F1 10 Tf 52 506 Td ('.$this->pdfText('labora en nuestra compañía desde '.$this->text($employee['fecha_ingreso'] ?? '')).') Tj ET';
        $commands[] = 'BT /F1 10 Tf 52 490 Td ('.$this->pdfText('cumpliendo funciones correspondientes al cargo de '.$this->text($contract['cargo'] ?? '') . '.').') Tj ET';
        $commands[] = 'BT /F1 10 Tf 52 450 Td ('.$this->pdfText($city.', '. $date).') Tj ET';

        $y = 408;
        foreach (array_slice($functions, 0, 12) as $function) {
            $commands[] = 'BT /F1 9 Tf 52 '.$y.' Td (• '. $this->pdfText($function).') Tj ET';
            $y -= 18;
        }

        $commands[] = 'BT /F2 11 Tf 52 310 Td ('.$this->pdfText('Cordialmente,').') Tj ET';
        $commands[] = 'BT /F1 10 Tf 52 286 Td ('.$this->pdfText($this->text($signer['nombre'] ?? '')).') Tj ET';
        $commands[] = 'BT /F1 10 Tf 52 268 Td ('.$this->pdfText($this->text($signer['cargo'] ?? '')).') Tj ET';
        $commands[] = 'BT /F1 9 Tf 52 250 Td ('.$this->pdfText('TEL. '.$this->text($signer['telefono'] ?? '')).') Tj ET';
        $commands[] = 'BT /F1 8 Tf 52 62 Td ('.$this->pdfText('Documento generado por BBF SisAdmin | versión 01 | '.$date).') Tj ET';
        $commands[] = 'BT /F1 8 Tf 510 62 Td ('.$this->pdfText('Página 1 de 1').') Tj ET';

        return implode("\n", $commands)."\n";
    }

    private function contentTypes(): string
    {
        return <<<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>
XML;
    }

    private function rootRelationships(): string
    {
        return <<<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>
XML;
    }

    private function documentRelationships(): string
    {
        return <<<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>
XML;
    }

    private function styles(): string
    {
        return <<<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/></w:rPr></w:rPrDefault></w:docDefaults>
</w:styles>
XML;
    }

    private function document(array $data): string
    {
        $employee = $data['empleado'] ?? [];
        $contract = $data['contrato'] ?? [];
        $functions = $data['funciones'] ?? [];
        $company = $data['empresa'] ?? [];
        $signer = $data['firmantes'][0] ?? [];
        $format = $data['formato'] ?? [];
        $city = $this->text($employee['lugar_expedicion_documento'] ?? $company['ciudad'] ?? '');
        $city = $city !== '' ? $city : 'La ciudad se configura en el sistema';
        $date = $this->text($data['fecha_expedicion'] ?? '');
        $body = [
            'header' => sprintf('%s, %s', $city, $date),
            'date' => $date,
            'title' => 'CERTIFICADO LABORAL A COLABORADOR ACTIVO',
            'code' => $this->text($format['codigo_formato'] ?? 'BBTH-F-002'),
            'company' => $this->text($company['razon_social'] ?? ''),
            'employee' => $this->text($employee['nombre_completo'] ?? ''),
            'document' => sprintf('%s número %s', $this->text($employee['tipo_documento'] ?? ''), $this->text($employee['numero_documento'] ?? '')),
            'place' => $this->text($employee['lugar_expedicion_documento'] ?? ''),
            'ingress' => $this->text($employee['fecha_ingreso'] ?? ''),
            'position' => $this->text($contract['cargo'] ?? ''),
            'functions' => $functions,
            'request' => $this->text($data['solicitud'] ?? ''),
            'signer' => $signer,
        ];

        $paragraphs = [
            [$body['header'], 'Normal'],
            ['', 'Heading1'],
            [$body['title'], 'Heading1'],
            ['Código: '.$body['code'], 'Normal'],
            ['', 'Normal'],
            ['SUSCRITA TALENTO HUMANO', 'Heading2'],
            ['La persona suscrita, responsable del área de Talento Humano de la compañía '.$body['company'].'.', 'Normal'],
            ['', 'Normal'],
            ['CERTIFICA', 'Heading2'],
            ['Que '.$body['employee'].', identificado(a) con '.$body['document'].' '.$body['place'].', labora en nuestra compañía desde '.$body['ingress'].', cumpliendo funciones correspondientes al cargo de '.$body['position'].'.', 'Normal'],
            ['', 'Normal'],
        ];

        foreach ($functions as $function) {
            $paragraphs[] = ['• '.$function, 'Normal'];
        }
        $paragraphs[] = ['', 'Normal'];
        $paragraphs[] = ['Este certificado se expide el '.$body['date'].' a solicitud '.$body['request'].', para los fines pertinentes que se requieran.', 'Normal'];
        $paragraphs[] = ['', 'Normal'];
        $paragraphs[] = ['Cordialmente,', 'Normal'];
        $paragraphs[] = ['', 'Normal'];
        $paragraphs[] = ['________________________________________', 'Normal'];
        $paragraphs[] = [$body['signer']['nombre'] ?? '', 'Normal'];
        $paragraphs[] = [$body['signer']['cargo'] ?? '', 'Normal'];
        $paragraphs[] = ['TEL. '.($body['signer']['telefono'] ?? ''), 'Normal'];

        return <<<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
XML.$this->paragraphs($paragraphs).<<<XML
    <w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/></w:sectPr>
  </w:body>
</w:document>
XML;
    }

    private function paragraphs(array $paragraphs): string
    {
        $xml = '';
        foreach ($paragraphs as [$text, $style]) {
            $property = $style === 'Heading1'
                ? '<w:pPr><w:pStyle w:val="Heading1"/></w:pPr>'
                : ($style === 'Heading2' ? '<w:pPr><w:pStyle w:val="Heading2"/></w:pPr>' : '');
            $xml .= '<w:p>'.$property.'<w:r><w:t xml:space="preserve">'.htmlspecialchars($text, ENT_XML1 | ENT_QUOTES, 'UTF-8').'</w:t></w:r></w:p>';
        }
        return $xml;
    }

    private function text(mixed $value): string
    {
        return is_string($value) && trim($value) !== '' ? trim($value) : '';
    }
}
