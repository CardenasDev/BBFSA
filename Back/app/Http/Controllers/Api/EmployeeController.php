<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\ChangeEmployeeStatusRequest;
use App\Http\Requests\StoreEmployeeRequest;
use App\Http\Requests\UpdateEmployeeRequest;
use App\Http\Requests\UploadEmployeePhotoRequest;
use App\Services\EmployeeService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

#[Group('Employees', 'Administracion de empleados.', weight: 5)]
class EmployeeController extends ApiController
{
    public function __construct(private readonly EmployeeService $employees) {}

    /**
     * Listar empleados
     *
     * Permite filtrar por estado laboral, area, cargo y texto de busqueda.
     */
    public function index(Request $request): JsonResponse
    {
        return $this->success($this->employees->list(
            $request->query('estado_empleado'),
            $request->integer('id_area') ?: null,
            $request->integer('id_cargo') ?: null,
            $request->query('texto_busqueda'),
        ));
    }

    /**
     * Exportar empleados activos
     *
     * Descarga el reporte consolidado de empleados activos en formato XLSX.
     */
    public function export(): BinaryFileResponse
    {
        $export = $this->employees->exportActiveEmployees();

        return response()->download($export['path'], $export['filename'], [
            'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ])->deleteFileAfterSend(true);
    }

    /**
     * Crear empleado
     *
     * Crea un empleado sin generar usuario automaticamente.
     */
    public function store(StoreEmployeeRequest $request): JsonResponse
    {
        $employee = $this->employees->create($request->validated(), $this->actorId($request), $this->context($request));

        return $this->success($employee, 'Empleado creado exitosamente.', 201);
    }

    /**
     * Obtener empleado
     *
     * Retorna un empleado por su identificador.
     */
    public function show(int $id): JsonResponse
    {
        return $this->success($this->employees->find($id));
    }

    /**
     * Buscar empleado por documento
     *
     * Retorna el empleado asociado al numero de documento indicado.
     */
    public function byDocument(string $document): JsonResponse
    {
        return $this->success($this->employees->findByDocument($document));
    }

    /**
     * Actualizar empleado
     *
     * Actualiza datos laborales sin modificar usuarios vinculados.
     */
    public function update(UpdateEmployeeRequest $request, int $id): JsonResponse
    {
        $employee = $this->employees->update($id, $request->validated(), $this->actorId($request), $this->context($request));

        return $this->success($employee, 'Empleado actualizado exitosamente.');
    }

    /**
     * Cargar foto del empleado
     *
     * Guarda una imagen fisica y actualiza la ruta FOTO_URL del empleado.
     */
    public function uploadPhoto(UploadEmployeePhotoRequest $request, int $id): JsonResponse
    {
        $photo = $request->file('photo');

        return $this->success(
            $this->employees->uploadPhoto($id, $photo),
            'Foto de empleado cargada correctamente',
        );
    }

    /**
     * Cambiar estado laboral
     *
     * Cambia el estado laboral del empleado y maneja fecha de retiro segun el SP.
     */
    public function changeStatus(ChangeEmployeeStatusRequest $request, int $id): JsonResponse
    {
        $employee = $this->employees->changeStatus(
            $id,
            (string) $request->string('estado_empleado'),
            $request->validated('fecha_retiro'),
            $this->actorId($request),
            $this->context($request),
        );

        return $this->success($employee, 'Estado laboral actualizado exitosamente.');
    }

    /**
     * Eliminar empleado
     *
     * Elimina logicamente un empleado sin borrar usuarios, auditoria ni catalogos.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        return $this->success(
            $this->employees->deleteLogical($id, $this->actorId($request), $this->context($request)),
            'Empleado eliminado exitosamente.',
        );
    }
}
