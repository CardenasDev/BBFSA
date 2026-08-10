<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\TrainingRepository;
use DateTimeImmutable;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;
use OpenSpout\Common\Entity\Cell;
use OpenSpout\Reader\XLSX\Reader;
use Throwable;
use ZipArchive;

class TrainingService
{
    public function __construct(private readonly TrainingRepository $repository, private readonly AuditService $audit) {}

    public function tasks(bool $inactive = false): array
    {
        return $this->bools($this->repository->tasks($inactive));
    }

    public function saveTask(array $data, int $actor, array $context): array
    {
        return $this->mutate('LABOR_GUARDAR', $this->repository->saveTask($data), $actor, $context);
    }

    public function attachedTasks(int $trainingId, bool $inactive = false): array
    {
        return $this->bools($this->repository->attachedTasks($trainingId, $inactive));
    }

    public function trainings(?string $type, bool $inactive = false): array
    {
        return $this->bools($this->repository->trainings($type ? strtoupper($type) : null, $inactive));
    }

    public function saveTraining(array $data, int $actor, array $context): array
    {
        return $this->mutate('CAPACITACION_GUARDAR', $this->repository->saveTraining($data, $actor), $actor, $context);
    }

    public function attachTask(array $data, int $actor, array $context): array
    {
        return $this->mutate('LABOR_ASOCIAR', $this->repository->attachTask($data), $actor, $context);
    }

    public function createSession(array $data, int $actor, array $context): array
    {
        return $this->mutate('SESION_CREAR', $this->repository->createSession($data, $actor), $actor, $context);
    }

    public function sessions(array $filters): array
    {
        return $this->repository->sessions($filters);
    }

    public function session(int $id): array
    {
        $result = $this->repository->sessionDetail($id);
        if (! $result['session']) {
            throw new ApiException('La sesion no existe.', 404);
        }

        return $result;
    }

    public function status(int $id, string $status, int $actor, array $context): array
    {
        return $this->mutate('SESION_ESTADO', $this->repository->changeSessionStatus($id, strtoupper($status), $actor), $actor, $context);
    }

    public function participant(int $session, int $employee, ?string $observations, int $actor, array $context): array
    {
        return $this->mutate('PARTICIPANTE_AGREGAR', $this->repository->addParticipant($session, $employee, $observations, $actor), $actor, $context);
    }

    public function attendance(int $participant, string $status, ?string $observations, int $actor, array $context): array
    {
        return $this->mutate('ASISTENCIA_REGISTRAR', $this->repository->attendance($participant, strtoupper($status), $observations), $actor, $context);
    }

    public function evaluation(array $data, int $actor, array $context): array
    {
        return $this->mutate('EVALUACION_GUARDAR', $this->repository->evaluation($data, $actor), $actor, $context);
    }

    public function result(array $data, int $actor, array $context): array
    {
        return $this->mutate('RESULTADO_REGISTRAR', $this->repository->result($data, $actor), $actor, $context);
    }

    public function confirmEmployee(int $participant, ?string $observation, int $actor, array $context): array
    {
        return $this->mutate('CONFIRMAR_EMPLEADO', $this->repository->confirmEmployee($actor, $participant, $observation), $actor, $context);
    }

    public function confirmHr(int $participant, ?string $observation, int $actor, array $context): array
    {
        return $this->mutate('CONFIRMAR_RRHH', $this->repository->confirmHr($actor, $participant, $observation), $actor, $context);
    }

    public function myRecords(int $actor): array
    {
        return $this->bools($this->repository->myRecords($actor));
    }

    public function alerts(?int $employee): array
    {
        return $this->repository->alerts($employee);
    }

    public function commitments(?int $employee, ?string $status): array
    {
        return $this->repository->commitments($employee, $status ? strtoupper($status) : null);
    }

    public function commitment(int $id): array
    {
        $commitment = $this->repository->commitment($id);
        if (! $commitment) {
            throw new ApiException('El compromiso no existe.', 404);
        }

        return $commitment;
    }

    public function createCommitment(array $data, int $actor, array $context): array
    {
        return $this->mutate('COMPROMISO_CREAR', $this->repository->createCommitment($data, $actor), $actor, $context);
    }

    public function updateCommitment(int $id, array $data, int $actor, array $context): array
    {
        $stored = [];
        foreach (['documento' => 'documento_ruta', 'firma' => 'firma_url'] as $field => $target) {
            if (($data[$field] ?? null) instanceof UploadedFile) {
                $file = $data[$field];
                $directory = 'uploads/trainings/commitments/'.now()->format('Ym');
                File::ensureDirectoryExists(public_path($directory), 0755, true);
                $name = Str::uuid().'.'.strtolower($file->getClientOriginalExtension());
                $file->move(public_path($directory), $name);
                $stored[] = $directory.'/'.$name;
                $data[$target] = $target === 'firma_url' ? url($directory.'/'.$name) : $directory.'/'.$name;
            }
        }
        unset($data['documento'], $data['firma']);

        try {
            return $this->mutate('COMPROMISO_ACTUALIZAR', $this->repository->updateCommitment($id, $data, $actor), $actor, $context);
        } catch (Throwable $exception) {
            foreach ($stored as $path) {
                File::delete(public_path($path));
            }
            throw $exception;
        }
    }

    public function importMatrix(int $sessionId, UploadedFile $upload, int $actor, array $context): array
    {
        $this->assertWorkbook($upload);
        $directory = 'uploads/trainings/'.now()->format('Ym');
        File::ensureDirectoryExists(public_path($directory), 0755, true);
        $filename = Str::uuid().'.xlsx';
        $relative = $directory.'/'.$filename;
        $upload->move(public_path($directory), $filename);
        $import = $this->repository->createImport($sessionId, ['nombre_archivo' => $filename, 'nombre_original' => $upload->getClientOriginalName(), 'ruta' => $relative, 'mime' => $upload->getClientMimeType(), 'peso' => File::size(public_path($relative))], $actor);
        if (! $import) {
            File::delete(public_path($relative));
            throw new ApiException('No fue posible registrar la importacion.', 500);
        }
        $importId = (int) $import['id_capacitacion_importacion'];
        try {
            $parsed = $this->parseMatrix(public_path($relative), $this->session($sessionId));
            foreach ($parsed['errors'] as $error) {
                $this->repository->addImportError($importId, $error);
            }
            if ($parsed['errors']) {
                $final = $this->repository->finishImport($importId, 'CON_ERRORES', $parsed['total'], 0, 'El archivo no fue aplicado porque contiene empleados o labores sin correspondencia inequivoca.');

                return ['importacion' => $final, 'errores' => $parsed['errors'], 'aplicados' => 0];
            }
            $final = DB::transaction(function () use ($parsed, $actor, $importId): ?array {
                foreach ($parsed['rows'] as $row) {
                    $this->repository->evaluation($row, $actor, 'EXCEL', $importId);
                }

                return $this->repository->finishImport($importId, 'IMPORTADA', $parsed['total'], count($parsed['rows']), 'Matriz semanal importada correctamente.');
            });
            $this->audit->record($actor, 'CAPACITACIONES', 'IMPORTACION_EXCEL', 'CAPACITACION_IMPORTACION', $importId, null, ['id_sesion' => $sessionId, 'registros' => count($parsed['rows'])], $context);

            return ['importacion' => $final, 'errores' => [], 'aplicados' => count($parsed['rows'])];
        } catch (Throwable $e) {
            $this->repository->finishImport($importId, 'CON_ERRORES', 0, 0, 'Error al procesar el archivo: '.$e->getMessage());
            throw $e;
        }
    }

    private function parseMatrix(string $path, array $detail): array
    {
        $session = $detail['session'];
        $participants = [];
        foreach ($detail['participants'] as $p) {
            $participants[$this->key($p['empleado'])][] = $p;
        }
        $tasks = [];
        foreach ($this->attachedTasks((int) $session['id_capacitacion']) as $task) {
            $tasks[$this->key($task['nombre'])] = $task;
        }
        $reader = new Reader;
        $reader->open($path);
        $records = [];
        $errors = [];
        $total = 0;
        try {
            foreach ($reader->getSheetIterator() as $sheet) {
                $rows = [];
                foreach ($sheet->getRowIterator() as $number => $row) {
                    $rows[$number] = array_map(static fn (Cell $c): mixed => $c->getValue(), $row->getCells());
                }
                foreach ($rows as $number => $values) {
                    $headerIndex = array_search('CODIGO EMPLEADO', array_map(fn ($v) => $this->key($v), $values), true);
                    if ($headerIndex === false) {
                        continue;
                    }
                    $names = $rows[$number - 1] ?? [];
                    $groups = [];
                    for ($column = $headerIndex + 2; $column < count($values); $column++) {
                        if ($this->key($values[$column] ?? null) === 'LU') {
                            $name = trim((string) ($names[$column] ?? ''));
                            if ($name !== '') {
                                $groups[] = ['name' => $name, 'start' => $column];
                            }
                        }
                    }
                    for ($r = $number + 1; isset($rows[$r]); $r++) {
                        $laborName = trim((string) ($rows[$r][$headerIndex] ?? ''));
                        if ($this->key($laborName) === 'TOTALES' || $laborName === '') {
                            break;
                        }
                        $task = $tasks[$this->key($laborName)] ?? null;
                        foreach ($groups as $group) {
                            $matches = $participants[$this->key($group['name'])] ?? [];
                            for ($day = 0; $day < 5; $day++) {
                                $value = $rows[$r][$group['start'] + $day] ?? null;
                                if ($value === null || trim((string) $value) === '') {
                                    continue;
                                }
                                $total++;
                                if (count($matches) !== 1) {
                                    $errors[] = ['hoja' => $sheet->getName(), 'fila' => $r, 'empleado' => $group['name'], 'labor' => $laborName, 'valor' => (string) $value, 'codigo' => count($matches) ? 'EMPLEADO_AMBIGUO' : 'EMPLEADO_NO_ENCONTRADO', 'mensaje' => 'El nombre no identifica de forma inequivoca a un participante de la sesion.'];

                                    continue;
                                }
                                if (! $task) {
                                    $errors[] = ['hoja' => $sheet->getName(), 'fila' => $r, 'empleado' => $group['name'], 'labor' => $laborName, 'valor' => (string) $value, 'codigo' => 'LABOR_NO_ENCONTRADA', 'mensaje' => 'La labor no existe en el catalogo activo.'];

                                    continue;
                                }
                                if (! is_numeric($value) || $value < 0) {
                                    $errors[] = ['hoja' => $sheet->getName(), 'fila' => $r, 'empleado' => $group['name'], 'labor' => $laborName, 'valor' => (string) $value, 'codigo' => 'VALOR_INVALIDO', 'mensaje' => 'La calificacion debe ser numerica y mayor o igual a cero.'];

                                    continue;
                                }
                                $date = (new DateTimeImmutable($session['fecha_inicio']))->modify('+'.$day.' days')->format('Y-m-d');
                                $records[] = ['id_capacitacion_participante' => (int) $matches[0]['id_capacitacion_participante'], 'id_capacitacion_labor' => (int) $task['id_capacitacion_labor'], 'fecha_evaluacion' => $date, 'valor_obtenido' => (float) $value, 'requiere_atencion' => false];
                            }
                        }
                    }
                }
            }
        } finally {
            $reader->close();
        }
        if ($total === 0) {
            $errors[] = ['codigo' => 'MATRIZ_SIN_DATOS', 'mensaje' => 'No se encontraron bloques con encabezado CODIGO EMPLEADO ni valores diarios.'];
        }

        return ['rows' => $records, 'errors' => $errors, 'total' => $total];
    }

    private function assertWorkbook(UploadedFile $file): void
    {
        if (! $file->isValid() || strtolower($file->getClientOriginalExtension()) !== 'xlsx') {
            throw new ApiException('Debe cargar un archivo XLSX valido.', 422);
        }
        $zip = new ZipArchive;
        if ($zip->open($file->getRealPath()) !== true) {
            throw new ApiException('El archivo XLSX esta danado.', 422);
        }
        if ($zip->numFiles > 5000) {
            $zip->close();
            throw new ApiException('El XLSX contiene demasiados archivos internos.', 422);
        }
        $zip->close();
    }

    private function mutate(string $action, ?array $row, int $actor, array $context): array
    {
        if (! $row) {
            throw new ApiException('No fue posible completar la operacion.', 422);
        }
        $this->audit->record($actor, 'CAPACITACIONES', $action, 'CAPACITACION', null, null, $row, $context);

        return $this->bools([$row])[0];
    }

    private function bools(array $rows): array
    {
        foreach ($rows as &$row) {
            foreach (['activo', 'requiere_evaluacion', 'requiere_confirmacion', 'generar_compromiso_no_aprobado', 'confirmo_recibido', 'requiere_atencion', 'requiere_reinduccion', 'requiere_compromiso'] as $key) {
                if (array_key_exists($key, $row)) {
                    $row[$key] = (bool) $row[$key];
                }
            }
        }

        return $rows;
    }

    private function key(mixed $value): string
    {
        return Str::of((string) $value)->ascii()->upper()->squish()->toString();
    }
}
