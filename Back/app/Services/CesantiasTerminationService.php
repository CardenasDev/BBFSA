<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\CertificateRepository;
use App\Repositories\ContractingRepository;
use App\Repositories\EmployeeRepository;
use Carbon\CarbonImmutable;

class CesantiasTerminationService
{
    public const FORMAT_KEY = 'CESANTIAS_FIN_CONTRATO';
    public const RENDERER_KEY = 'carta-retiro-cesantias-fin-contrato';

    public function __construct(
        private CertificateRepository $certificates,
        private EmployeeRepository $employees,
        private ContractingRepository $contracting,
        private CertificateRenderer $renderer,
    ) {}

    public function available(int $employeeId): array
    {
        $this->existingEmployee($employeeId);

        return array_values(array_map(fn (array $row): array => $this->metadata($row),
            array_filter($this->certificates->listAllFormats($this->today()), fn (array $row): bool => $this->supported($row))));
    }

    public function generateDocument(int $employeeId, array $supplied = []): string
    {
        return $this->renderer->render($this->generationData($employeeId, $supplied));
    }

    public function generationData(int $employeeId, array $supplied = []): array
    {
        $employee = $this->existingEmployee($employeeId);
        $today = $this->today();

        $format = $this->certificates->getFormat(self::FORMAT_KEY, $today);
        if (! $format || ! $this->supported($format)) {
            throw new ApiException('Formato no implementado o no disponible.', 404);
        }

        $errors = [];

        $identity = [
            'id_empleado' => $employeeId,
            'nombre_completo' => trim(($employee['nombres'] ?? '').' '.($employee['apellidos'] ?? '')),
            'tipo_documento' => $this->text($employee['tipo_documento'] ?? null),
            'numero_documento' => $this->text($employee['numero_documento'] ?? null),
        ];
        $identity['nombre_completo'] = $this->text($employee['nombre_completo'] ?? null) ?? ($identity['nombre_completo'] !== '' ? $identity['nombre_completo'] : null);
        foreach (['nombre_completo', 'tipo_documento', 'numero_documento'] as $field) {
            if (empty($identity[$field])) {
                $errors[$field] = ['Dato oficial obligatorio ausente o inválido.'];
            }
        }

        $security = $this->contracting->getSocialSecurity($employeeId) ?? [];
        $fondoCesantias = $this->text($security['fondo_cesantias'] ?? null);
        if (! $fondoCesantias) {
            $errors['fondo_cesantias'] = ['El empleado no tiene fondo de cesantías registrado.'];
        }

        $desde = $this->suppliedDate($supplied, 'fecha_desde', 'Indique la fecha inicial del periodo.', $errors);
        $hasta = $this->suppliedDate($supplied, 'fecha_hasta', 'Indique la fecha final del periodo.', $errors);
        if ($desde && $hasta && $hasta < $desde) {
            $errors['fecha_hasta'] = ['La fecha final del periodo no puede ser anterior a la inicial.'];
        }
        if ($hasta && $hasta > $today) {
            $errors['fecha_hasta'] = ['La fecha final del periodo no puede ser futura.'];
        }

        $nit = $this->text($supplied['nit_empresa'] ?? null);
        if (! $nit || ! preg_match('/^\d{5,12}-\d$/', $nit) || mb_strlen($nit) > 20) {
            $errors['nit_empresa'] = ['Indique el NIT de la empresa con formato de dígitos y dígito de verificación (ejemplo: 900747203-1).'];
        }

        $correo = $this->text($supplied['correo_contacto'] ?? null);
        if (! $correo || mb_strlen($correo) > 150 || ! filter_var($correo, FILTER_VALIDATE_EMAIL)) {
            $errors['correo_contacto'] = ['Indique un correo electrónico de contacto válido de hasta 150 caracteres.'];
        }

        $telefono = $this->text($supplied['telefono_contacto'] ?? null);
        if (! $telefono || mb_strlen($telefono) > 30 || ! preg_match('/^[\d\s\-+]{6,30}$/', $telefono)) {
            $errors['telefono_contacto'] = ['Indique un teléfono de contacto válido de 6 a 30 caracteres (dígitos, espacios, guiones).'];
        }

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

        if ($errors) {
            throw new ApiException('Faltan datos oficiales o configuración para generar el documento.', 422, $errors);
        }

        $profile = $this->contracting->getProfile($employeeId);
        $identity['lugar_expedicion_documento'] = $this->text($profile['lugar_expedicion_documento'] ?? null);

        return [
            'empleado' => $identity,
            'fondo_cesantias' => $fondoCesantias,
            'solicitud' => [
                'fecha_desde' => $desde,
                'fecha_hasta' => $hasta,
                'nit_empresa' => $nit,
                'correo_contacto' => $correo,
                'telefono_contacto' => $telefono,
            ],
            'empresa' => $company,
            'fecha_expedicion' => $today,
            'formato' => $this->metadata($format),
            'firmantes' => $signers,
        ];
    }

    private function existingEmployee(int $id): array
    {
        $employee = $this->employees->find($id);
        if (! $employee) { throw new ApiException('Empleado no encontrado.', 404); }
        return $employee;
    }

    private function suppliedDate(array $supplied, string $field, string $requiredMessage, array &$errors): ?string
    {
        $value = $supplied[$field] ?? null;
        if (! is_string($value) || trim($value) === '') {
            $errors[$field] = [$requiredMessage];
            return null;
        }
        $date = $this->date(trim($value));
        if (! $date) {
            $errors[$field] = ['La fecha debe ser una fecha válida YYYY-MM-DD.'];
            return null;
        }

        return $date;
    }

    private function supported(array $row): bool
    {
        return ($row['clave_formato'] ?? null) === self::FORMAT_KEY
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
