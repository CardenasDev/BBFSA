<?php

namespace App\Services;

use App\Exceptions\ApiException;

/** PDF F-002 con fuentes estándar y sin procesos externos. */
class CertificateRenderer
{
    private const LEFT = 70;

    private const WIDTH = 472;

    private const TOP = 646;

    private array $widths;

    public function __construct()
    {
        $this->widths = require __DIR__.'/../../resources/certificates/helvetica-widths.php';
    }

    public function render(array $data): string
    {
        $footer = $this->footer($data);
        $bottom = 40 + $footer['height'] + 22;
        $pages = [[]];
        $page = 0;
        $y = self::TOP;
        foreach ($this->blocks($data) as $block) {
            $size = $block['size'] ?? 10;
            $leading = $size + 3;
            $x = self::LEFT + ($block['indent'] ?? 0);
            $font = ! empty($block['bold']) ? 'F2' : 'F1';
            $lines = $this->wrap($block['text'], $size, self::WIDTH - ($x - self::LEFT), $font);
            $height = count($lines) * $leading;
            if (! empty($block['signature']) && $height > self::TOP - $bottom) {
                throw new ApiException('Los datos del firmante exceden el espacio del certificado.', 422, ['firmantes' => ['Revise la extensión del nombre, cargo y teléfono.']]);
            }
            $reserved = $height + ($block['keep_next'] ?? 0);
            // Mantener firma y párrafos cortos juntos; las funciones extensas continúan.
            if ($reserved <= self::TOP - $bottom && $y - $reserved < $bottom) {
                $pages[++$page] = [];
                $y = self::TOP;
            }
            foreach ($lines as $lineIndex => $line) {
                if ($y - $leading < $bottom) {
                    $pages[++$page] = [];
                    $y = self::TOP;
                }
                $lineX = ! empty($block['center']) ? self::LEFT + (self::WIDTH - $this->width($line, $size, $font)) / 2 : $x;
                if (! empty($block['bullet']) && $lineIndex === 0) {
                    $pages[$page][] = $this->textCommand('•', $size, $x - 10, $y, $font);
                }
                $pages[$page][] = $this->textCommand($line, $size, $lineX, $y, $font);
                $y -= $leading;
            }
            $y -= $block['after'] ?? 9;
        }
        $path = __DIR__.'/../../resources/certificates/bbf-logo.jpeg';
        $logo = is_readable($path) ? file_get_contents($path) : false;
        $image = $logo !== false ? @getimagesizefromstring($logo) : false;
        if (! $image || $image[2] !== IMAGETYPE_JPEG || ($image['channels'] ?? 0) !== 3) {
            throw new ApiException('El recurso de logo del certificado no está disponible o no es válido.', 500);
        }
        $objects = [
            '<< /Type /Catalog /Pages 2 0 R >>', '',
            '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>',
            '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>',
            '<< /Type /XObject /Subtype /Image /Width '.$image[0].' /Height '.$image[1].' /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length '.strlen($logo)." >>\nstream\n".$logo."\nendstream",
            '<< /Type /ExtGState /ca 0.06 /CA 0.06 >>',
        ];
        $kids = [];
        foreach ($pages as $index => $commands) {
            $pageId = count($objects) + 1;
            $kids[] = $pageId.' 0 R';
            $stream = $this->header($data, $index + 1, count($pages))."\n".implode("\n", $commands)."\n".$footer['stream'];
            $objects[] = '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 3 0 R /F2 4 0 R >> /XObject << /Logo 5 0 R >> /ExtGState << /Watermark 6 0 R >> >> /Contents '.($pageId + 1).' 0 R >>';
            $objects[] = '<< /Length '.strlen($stream)." >>\nstream\n".$stream."\nendstream";
        }
        $objects[1] = '<< /Type /Pages /Kids ['.implode(' ', $kids).'] /Count '.count($pages).' >>';
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

        return $pdf."trailer\n<< /Size ".(count($objects) + 1)." /Root 1 0 R >>\nstartxref\n".$xref."\n%%EOF";
    }

    private function blocks(array $data): array
    {
        $employee = $data['empleado'];
        $company = $data['empresa'];
        $date = $this->dateText($data['fecha_expedicion']);
        $place = $this->text($employee['lugar_expedicion_documento'] ?? null);
        $blocks = [
            ['text' => $company['ciudad'].', '.$date, 'after' => 18],
            ['text' => 'SUSCRITA TALENTO HUMANO', 'bold' => true, 'center' => true, 'after' => 12],
            ['text' => 'La persona suscrita, responsable del área de Talento Humano de la compañía '.$company['razon_social'].'.', 'after' => 16],
            ['text' => 'CERTIFICA', 'bold' => true, 'center' => true, 'after' => 12],
            ['text' => 'Que '.$employee['nombre_completo'].', identificado(a) con '.$employee['tipo_documento'].' número '.$employee['numero_documento'].($place !== '' ? ' de '.$place : '').', labora en nuestra compañía desde '.$this->dateText($employee['fecha_ingreso']).', cumpliendo funciones correspondientes al cargo de '.$data['contrato']['cargo'].'.'],
        ];
        $variant = $data['formato']['variante'] ?? 'GENERAL';
        if ($variant === 'SALARIO_AFILIACIONES') {
            $blocks[] = ['text' => 'Su contrato es de tipo '.$data['contrato']['tipo_contrato'].', con un salario mensual de '.$data['salario']['letras'].' ('.$data['salario']['cifra'].').'];
            $blocks[] = ['text' => 'Tiene registradas las siguientes afiliaciones e información declarada:', 'keep_next' => 26];
            foreach (['eps' => 'EPS', 'arl' => 'ARL', 'fondo_pension' => 'Fondo de pensión', 'caja_compensacion' => 'Caja de compensación', 'fondo_solidaridad' => 'Fondo de solidaridad', 'retencion_fuente' => 'Retención en la fuente'] as $key => $label) {
                $blocks[] = ['text' => $label.': '.$data['afiliaciones'][$key], 'indent' => 10, 'bullet' => true, 'after' => 4];
            }
        } elseif ($variant === 'HISTORIAL_CONTRACTUAL') {
            $blocks[] = ['text' => 'Su contrato actual es de tipo '.$data['contrato']['tipo_contrato'].', con una duración de '.$data['duracion_meses'].' meses, iniciado el '.$this->dateText($data['contrato']['fecha_inicio']).($data['contrato']['fecha_fin'] ? ' y finaliza el '.$this->dateText($data['contrato']['fecha_fin']) : '').'.'];
            $blocks[] = ['text' => 'Se desempeña en el cargo de '.$data['contrato']['cargo'].', con un salario mensual de '.$data['salario']['letras'].' ('.$data['salario']['cifra'].').'];
            $blocks[] = ['text' => 'La fecha de inicio de labores certificada es el '.$this->dateText($data['fecha_inicio_labores']).'.', 'after' => 14];
        } else {
            $blocks[] = ['text' => 'Durante el tiempo que ha laborado en nuestra empresa, el trabajador ha desempeñado las siguientes funciones principales:', 'keep_next' => 26];
            foreach ($data['funciones'] as $function) {
                $blocks[] = ['text' => $function, 'indent' => 10, 'bullet' => true, 'after' => 4];
            }
        }
        $blocks[] = ['text' => 'Este certificado se expide el '.$date.', a solicitud del colaborador, para los fines pertinentes que se requieran.', 'after' => 14];
        foreach ($data['firmantes'] as $signer) {
            $blocks[] = ['text' => "Cordialmente,\n\n____________________\n".$signer['nombre']."\nTEL. ".$signer['telefono']."\n".$signer['cargo'], 'signature' => true, 'after' => 14];
        }

        return $blocks;
    }

    private function header(array $data, int $page, int $total): string
    {
        $format = $data['formato'] ?? [];
        $commands = ['q /Watermark gs 442 0 0 246 85 273 cm /Logo Do Q', '0 0 0 RG 0.5 w 70 682 472 74 re S', '146 682 m 146 756 l S', '448 682 m 448 756 l S'];
        foreach ([734, 716, 698] as $y) {
            $commands[] = '448 '.$y.' m 542 '.$y.' l S';
        }
        $commands[] = 'q 66 0 0 36.84 75 701 cm /Logo Do Q';
        $commands[] = $this->cell('PROCESO: '.($format['proceso'] ?? 'GESTIÓN DE TALENTO HUMANO'), 151, 746, 292, 8, 'F2', 24);
        $commands[] = $this->cell($format['titulo'] ?? 'CERTIFICADO LABORAL A COLABORADOR ACTIVO', 151, 719, 292, 9, 'F2', 32);
        $commands[] = $this->cell('Código: '.($format['codigo_formato'] ?? 'BBTH-F-002'), 452, 746, 86, 7);
        $commands[] = $this->cell('Versión: '.($format['version_formato'] ?? '01'), 452, 726, 86, 7);
        $commands[] = $this->cell('Vigente a partir de: '.$this->shortDate($format['vigencia_desde'] ?? '2026-06-18'), 452, 709, 86, 6.5);
        $commands[] = $this->cell('Página '.$page.' de '.$total, 452, 687, 86, 7);

        return implode("\n", $commands);
    }

    private function footer(array $data): array
    {
        $format = $data['formato'] ?? [];
        $control = $format['control_documental'] ?? [];
        $rows = [
            ['Versión '.($format['version_formato'] ?? '01'), 'Fecha '.$this->shortDate($format['vigencia_desde'] ?? '2026-06-18'), 'Motivo de la revisión: '.($this->text($control['motivo_revision'] ?? null) ?: '—')],
            ['Elaboró: '.($this->text($control['elaboro'] ?? null) ?: '—'), 'Revisó: '.($this->text($control['reviso'] ?? null) ?: '—'), 'Aprobó: '.($this->text($control['aprobo'] ?? null) ?: '—')],
        ];
        $widths = [100, 100, 272];
        $height = 0;
        $prepared = [];
        foreach ($rows as $row) {
            $lines = [];
            foreach ($row as $index => $value) {
                $lines[] = $this->wrap($value, 7, $widths[$index] - 10);
            }
            $rowHeight = max(array_map('count', $lines)) * 9 + 10;
            $prepared[] = ['lines' => $lines, 'height' => $rowHeight];
            $height += $rowHeight;
        }
        if ($height > 140) {
            throw new ApiException('El control documental excede el espacio del certificado.', 422, ['control_documental' => ['Revise la extensión del motivo y de los responsables de revisión.']]);
        }
        $y = 40 + $height;
        $commands = ['0 0 0 RG 0.5 w'];
        foreach ($prepared as $row) {
            $x = self::LEFT;
            foreach ($row['lines'] as $index => $lines) {
                $commands[] = $x.' '.($y - $row['height']).' '.$widths[$index].' '.$row['height'].' re S';
                foreach ($lines as $lineIndex => $line) {
                    $commands[] = $this->textCommand($line, 7, $x + 5, $y - 12 - $lineIndex * 9);
                }
                $x += $widths[$index];
            }
            $y -= $row['height'];
        }

        return ['height' => $height, 'stream' => implode("\n", $commands)];
    }

    private function cell(string $value, float $x, float $y, float $width, float $size, string $font = 'F1', float $height = 16): string
    {
        do {
            $lines = $this->wrap($value, $size, $width, $font);
            if (count($lines) * ($size + 1) <= $height) {
                break;
            }
            $size -= 0.5;
        } while ($size >= 5);
        if ($size < 5) {
            throw new ApiException('Los metadatos del formato exceden el espacio del encabezado.', 422, ['formato' => ['Revise la extensión del título, proceso, código y versión.']]);
        }
        $commands = [];
        foreach ($lines as $index => $line) {
            $commands[] = $this->textCommand($line, $size, $x, $y - $index * ($size + 1), $font);
        }

        return implode("\n", $commands);
    }

    private function wrap(string $value, float $size, float $maxWidth, string $font = 'F1'): array
    {
        $lines = [];
        foreach (preg_split('/\R/u', $value) as $paragraph) {
            $line = '';
            foreach (preg_split('/\s+/u', trim($paragraph), -1, PREG_SPLIT_NO_EMPTY) as $word) {
                $candidate = $line === '' ? $word : $line.' '.$word;
                if ($this->width($candidate, $size, $font) <= $maxWidth) {
                    $line = $candidate;

                    continue;
                }
                if ($line !== '' && $this->width($candidate, $size, $font) > $maxWidth) {
                    $lines[] = $line;
                    $line = '';
                }
                if ($line !== '') {
                    $line .= ' ';
                }
                // Partir palabras extensas sin perder caracteres.
                foreach (mb_str_split($word) as $character) {
                    if ($this->width($line.$character, $size, $font) > $maxWidth) {
                        $lines[] = $line;
                        $line = '';
                    }
                    $line .= $character;
                }
            }
            $lines[] = $line;
        }

        return $lines;
    }

    private function width(string $value, float $size, string $font = 'F1'): float
    {
        $metrics = $this->widths[$font === 'F2' ? 'Helvetica-Bold' : 'Helvetica'];
        $width = 0;
        foreach (str_split($this->encode($value)) as $character) {
            $width += $metrics[ord($character)];
        }

        return $width * $size / 1000;
    }

    private function textCommand(string $value, float $size, float $x, float $y, string $font = 'F1'): string
    {
        $encoded = $this->encode($value);
        $encoded = str_replace(['\\', '(', ')'], ['\\\\', '\\(', '\\)'], $encoded);

        // Color explícito: cada texto es negro, independientemente del fondo.
        return '0 0 0 rg BT /'.$font.' '.$size.' Tf '.sprintf('%.3F %.3F', $x, $y).' Td ('.$encoded.') Tj ET';
    }

    private function text(mixed $value): string
    {
        return is_string($value) ? trim($value) : '';
    }

    private function encode(string $value): string
    {
        $encoded = mb_convert_encoding($value, 'Windows-1252', 'UTF-8');
        if (mb_convert_encoding($encoded, 'UTF-8', 'Windows-1252') !== $value) {
            throw new ApiException('Hay caracteres que la fuente del certificado no puede representar.', 422, ['contenido' => ['Revise los caracteres del contenido oficial; no se sustituirán en el PDF.']]);
        }

        return $encoded;
    }

    private function dateText(string $date): string
    {
        $months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
        $parts = explode('-', $date);

        return (int) $parts[2].' de '.$months[(int) $parts[1] - 1].' de '.$parts[0];
    }

    private function shortDate(string $date): string
    {
        $parts = explode('-', $date);

        return count($parts) === 3 ? $parts[2].'/'.$parts[1].'/'.$parts[0] : $date;
    }
}
