<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\BulkLoadEmployeeRepository;
use DateTimeImmutable;
use DateTimeInterface;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use OpenSpout\Common\Entity\Cell;
use OpenSpout\Common\Entity\Cell\NumericCell;
use OpenSpout\Common\Entity\Row;
use OpenSpout\Common\Entity\Style\Color;
use OpenSpout\Common\Entity\Style\Style;
use OpenSpout\Reader\XLSX\Reader;
use OpenSpout\Writer\AutoFilter;
use OpenSpout\Writer\XLSX\Entity\SheetView;
use OpenSpout\Writer\XLSX\Writer;
use RuntimeException;
use Throwable;
use ZipArchive;

class BulkLoadEmployeeService
{
    public const DATA_SHEET = 'PERSONAL EMPRESA ACTIVOS';

    public const INSTRUCTIONS_SHEET = 'INSTRUCCIONES';

    public const CATALOGS_SHEET = 'CATALOGOS';

    /**
     * Contract compatible with the report delivered to the customer. Do not reorder:
     * only the old full-name column was replaced by NOMBRES and APELLIDOS.
     */
    public const COLUMNS = [
        'N. CARPETA' => 'numero_carpeta',
        'GENERO' => 'genero',
        'TIPO DE DOCUMENTO' => 'tipo_documento',
        'DOCUMENTO' => 'numero_documento',
        'FECHA DE EXPEDICION DEL DOCUMENTO' => 'fecha_expedicion_documento',
        'NOMBRES' => 'nombres',
        'APELLIDOS' => 'apellidos',
        'AREA' => 'area',
        'CARGO' => 'cargo',
        'MES' => 'mes',
        'FECHA DE INGRESO' => 'fecha_ingreso',
        'COPIA DOCUMENTO - SI' => 'copia_documento_si',
        'COPIA DOCUMENTO - NO' => 'copia_documento_no',
        'FECHA DE NACIMIENTO' => 'fecha_nacimiento',
        'CELULAR' => 'telefono',
        'CORREO ELECTRONICO' => 'correo',
        'CONTRATO FIRMADO - SI' => 'contrato_firmado_si',
        'CONTRATO FIRMADO - NO' => 'contrato_firmado_no',
        'TIPO ULTIMO CONTRATO' => 'tipo_contrato',
        'FECHA FINALIZACION CONTRATO' => 'fecha_finalizacion_contrato',
        'SALARIO' => 'salario',
        'ULTIMO EXAMEN MEDICO' => 'ultimo_examen_medico',
        'CONTRATO DE ARRENDAMIENTO' => 'contrato_arrendamiento',
        'DIRECCION VIVIENDA' => 'direccion_residencia',
        'CUANTAS PERSONAS VIVEN' => 'personas_vivienda',
        'LOS MENORES DE EDAD ESTUDIAN' => 'menores_estudian',
        'EPS - SI' => 'eps_si',
        'EPS - NO' => 'eps_no',
        'EPS - CUAL' => 'eps',
        'PENSION - SI' => 'pension_si',
        'PENSION - NO' => 'pension_no',
        'PENSION - CUAL' => 'pension',
        'ARL - SI' => 'arl_si',
        'ARL - NO' => 'arl_no',
        'ARL - CUAL' => 'arl',
        'ARL - CARNET' => 'arl_carnet',
        'CAJA DE COMPENSACION - SI' => 'caja_si',
        'CAJA DE COMPENSACION - NO' => 'caja_no',
        'CAJA DE COMPENSACION - CUAL' => 'caja',
        'CESANTIAS - SI' => 'cesantias_si',
        'CESANTIAS - NO' => 'cesantias_no',
        'CESANTIAS - CUAL' => 'cesantias',
        'BATERIA RIESGO PSICOSOCIAL' => 'bateria_riesgo_psicosocial',
        'ULTIMA ENTREGA DOTACIONES' => 'ultima_entrega_dotaciones',
        'TALLA OVEROL' => 'talla_overol',
        'TALLA PANTALON' => 'talla_pantalon',
        'TALLA CAMISA' => 'talla_camisa',
        'NUMERO CALZADO' => 'talla_calzado',
        'OBSERVACIONES' => 'observaciones_empleado',
        'FINALIZACION CONTRATO' => 'finalizacion_contrato',
        'ESTADO' => 'estado_empleado',
    ];

    /** Exact contract of the 72-column source workbook delivered on 2026-08-10. */
    public const CLIENT_COLUMNS = [
        'N. CARPETA' => 'numero_carpeta',
        'GENERO' => 'genero',
        'TIPO DE DOCUMENTO' => 'tipo_documento',
        'DOCUMENTO' => 'numero_documento',
        'FECHA DE EXPEDICION DEL DOCUMENTO' => 'fecha_expedicion_documento',
        'LUGAR DE EXPEDICION' => 'lugar_expedicion_documento',
        'PRIMER APELLIDO' => 'primer_apellido',
        'SEGUNDO APELLIDO' => 'segundo_apellido',
        'PRIMER NOMBRE' => 'primer_nombre',
        'SEGUNDO NOMBRE' => 'segundo_nombre',
        'AREA' => 'area',
        'CARGO' => 'cargo',
        'FECHA DE INGRESO' => 'fecha_ingreso',
        'COPIA DOCUMENTO - SI' => 'copia_documento_si',
        'COPIA DOCUMENTO - NO' => 'copia_documento_no',
        'FECHA DE NACIMIENTO' => 'fecha_nacimiento',
        'CELULAR' => 'telefono',
        'CORREO ELECTRONICO' => 'correo',
        'CONTRATO FIRMADO - SI' => 'contrato_firmado_si',
        'CONTRATO FIRMADO - NO' => 'contrato_firmado_no',
        'TIPO ULTIMO CONTRATO' => 'tipo_contrato',
        'FECHA FINALIZACION CONTRATO' => 'fecha_finalizacion_contrato',
        'OTROS SI' => 'otros_si',
        'FECHA DEL ULTIMO  OTRO SI' => 'fecha_ultimo_otrosi',
        'SALARIO' => 'salario',
        'FECHA ULTIMA DE VACACIONES' => 'fecha_ultima_vacaciones',
        'ULTIMO EXAMEN MEDICO' => 'ultimo_examen_medico',
        'ULTIMO EXAMEN MEDICO POSINCAPACIDAD' => 'ultimo_examen_medico_posincapacidad',
        'CONTRATO DE ARRENDAMIENTO' => 'contrato_arrendamiento',
        'DIRECCION VIVIENDA' => 'direccion_residencia',
        'CUANTAS PERSONAS VIVEN VIVIENTES' => 'personas_vivienda',
        'LOS MENORES DE EDAD ESTUDIAN' => 'menores_estudian',
        'EPS - SI' => 'eps_si',
        'EPS - NO' => 'eps_no',
        'EPS - CUAL' => 'eps',
        'PENSION - SI' => 'pension_si',
        'PENSION - NO' => 'pension_no',
        'PENSION - CUAL' => 'pension',
        'ARL - SI' => 'arl_si',
        'ARL - NO' => 'arl_no',
        'ARL - CUAL' => 'arl',
        'CAJA DE COMPENSACION - SI' => 'caja_si',
        'CAJA DE COMPENSACION - NO' => 'caja_no',
        'CAJA DE COMPENSACION - CUAL' => 'caja',
        'CESANTIAS - SI' => 'cesantias_si',
        'CESANTIAS - NO' => 'cesantias_no',
        'CESANTIAS - CUAL' => 'cesantias',
        'BATERIA RIESGO PSICOSOCIAL' => 'bateria_riesgo_psicosocial',
        'ULTIMA ENTREGA DOTACIONES' => 'ultima_entrega_dotaciones',
        'UNIFORME 2 P S. GENERAL BLUSA PANTALON' => 'article_size::UNIFORME 2 P S. GENERAL BLUSA PANTALON',
        'PANTALON  JEAN ESTAMPADO BARRO B' => 'article_size::PANTALON  JEAN estampado Barro B',
        'PANTALON DRIL HOMBRE ESTAMPADO BARRO B' => 'article_size::Pantalon Dril Hombre Estampado Barro B',
        'PANTALON DRIL MUJER ESTAMPADO BARRO B' => 'article_size::Pantalon Dril Mujer Estampado Barro B',
        'CAMISA MANGA LARGA  BORDADO BB' => 'article_size::CAMISA MANGA LARGA  BORDADO BB',
        'CAMISA JEAN  BORDADO BB' => 'article_size::CAMISA JEAN  BORDADO BB',
        'CCAMISETA TIPO POLO  BOR BARRO B' => 'article_size::CCamiseta Tipo Polo  Bor Barro B',
        'BATA MUJER TIPO LABO DRIL BOR BARRO B' => 'article_size::Bata Mujer Tipo Labo Dril Bor BARRO B',
        'BATA HOMBRE TIPO LABO DRIL BOR BARRO B' => 'article_size::Bata Hombre Tipo Labo Dril Bor BARRO B',
        'OVEROL DOS PIEZAS ESTAMPAD HOMBR BARRO' => 'article_size::Overol dos piezas Estampad Hombr BARRO',
        'OVEROL DOS PIEZAS ESTAMPAD MUJER BARRO B' => 'article_size::Overol dos piezas Estampad Mujer BARRO B',
        'OVEROL 1P  ESTAMPADO  BARRO B' => 'article_size::Overol 1P  Estampado  BARRO B',
        'OVEROL 1P C/REFLE ESTAMPADO BRIG BARRO B' => 'article_size::Overol 1P C/Refle Estampado Brig BARRO B',
        'OVEROL TIPO TYVEK COLTEJER BARRO B' => 'article_size::Overol Tipo Tyvek Coltejer BARRO B',
        'TRAJE DE CUARTO FRIO' => 'article_size::TRAJE DE CUARTO FRIO',
        'BOTA PVC MACHA ALTA' => 'article_size::BOTA PVC MACHA ALTA',
        'BOTA PVC MACHITA' => 'article_size::BOTA PVC MACHITA',
        'BOTA CUERO LISO SP' => 'article_size::BOTA CUERO LISO SP',
        'ZUECO' => 'article_size::Zueco',
        'BOTA CUERO MICROPIEL RH-PP-DE' => 'article_size::Bota Cuero Micropiel RH-PP-DE',
        'OBSERVACIONES' => 'observaciones_empleado',
        'FINALIZACION CONTRATO' => 'finalizacion_contrato',
        'ESTADO' => 'estado_empleado',
    ];

    public const LEGACY_COLUMNS = [
        'N. CARPETA', 'GENERO', 'TIPO DE DOCUMENTO', 'DOCUMENTO',
        'FECHA DE EXPEDICION DEL DOCUMENTO', 'APELLIDO Y NOMBRE COMPLETO', 'AREA',
        'CARGO', 'MES', 'FECHA DE INGRESO', 'COPIA DOCUMENTO - SI',
        'COPIA DOCUMENTO - NO', 'FECHA DE NACIMIENTO', 'CELULAR',
        'CORREO ELECTRONICO', 'CONTRATO FIRMADO - SI', 'CONTRATO FIRMADO - NO',
        'TIPO ULTIMO CONTRATO', 'FECHA FINALIZACION CONTRATO', 'SALARIO',
        'ULTIMO EXAMEN MEDICO', 'CONTRATO DE ARRENDAMIENTO', 'DIRECCION VIVIENDA',
        'CUANTAS PERSONAS VIVEN', 'LOS MENORES DE EDAD ESTUDIAN', 'EPS - SI',
        'EPS - NO', 'EPS - CUAL', 'PENSION - SI', 'PENSION - NO', 'PENSION - CUAL',
        'ARL - SI', 'ARL - NO', 'ARL - CUAL', 'ARL - CARNET',
        'CAJA DE COMPENSACION - SI', 'CAJA DE COMPENSACION - NO',
        'CAJA DE COMPENSACION - CUAL', 'CESANTIAS - SI', 'CESANTIAS - NO',
        'CESANTIAS - CUAL', 'BATERIA RIESGO PSICOSOCIAL', 'ULTIMA ENTREGA DOTACIONES',
        'TALLA OVEROL', 'TALLA PANTALON', 'TALLA CAMISA', 'NUMERO CALZADO',
        'OBSERVACIONES', 'FINALIZACION CONTRATO', 'ESTADO',
    ];

    private const REQUIRED = ['tipo_documento', 'numero_documento', 'nombres', 'apellidos'];

    private const DATES = ['fecha_expedicion_documento', 'fecha_ingreso', 'fecha_nacimiento'];

    private const SIZE_FIELDS = [
        'talla_overol' => 'Overol',
        'talla_pantalon' => 'Pantalón',
        'talla_camisa' => 'Camisa',
        'talla_calzado' => 'Calzado',
    ];

    private const INFORMATIONAL = [
        'copia_documento_si', 'copia_documento_no',
        'contrato_firmado_si', 'contrato_firmado_no',
        'fecha_finalizacion_contrato', 'salario', 'ultimo_examen_medico',
        'contrato_arrendamiento', 'arl_carnet', 'bateria_riesgo_psicosocial',
        'ultima_entrega_dotaciones', 'finalizacion_contrato',
        'lugar_expedicion_documento', 'otros_si', 'fecha_ultimo_otrosi',
        'fecha_ultima_vacaciones', 'ultimo_examen_medico_posincapacidad',
    ];

    private const MONTHS = [
        1 => 'ENERO', 2 => 'FEBRERO', 3 => 'MARZO', 4 => 'ABRIL',
        5 => 'MAYO', 6 => 'JUNIO', 7 => 'JULIO', 8 => 'AGOSTO',
        9 => 'SEPTIEMBRE', 10 => 'OCTUBRE', 11 => 'NOVIEMBRE', 12 => 'DICIEMBRE',
    ];

    private const CATALOG_ALIASES = [
        'tipo_documento' => [
            'PERMISO DE PROTECCION DE PERMANENCIA' => 'PERMISO POR PROTECCION TEMPORAL - PPT',
        ],
        'tipo_contrato' => [
            'CONTRATO A TERMINO INDEFINIDO' => 'INDEFINIDO',
            'CONTRATO A TERMINO FIJO INFERIOR A UN ANO' => 'FIJO',
        ],
        'cargo' => [
            'SERVICIOS GENERAL' => 'SERVICIOS GENERALES',
        ],
        'eps' => [
            'ASOCIACION MUTUAL SER EMPRESA SOLIDARIA DE SALUD, ENTIDAD PROMOTORA DE SALUD. MU' => 'MUTUAL SER EPS',
            'COMPENSAR ENTIDAD PROMOTORA DE SALUD' => 'COMPENSAR EPS',
            'COOSALUD ENTIDAD PROMOTORA DE SALUD SA' => 'COOSALUD EPS',
            'E.P.S. SANITAS' => 'SANITAS EPS',
            'E.P.S. SURA' => 'SURA EPS',
            'FAMISANAR' => 'FAMISANAR EPS',
            'SALUD TOTAL S.A.' => 'SALUD TOTAL EPS',
        ],
        'pension' => [
            'PROTECCCION' => 'PROTECCION',
        ],
        'arl' => [
            'POSITIVA -ARL' => 'ARL POSITIVA',
            'POSITIVA- ARL' => 'ARL POSITIVA',
        ],
        'caja' => [
            'CAJA COLOMBIANA DE SUBCIDIO FAMILIAR COLSUBSIDIO' => 'COLSUBSIDIO',
        ],
        'cesantias' => [
            'PORVENIR' => 'PORVENIR CESANTIAS',
        ],
    ];

    public function __construct(
        private readonly BulkLoadEmployeeRepository $repository,
        private readonly AuditService $audit,
    ) {}

    /** @return array{path:string,filename:string} */
    public function template(): array
    {
        $path = tempnam(sys_get_temp_dir(), 'bbf_carga_empleados_');
        if ($path === false) {
            throw new RuntimeException('No fue posible crear la plantilla temporal.');
        }

        try {
            $this->writeTemplate($path, $this->repository->catalogs());
        } catch (Throwable $exception) {
            @unlink($path);
            throw $exception;
        }

        return ['path' => $path, 'filename' => 'plantilla_carga_masiva_empleados.xlsx'];
    }

    public function validate(UploadedFile $file): array
    {
        $this->assertSafeWorkbook($file);

        return $this->validateRows($this->readWorkbook($file->getRealPath()));
    }

    public function publicResult(array $result): array
    {
        unset($result['_rows']);

        return $result;
    }

    public function import(UploadedFile $file, int $actorId, array $context): array
    {
        $result = $this->validate($file);
        if ($result['invalid'] > 0) {
            throw new ApiException('El archivo contiene errores y no fue importado.', 422, [
                'validation' => $this->publicResult($result),
            ]);
        }

        $safeName = Str::limit(pathinfo($file->getClientOriginalName(), PATHINFO_FILENAME), 80, '').'.xlsx';
        try {
            $created = DB::transaction(function () use ($result, $actorId): int {
                foreach ($result['_rows'] as $row) {
                    $employeeId = $this->repository->createEmployee($row);
                    if ($employeeId < 1) {
                        throw new RuntimeException('No fue posible crear uno de los empleados.');
                    }

                    if ($this->hasAny($row, [
                        'numero_carpeta', 'genero', 'fecha_expedicion_documento',
                        'fecha_nacimiento', 'direccion_residencia', 'personas_vivienda',
                        'menores_estudian',
                    ])) {
                        $this->repository->saveProfile($employeeId, $row);
                    }
                    if ($this->hasAny($row, ['id_eps', 'id_arl', 'id_pension', 'id_cesantias', 'id_caja'])) {
                        $this->repository->saveSocialSecurity($employeeId, $row);
                    }
                    foreach ($row['_sizes'] as $size) {
                        $this->repository->saveSize($employeeId, $size['type_id'], $size['id'], $actorId);
                    }
                    foreach ($row['_article_sizes'] as $size) {
                        $this->repository->saveArticleSize(
                            $employeeId,
                            $size['article_id'],
                            $size['id'],
                            $actorId,
                        );
                    }
                }

                return count($result['_rows']);
            });
        } catch (Throwable $exception) {
            $this->audit->record($actorId, 'EMPLEADOS', 'CARGA_MASIVA_IMPORTAR', 'CARGA_MASIVA', null, null, [
                'cantidad_solicitada' => $result['total'],
                'archivo' => $safeName,
                'resultado' => 'FALLIDO',
            ], $context);
            throw $exception;
        }

        $this->audit->record($actorId, 'EMPLEADOS', 'CARGA_MASIVA_IMPORTAR', 'CARGA_MASIVA', null, null, [
            'cantidad_creada' => $created,
            'archivo' => $safeName,
            'resultado' => 'EXITOSO',
        ], $context);

        return ['created' => $created, 'total' => $created];
    }

    private function validateRows(array $source): array
    {
        $lookups = $this->lookups($this->repository->catalogs());
        $errors = $source['errors'];
        $warnings = [];
        $validRows = [];
        $documents = [];
        $clientInformationalWarningAdded = false;

        foreach ($source['rows'] as $entry) {
            $rowNumber = $entry['row'];
            $row = $this->normalizeRow($entry['values']);
            $rowErrors = [];
            $rowWarnings = [];

            foreach ($entry['numeric_identifiers'] as $field => $numericValue) {
                if (! $this->normalizeSafeNumericIdentifier($numericValue, $normalizedIdentifier)) {
                    $rowErrors[] = $this->issue(
                        $rowNumber,
                        $field,
                        'Excel pudo alterar este identificador. Recupéralo del archivo fuente y pégalo como texto; un valor numérico debe ser entero, no negativo, finito y tener máximo 15 dígitos.'
                    );

                    continue;
                }

                $row[$field] = $normalizedIdentifier;
                if ($field === 'numero_documento') {
                    $rowWarnings[] = $this->issue(
                        $rowNumber,
                        $field,
                        'El documento llegó como número y se convertirá a texto. Verifica que no tuviera ceros iniciales.'
                    );
                }
            }

            foreach (self::REQUIRED as $field) {
                if ($row[$field] === null) {
                    $rowErrors[] = $this->issue($rowNumber, $field, 'El campo es obligatorio.');
                }
            }
            foreach ($entry['formula_fields'] as $field) {
                $rowErrors[] = $this->issue($rowNumber, $field, 'No se permiten fórmulas en la plantilla.');
            }

            foreach ([
                'tipo_documento' => ['document_types', 'id_tipo_documento'],
                'area' => ['areas', 'id_area'],
                'cargo' => ['positions', 'id_cargo'],
                'tipo_contrato' => ['contract_types', 'id_tipo_contrato'],
            ] as $field => [$catalog, $idField]) {
                $this->resolve($row, $field, $idField, $lookups[$catalog] ?? [], $rowNumber, $rowErrors);
            }

            foreach ([
                'eps' => 'EPS',
                'pension' => 'PENSION',
                'arl' => 'ARL',
                'caja' => 'CAJA_COMPENSACION',
                'cesantias' => 'CESANTIAS',
            ] as $field => $type) {
                $this->validateSocialPair($row, $field, $rowNumber, $rowErrors, $rowWarnings);
                $this->resolve(
                    $row,
                    $field,
                    'id_'.$field,
                    $lookups['social_security'][$type] ?? [],
                    $rowNumber,
                    $rowErrors
                );
            }

            $row['_sizes'] = [];
            foreach (self::SIZE_FIELDS as $field => $type) {
                if ($row[$field] === null) {
                    continue;
                }
                $matches = $lookups['sizes'][$type][$this->key($row[$field])] ?? [];
                if (count($matches) !== 1) {
                    $rowErrors[] = $this->issue(
                        $rowNumber,
                        $field,
                        count($matches) ? 'La talla es ambigua.' : 'La talla no existe o no está activa para este tipo de dotación.'
                    );
                } else {
                    $row['_sizes'][] = $matches[0];
                }
            }

            $row['_article_sizes'] = [];
            $articleIds = [];
            foreach ($row as $field => $value) {
                if (! str_starts_with($field, 'article_size::') || $value === null) {
                    continue;
                }

                $header = substr($field, strlen('article_size::'));
                $aliases = $lookups['article_aliases'][$this->key($header)] ?? [];
                if (count($aliases) !== 1) {
                    $rowErrors[] = $this->issue(
                        $rowNumber,
                        $header,
                        count($aliases) ? 'La equivalencia del artículo es ambigua.' : 'El encabezado no tiene un artículo activo configurado para el cargue.'
                    );
                    continue;
                }

                $article = $aliases[0];
                if (isset($articleIds[$article['article_id']])) {
                    $rowErrors[] = $this->issue(
                        $rowNumber,
                        $header,
                        'El mismo artículo tiene más de una talla diligenciada en esta fila.'
                    );
                    continue;
                }

                $matches = $lookups['sizes'][$article['type']][$this->key($value)] ?? [];
                if (count($matches) !== 1) {
                    $rowErrors[] = $this->issue(
                        $rowNumber,
                        $header,
                        count($matches) ? 'La talla es ambigua para la familia del artículo.' : 'La talla no existe o no está activa para la familia del artículo.'
                    );
                    continue;
                }

                $articleIds[$article['article_id']] = true;
                $row['_article_sizes'][] = array_merge($matches[0], [
                    'article_id' => $article['article_id'],
                    'article_code' => $article['code'],
                    'article' => $article['article'],
                    'header' => $header,
                ]);
            }

            foreach (self::DATES as $field) {
                if ($row[$field] !== null && ! $this->parseDate($row[$field], $parsed)) {
                    $rowErrors[] = $this->issue(
                        $rowNumber,
                        $field,
                        'Fecha inválida. Usa DD/MM/AAAA, AAAA-MM-DD o una fecha real de Excel.'
                    );
                } elseif ($row[$field] !== null) {
                    $row[$field] = $parsed;
                }
            }
            if ($row['mes'] === null && $row['fecha_ingreso'] !== null && $this->validDateString($row['fecha_ingreso'])) {
                $row['mes'] = self::MONTHS[(int) substr($row['fecha_ingreso'], 5, 2)];
            }
            if ($row['mes'] !== null && $row['fecha_ingreso'] !== null && $this->validDateString($row['fecha_ingreso'])) {
                $month = (int) substr($row['fecha_ingreso'], 5, 2);
                if (! $this->monthMatches($row['mes'], $month)) {
                    $rowErrors[] = $this->issue(
                        $rowNumber,
                        'mes',
                        'MES debe coincidir con FECHA DE INGRESO ('.self::MONTHS[$month].').'
                    );
                }
            }

            if ($row['menores_estudian'] !== null) {
                $row['menores_estudian'] = match ($this->key($row['menores_estudian'])) {
                    'SI', '1', 'X', 'OK' => 1,
                    'NO', '0' => 0,
                    default => $row['menores_estudian'],
                };
            }

            foreach (self::INFORMATIONAL as $field) {
                if (($row[$field] ?? null) !== null) {
                    if ($source['format'] === 'CLIENTE_72') {
                        if (! $clientInformationalWarningAdded) {
                            $warnings[] = $this->issue(
                                1,
                                '_archivo',
                                'El formato ampliado contiene datos contractuales e históricos informativos. Se importarán empleados, perfil, seguridad social y tallas; no se crearán contratos, documentos, exámenes, vacaciones ni entregas históricas.'
                            );
                            $clientInformationalWarningAdded = true;
                        }
                        continue;
                    }
                    $rowWarnings[] = $this->issue(
                        $rowNumber,
                        $field,
                        'Dato informativo conservado por compatibilidad; no se persiste ni crea documentos o históricos.'
                    );
                }
            }

            $validator = Validator::make($row, [
                'numero_carpeta' => ['nullable', 'string', 'max:50'],
                'genero' => ['nullable', 'in:M,F'],
                'numero_documento' => ['nullable', 'string', 'max:50'],
                'nombres' => ['nullable', 'string', 'max:150'],
                'apellidos' => ['nullable', 'string', 'max:150'],
                'telefono' => ['nullable', 'string', 'max:50'],
                'correo' => ['nullable', 'email:rfc', 'max:150'],
                'direccion_residencia' => ['nullable', 'string', 'max:250'],
                'personas_vivienda' => ['nullable', 'integer', 'min:0'],
                'menores_estudian' => ['nullable', 'in:0,1'],
                'observaciones_empleado' => ['nullable', 'string'],
                'estado_empleado' => [
                    'nullable',
                    'in:ACTIVO,RETIRADO,SUSPENDIDO,INCAPACITADO,EN_PROCESO_RETIRO',
                ],
            ]);
            foreach ($validator->errors()->messages() as $field => $messages) {
                foreach ($messages as $message) {
                    $rowErrors[] = $this->issue($rowNumber, $field, $message);
                }
            }

            if ($row['personas_vivienda'] !== null && filter_var($row['personas_vivienda'], FILTER_VALIDATE_INT) !== false) {
                $row['personas_vivienda'] = (int) $row['personas_vivienda'];
            }
            if ($row['numero_documento'] !== null) {
                $documents[$row['numero_documento']][] = $rowNumber;
            }

            array_push($warnings, ...$rowWarnings);
            if ($rowErrors === []) {
                $validRows[$rowNumber] = $row;
            } else {
                array_push($errors, ...$rowErrors);
            }
        }

        foreach ($documents as $document => $rows) {
            if (count($rows) > 1) {
                foreach ($rows as $rowNumber) {
                    $errors[] = $this->issue($rowNumber, 'numero_documento', 'El documento está duplicado dentro del archivo.');
                    unset($validRows[$rowNumber]);
                }
            }
        }
        foreach ($this->repository->existingDocuments(array_keys($documents)) as $document) {
            foreach ($documents[(string) $document] ?? [] as $rowNumber) {
                $errors[] = $this->issue($rowNumber, 'numero_documento', 'Ya existe un empleado con este documento.');
                unset($validRows[$rowNumber]);
            }
        }

        $invalidRows = array_unique(array_column($errors, 'row'));
        $total = count($source['rows']);

        return [
            'format' => $source['format'],
            'total' => $total,
            'valid' => max(0, $total - count($invalidRows)),
            'invalid' => count($invalidRows),
            'article_sizes' => array_sum(array_map(
                fn (array $row) => count($row['_article_sizes'] ?? []),
                $validRows,
            )),
            'warnings' => array_values($warnings),
            'errors' => array_values($errors),
            '_rows' => array_values($validRows),
        ];
    }

    private function readWorkbook(string $path): array
    {
        $reader = new Reader;
        $reader->open($path);
        $rows = [];
        $errors = [];
        $found = [];
        $format = null;

        try {
            foreach ($reader->getSheetIterator() as $sheet) {
                $name = strtoupper(trim($sheet->getName()));
                $found[] = $name;
                if ($name !== self::DATA_SHEET) {
                    continue;
                }

                $header = null;
                foreach ($sheet->getRowIterator() as $index => $excelRow) {
                    $cells = $excelRow->getCells();
                    if ($header === null) {
                        $header = array_map(fn (Cell $cell) => strtoupper(trim((string) $cell->getValue())), $cells);
                        $format = $this->assertHeaders($header);
                        continue;
                    }
                    if ($index > config('bulk_load.max_rows', 1000) + 1) {
                        throw new ApiException('El archivo supera el máximo de filas permitido.', 422);
                    }
                    if ($this->emptyCells($cells)) {
                        continue;
                    }

                    $values = [];
                    $formulaFields = [];
                    $columns = $format === 'CLIENTE_72' ? self::CLIENT_COLUMNS : self::COLUMNS;
                    foreach ($columns as $heading => $field) {
                        $position = array_search($heading, array_keys($columns), true);
                        $cell = $cells[$position] ?? null;
                        if ($cell && str_contains($cell::class, 'FormulaCell')) {
                            $formulaFields[] = $field;
                        }
                        $values[$field] = $cell?->getValue();
                    }
                    $numericIdentifiers = [];
                    foreach ($columns as $positionHeading => $field) {
                        if (! in_array($field, ['numero_carpeta', 'numero_documento', 'telefono'], true)) {
                            continue;
                        }
                        $position = array_search($positionHeading, array_keys($columns), true);
                        $identifierCell = $cells[$position] ?? null;
                        if ($identifierCell instanceof NumericCell) {
                            $numericIdentifiers[$field] = $identifierCell->getValue();
                        }
                    }
                    $rows[] = [
                        'row' => $index,
                        'values' => $values,
                        'formula_fields' => $formulaFields,
                        'numeric_identifiers' => $numericIdentifiers,
                    ];
                }
            }
        } finally {
            $reader->close();
        }

        $allowedSheets = $format === 'CLIENTE_72'
            ? [self::DATA_SHEET]
            : [self::DATA_SHEET, self::INSTRUCTIONS_SHEET, self::CATALOGS_SHEET];
        if (array_diff($found, $allowedSheets) !== []) {
            throw new ApiException('El XLSX contiene hojas desconocidas. Usa la plantilla oficial sin agregar hojas.', 422);
        }
        if (! in_array(self::DATA_SHEET, $found, true)
            || ($format !== 'CLIENTE_72' && ! in_array(self::INSTRUCTIONS_SHEET, $found, true))) {
            throw new ApiException(
                'El XLSX debe contener las hojas PERSONAL EMPRESA ACTIVOS e INSTRUCCIONES.',
                422
            );
        }
        if ($rows === []) {
            $errors[] = $this->issue(2, '_archivo', 'El archivo no contiene filas de empleados.');
        }

        return ['format' => $format ?? 'OFICIAL_51', 'rows' => $rows, 'errors' => $errors];
    }

    private function assertHeaders(array $headers): string
    {
        $headers = array_values(array_filter($headers, fn ($value) => $value !== ''));
        if ($headers === self::LEGACY_COLUMNS) {
            throw new ApiException(
                'El archivo corresponde al formato anterior de 50 columnas. Separa únicamente “APELLIDO Y NOMBRE COMPLETO” en las columnas consecutivas NOMBRES y APELLIDOS; no reordenes ni cambies las demás columnas.',
                422
            );
        }

        if ($headers === array_keys(self::CLIENT_COLUMNS)) {
            return 'CLIENTE_72';
        }

        $duplicates = array_diff_assoc($headers, array_unique($headers));
        $expected = array_keys(self::COLUMNS);
        if ($duplicates !== []) {
            throw new ApiException('La hoja PERSONAL EMPRESA ACTIVOS contiene encabezados duplicados.', 422);
        }
        if ($headers !== $expected) {
            throw new ApiException(
                'Los encabezados de PERSONAL EMPRESA ACTIVOS no corresponden a las 51 columnas oficiales o están en otro orden.',
                422,
                [
                    'missing_headers' => array_values(array_diff($expected, $headers)),
                    'unknown_headers' => array_values(array_diff($headers, $expected)),
                ]
            );
        }

        return 'OFICIAL_51';
    }

    private function assertSafeWorkbook(UploadedFile $file): void
    {
        $path = $file->getRealPath();
        $handle = fopen($path, 'rb');
        $signature = $handle ? fread($handle, 4) : false;
        if ($handle) {
            fclose($handle);
        }
        if ($signature === false || ! str_starts_with($signature, "PK\x03\x04")) {
            throw new ApiException('El archivo no tiene la firma de un XLSX válido.', 422);
        }

        $zip = new ZipArchive;
        if (
            $zip->open($path) !== true
            || $zip->locateName('[Content_Types].xml') === false
            || $zip->locateName('xl/workbook.xml') === false
        ) {
            throw new ApiException('La estructura interna del XLSX no es válida.', 422);
        }
        try {
            for ($index = 0; $index < $zip->numFiles; $index++) {
                $name = strtolower((string) $zip->getNameIndex($index));
                if (str_ends_with($name, 'vbaproject.bin') || str_starts_with($name, 'xl/externallinks/')) {
                    throw new ApiException('No se permiten macros ni vínculos externos en el archivo.', 422);
                }
            }
        } finally {
            $zip->close();
        }
    }

    private function writeTemplate(string $path, array $catalogs): void
    {
        $header = (new Style)
            ->setFontBold()
            ->setFontColor(Color::BLACK)
            ->setBackgroundColor('E7E6E6')
            ->setShouldWrapText();
        $dateStyle = (new Style)->setFormat('dd/mm/yyyy');
        $textStyle = (new Style)->setFormat('@');
        $section = (new Style)->setFontBold()->setBackgroundColor('D9EAF7');
        $writer = new Writer;
        $writer->openToFile($path);

        try {
            $data = $writer->getCurrentSheet();
            $data->setName(self::DATA_SHEET);
            $data->setSheetView((new SheetView)->setFreezeRow(2));
            $data->setAutoFilter(new AutoFilter(0, 1, count(self::COLUMNS) - 1, 2));
            $this->setDataColumnWidths($data);
            $writer->addRow(Row::fromValues(array_keys(self::COLUMNS), $header));
            $writer->addRow(new Row($this->exampleCells($catalogs, $dateStyle, $textStyle)));

            $instructions = $writer->addNewSheetAndMakeItCurrent();
            $instructions->setName(self::INSTRUCTIONS_SHEET);
            $instructions->setColumnWidth(32, 1);
            $instructions->setColumnWidth(105, 2);
            $instructions->setSheetView((new SheetView)->setFreezeRow(2));
            $writer->addRow(Row::fromValues(['TEMA', 'INSTRUCCIÓN'], $header));
            foreach ($this->instructions() as $item) {
                $writer->addRow(Row::fromValues($item));
            }

            $sheet = $writer->addNewSheetAndMakeItCurrent();
            $sheet->setName(self::CATALOGS_SHEET);
            $sheet->setColumnWidthForRange(32, 1, 3);
            $sheet->setSheetView((new SheetView)->setFreezeRow(2));
            $writer->addRow(Row::fromValues(['CATÁLOGO', 'TIPO', 'VALOR VIGENTE'], $header));
            foreach ($this->catalogRows($catalogs) as $row) {
                $writer->addRow(Row::fromValues($row, $row[0] !== '' ? $section : null));
            }
        } finally {
            $writer->close();
        }
    }

    private function normalizeRow(array $row): array
    {
        $row = array_replace(array_fill_keys(array_values(self::COLUMNS), null), $row);
        foreach ($row as $field => $value) {
            if ($value instanceof DateTimeInterface) {
                continue;
            }
            if ($value === null) {
                continue;
            }
            $value = preg_replace('/\s+/u', ' ', trim((string) $value));
            $row[$field] = $value === '' ? null : $value;
        }

        if (($row['primer_nombre'] ?? null) !== null || ($row['primer_apellido'] ?? null) !== null) {
            $row['nombres'] = $this->joinNameParts([
                $row['primer_nombre'] ?? null,
                $row['segundo_nombre'] ?? null,
            ]);
            $row['apellidos'] = $this->joinNameParts([
                $row['primer_apellido'] ?? null,
                $row['segundo_apellido'] ?? null,
            ]);
        }
        foreach (['genero', 'estado_empleado'] as $field) {
            $row[$field] = $row[$field] === null ? null : $this->key($row[$field]);
        }
        foreach (['eps', 'pension', 'arl', 'caja', 'cesantias'] as $field) {
            if (($row[$field] ?? null) !== null && $this->key($row[$field]) === 'NO APLICA') {
                $row[$field] = null;
            }
        }

        return $row;
    }

    private function joinNameParts(array $parts): ?string
    {
        $value = implode(' ', array_filter($parts, fn ($part) => $part !== null && $part !== ''));

        return $value === '' ? null : $value;
    }

    private function lookups(array $catalogs): array
    {
        $result = [];
        foreach (['document_types', 'areas', 'positions', 'contract_types'] as $name) {
            foreach ($catalogs[$name] as $row) {
                $result[$name][$this->key($row['name'])][] = $row;
            }
        }
        foreach ($catalogs['social_security'] as $row) {
            $result['social_security'][$row['type']][$this->key($row['name'])][] = $row;
        }
        foreach ($catalogs['dotation_sizes'] as $row) {
            $result['sizes'][$row['type']][$this->key($row['name'])][] = $row;
        }
        foreach ($catalogs['dotation_article_aliases'] ?? [] as $row) {
            $result['article_aliases'][$this->key($row['header'])][] = $row;
        }

        return $result;
    }

    private function resolve(
        array &$row,
        string $field,
        string $idField,
        array $lookup,
        int $rowNumber,
        array &$errors
    ): void {
        $row[$idField] = null;
        if ($row[$field] === null) {
            return;
        }
        $key = $this->key($row[$field]);
        $key = self::CATALOG_ALIASES[$field][$key] ?? $key;
        $matches = $lookup[$key] ?? [];
        if (count($matches) !== 1) {
            $errors[] = $this->issue(
                $rowNumber,
                $field,
                count($matches)
                    ? 'El valor coincide con más de un catálogo vigente.'
                    : 'El valor no existe o no está activo en el catálogo.'
            );
        } else {
            $row[$idField] = (int) $matches[0]['id'];
        }
    }

    private function validateSocialPair(
        array $row,
        string $field,
        int $rowNumber,
        array &$errors,
        array &$warnings
    ): void {
        $yes = $this->indicatorMarked($row[$field.'_si']);
        $noValue = $row[$field.'_no'];
        $no = $this->indicatorMarked($noValue)
            || in_array($this->key($noValue), ['NO', 'NO APLICA'], true);
        if ($yes && $no) {
            $errors[] = $this->issue($rowNumber, $field, 'Las columnas SI y NO no pueden estar marcadas al mismo tiempo.');
        }
        if ($no && $row[$field] !== null) {
            $errors[] = $this->issue($rowNumber, $field, 'La columna NO está marcada, pero también se diligenció la entidad CUAL.');
        }
        if ($yes && $row[$field] === null) {
            $warnings[] = $this->issue(
                $rowNumber,
                $field,
                'La columna SI está marcada, pero CUAL está vacía; no se asociará una entidad.'
            );
        }
    }

    private function indicatorMarked(mixed $value): bool
    {
        if ($value === null || trim((string) $value) === '') {
            return false;
        }

        return in_array($this->key($value), ['OK', 'X', 'SI', '1'], true);
    }

    private function key(mixed $value): string
    {
        return strtoupper(Str::ascii(preg_replace('/\s+/u', ' ', trim((string) $value))));
    }

    private function normalizeSafeNumericIdentifier(mixed $value, ?string &$normalized): bool
    {
        if (! is_int($value) && ! is_float($value)) {
            return false;
        }

        $number = (float) $value;
        if (! is_finite($number) || $number < 0 || floor($number) !== $number || $number > 999999999999999) {
            return false;
        }

        $normalized = is_int($value) ? (string) $value : sprintf('%.0f', $number);

        return preg_match('/^\d{1,15}$/', $normalized) === 1;
    }

    private function parseDate(mixed $value, ?string &$parsed): bool
    {
        if ($value instanceof DateTimeInterface) {
            $parsed = $value->format('Y-m-d');

            return true;
        }
        if (is_int($value) || is_float($value) || (is_string($value) && preg_match('/^\d+(?:\.\d+)?$/', $value))) {
            $serial = (float) $value;
            if ($serial >= 1 && $serial < 2958466) {
                $date = (new DateTimeImmutable('1899-12-30'))->modify('+'.(int) floor($serial).' days');
                $parsed = $date->format('Y-m-d');

                return true;
            }
        }

        foreach (['!Y-m-d', '!d/m/Y', '!j/n/Y', '!Y-m-d H:i:s', '!d/m/Y H:i:s'] as $format) {
            $date = DateTimeImmutable::createFromFormat($format, (string) $value);
            $dateErrors = DateTimeImmutable::getLastErrors();
            if ($date !== false && ($dateErrors === false || (! $dateErrors['warning_count'] && ! $dateErrors['error_count']))) {
                $parsed = $date->format('Y-m-d');

                return true;
            }
        }

        return false;
    }

    private function validDateString(mixed $value): bool
    {
        return is_string($value) && preg_match('/^\d{4}-\d{2}-\d{2}$/', $value) === 1;
    }

    private function monthMatches(mixed $value, int $month): bool
    {
        $normalized = $this->key($value);

        return $normalized === self::MONTHS[$month]
            || $normalized === (string) $month
            || $normalized === str_pad((string) $month, 2, '0', STR_PAD_LEFT);
    }

    private function issue(int $row, string $field, string $message): array
    {
        return ['row' => $row, 'field' => $field, 'message' => $message];
    }

    private function hasAny(array $row, array $fields): bool
    {
        return collect($fields)->contains(fn ($field) => ($row[$field] ?? null) !== null);
    }

    private function emptyCells(array $cells): bool
    {
        return collect($cells)->every(
            fn (Cell $cell) => $cell->getValue() === null || trim((string) $cell->getValue()) === ''
        );
    }

    private function exampleCells(array $catalogs, Style $dateStyle, Style $textStyle): array
    {
        $values = array_fill_keys(array_values(self::COLUMNS), null);
        $values = array_replace($values, [
            'numero_carpeta' => '1',
            'genero' => 'F',
            'tipo_documento' => $catalogs['document_types'][0]['name'] ?? null,
            'numero_documento' => '0012345678',
            'fecha_expedicion_documento' => new DateTimeImmutable('2020-06-15'),
            'nombres' => 'ANA MARÍA',
            'apellidos' => 'PÉREZ GÓMEZ',
            'area' => $catalogs['areas'][0]['name'] ?? null,
            'cargo' => $catalogs['positions'][0]['name'] ?? null,
            'mes' => 'AGOSTO',
            'fecha_ingreso' => new DateTimeImmutable('2026-08-01'),
            'fecha_nacimiento' => new DateTimeImmutable('1995-05-20'),
            'telefono' => '3001234567',
            'correo' => 'ana@example.com',
            'tipo_contrato' => $catalogs['contract_types'][0]['name'] ?? null,
            'direccion_residencia' => 'Calle 10 # 20-30',
            'personas_vivienda' => 3,
            'menores_estudian' => 'SI',
            'estado_empleado' => 'ACTIVO',
        ]);

        $textFields = ['numero_carpeta', 'numero_documento', 'telefono'];
        $dateFields = self::DATES;
        $cells = [];
        foreach ($values as $field => $value) {
            $style = in_array($field, $textFields, true)
                ? $textStyle
                : (in_array($field, $dateFields, true) ? $dateStyle : null);
            $cells[] = Cell::fromValue($value, $style);
        }

        return $cells;
    }

    private function instructions(): array
    {
        return [
            ['Compatibilidad', 'La hoja conserva exactamente el formato entregado al cliente. El único cambio es reemplazar APELLIDO Y NOMBRE COMPLETO por dos columnas consecutivas: NOMBRES y APELLIDOS. No reordenes ni renombres las demás columnas.'],
            ['Obligatorios', 'TIPO DE DOCUMENTO, DOCUMENTO, NOMBRES y APELLIDOS. No se intenta dividir automáticamente el nombre completo.'],
            ['Texto', 'N. CARPETA, DOCUMENTO y CELULAR deben mantenerse como texto para conservar ceros iniciales. Al copiar y pegar, un DOCUMENTO numérico entero de hasta 15 dígitos puede convertirse de forma segura a texto; verifica la advertencia. Identificadores largos o con ceros iniciales deben conservarse como texto desde el archivo fuente.'],
            ['Fechas', 'Usa una fecha real de Excel visible como DD/MM/AAAA; también se aceptan DD/MM/AAAA y AAAA-MM-DD escritos explícitamente.'],
            ['Género', 'GENERO acepta M o F, igual que el archivo exportado.'],
            ['Mes', 'MES se deriva de FECHA DE INGRESO. Si se diligencia, debe coincidir con el mes de esa fecha y no se almacena independientemente.'],
            ['Seguridad social', 'En los pares SI/NO se aceptan OK, X o vacío. La entidad se resuelve principalmente desde CUAL y debe existir en CATALOGOS. No se crean catálogos.'],
            ['Tallas', 'TALLA OVEROL, TALLA PANTALON, TALLA CAMISA y NUMERO CALZADO se resuelven contra tallas vigentes.'],
            ['Columnas informativas', 'Copias de documento, contrato firmado, fecha de finalización y salario contractual, examen médico, arrendamiento, ARL carnet, batería psicosocial, última entrega y finalización de contrato se aceptan por compatibilidad, pero generan advertencia y no crean documentos, contratos, exámenes, entregas ni históricos.'],
            ['Contrato', 'TIPO ULTIMO CONTRATO asigna el tipo al empleado. Esta carga no crea contratos ni historial contractual.'],
            ['Importación', 'La validación no escribe datos. La importación revalida el archivo completo y es atómica: si hay un error, no se crea ningún registro.'],
            ['Límite', 'Máximo '.config('bulk_load.max_rows', 1000).' filas de datos y '.config('bulk_load.max_file_kb', 5120).' KB por archivo.'],
        ];
    }

    private function catalogRows(array $catalogs): array
    {
        $rows = [];
        foreach ([
            'document_types' => 'TIPO DE DOCUMENTO',
            'areas' => 'AREA',
            'positions' => 'CARGO',
            'contract_types' => 'TIPO ULTIMO CONTRATO',
        ] as $key => $label) {
            foreach ($catalogs[$key] as $row) {
                $rows[] = [$label, '', $row['name']];
            }
        }
        foreach ($catalogs['social_security'] as $row) {
            $rows[] = ['SEGURIDAD SOCIAL', $row['type'], $row['name']];
        }
        foreach ($catalogs['dotation_sizes'] as $row) {
            $rows[] = ['TALLAS', $row['type'], $row['name']];
        }

        return $rows;
    }

    private function setDataColumnWidths($sheet): void
    {
        $widths = [
            1 => 13, 2 => 9, 3 => 25, 4 => 18, 5 => 24, 6 => 22, 7 => 22,
            8 => 20, 9 => 24, 10 => 12, 11 => 17, 12 => 20, 13 => 20, 14 => 17,
            15 => 18, 16 => 28, 17 => 20, 18 => 20, 19 => 23, 20 => 22, 21 => 15,
            22 => 21, 23 => 26, 24 => 28, 25 => 20, 26 => 27, 27 => 13, 28 => 13,
            29 => 28, 30 => 15, 31 => 15, 32 => 28, 33 => 13, 34 => 13, 35 => 28,
            36 => 17, 37 => 27, 38 => 27, 39 => 31, 40 => 17, 41 => 17, 42 => 28,
            43 => 27, 44 => 25, 45 => 15, 46 => 16, 47 => 15, 48 => 16, 49 => 34,
            50 => 25, 51 => 15,
        ];
        foreach ($widths as $column => $width) {
            $sheet->setColumnWidth($width, $column);
        }
    }
}
