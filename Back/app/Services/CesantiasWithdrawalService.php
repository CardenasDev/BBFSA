<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\CertificateRepository;
use App\Repositories\ContractingRepository;
use App\Repositories\EmployeeRepository;
use Carbon\CarbonImmutable;

class CesantiasWithdrawalService
{
    public const FORMAT_KEY = 'CESANTIAS_VIVIENDA';
    public const RENDERER_KEY = 'carta-retiro-cesantias-vivienda';

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

        $modalidad = $this->text($supplied['modalidad'] ?? null);
        if (! in_array($modalidad, ['TOTAL', 'PARCIAL'], true)) {
            $errors['modalidad'] = ['Indique la modalidad del retiro: TOTAL o PARCIAL.'];
        }

        $concepto = $supplied['concepto_retiro'] ?? null;
        if (! is_string($concepto) || trim($concepto) === '' || mb_strlen($concepto) > 200 || preg_match('/[<>\r\n\x00-\x1F\x7F]/u', $concepto)) {
            $errors['concepto_retiro'] = ['Indique el concepto del retiro: texto obligatorio de hasta 200 caracteres, sin HTML ni saltos de línea.'];
        } else {
            $concepto = trim($concepto);
        }

        try {
            $monto = (new SalaryTextFormatter)->format($supplied['monto_retiro'] ?? null);
        } catch (\InvalidArgumentException $e) {
            $errors['monto_retiro'] = ['Indique un monto decimal válido mayor que cero, con hasta dos decimales.'];
            $monto = null;
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

        return [
            'empleado' => $identity,
            'fondo_cesantias' => $fondoCesantias,
            'solicitud' => [
                'modalidad' => $modalidad,
                'concepto_retiro' => $concepto,
                'monto' => $monto,
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

    private function today(): string
    {
        return CarbonImmutable::now('America/Bogota')->toDateString();
    }
}
