<?php

use App\Http\Controllers\Api\ApplicantController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CatalogController;
use App\Http\Controllers\Api\ContractingController;
use App\Http\Controllers\Api\DomainController;
use App\Http\Controllers\Api\DotationController;
use App\Http\Controllers\Api\EmployeeController;
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\RoleController;
use App\Http\Controllers\Api\UserController;
use Illuminate\Support\Facades\Route;

Route::get('health', HealthController::class);

Route::prefix('auth')->group(function (): void {
    Route::post('login', [AuthController::class, 'login']);
    Route::post('refresh', [AuthController::class, 'refresh']);

    Route::middleware('auth.jwt')->group(function (): void {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::post('logout-all', [AuthController::class, 'logoutAll']);
        Route::get('me', [AuthController::class, 'me']);
        Route::post('change-password', [AuthController::class, 'changePassword']);
    });
});

Route::middleware('auth.jwt')->group(function (): void {
    Route::get('catalogs/document-types', [CatalogController::class, 'documentTypes'])->middleware('permission:EMPLEADOS_VER,EMPLEADOS_CREAR');
    Route::get('catalogs/areas', [CatalogController::class, 'areas'])->middleware('permission:EMPLEADOS_VER,EMPLEADOS_CREAR');
    Route::get('catalogs/positions', [CatalogController::class, 'positions'])->middleware('permission:EMPLEADOS_VER,EMPLEADOS_CREAR');
    Route::get('catalogs/contract-types', [CatalogController::class, 'contractTypes'])->middleware('permission:EMPLEADOS_VER,EMPLEADOS_CREAR');
    Route::get('catalogs/labor-document-types', [CatalogController::class, 'laborDocumentTypes'])->middleware('permission:ASPIRANTES_DOCUMENTOS_VER,CONTRATACION_DOCUMENTOS_VER');
    Route::prefix('applicants')->group(function (): void {
        Route::get('/', [ApplicantController::class, 'index'])->middleware('permission:ASPIRANTES_VER');
        Route::post('/', [ApplicantController::class, 'store'])->middleware('permission:ASPIRANTES_CREAR');
        Route::get('{applicantId}', [ApplicantController::class, 'show'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_VER');
        Route::put('{applicantId}', [ApplicantController::class, 'update'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_EDITAR');
        Route::patch('{applicantId}/status', [ApplicantController::class, 'changeStatus'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_CAMBIAR_ESTADO');
        Route::post('{applicantId}/approve-contracting', [ApplicantController::class, 'approveForContracting'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_APROBAR_CONTRATACION');
        Route::get('{applicantId}/documents', [ApplicantController::class, 'documents'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_DOCUMENTOS_VER');
        Route::post('{applicantId}/documents', [ApplicantController::class, 'registerDocument'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_DOCUMENTOS_SUBIR');
        Route::get('{applicantId}/status-history', [ApplicantController::class, 'statusHistory'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_VER');
        Route::post('{applicantId}/convert-to-employee', [ApplicantController::class, 'convertToEmployee'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_CONVERTIR_EMPLEADO');
    });
    Route::get('employees', [EmployeeController::class, 'index'])->middleware('permission:EMPLEADOS_LISTAR,EMPLEADOS_VER');
    Route::get('employees/export', [EmployeeController::class, 'export'])->middleware('permission:EMPLEADOS_LISTAR,EMPLEADOS_VER');
    Route::post('employees', [EmployeeController::class, 'store'])->middleware('permission:EMPLEADOS_CREAR');
    Route::get('employees/by-document/{document}', [EmployeeController::class, 'byDocument'])->middleware('permission:EMPLEADOS_VER,USUARIOS_CREAR,USUARIOS_EDITAR');
    Route::get('employees/{id}', [EmployeeController::class, 'show'])->whereNumber('id')->middleware('permission:EMPLEADOS_VER');
    Route::post('employees/{id}/photo', [EmployeeController::class, 'uploadPhoto'])->whereNumber('id')->middleware('permission:EMPLEADOS_EDITAR');
    Route::patch('employees/{id}', [EmployeeController::class, 'update'])->whereNumber('id')->middleware('permission:EMPLEADOS_EDITAR');
    Route::patch('employees/{id}/estado', [EmployeeController::class, 'changeStatus'])->whereNumber('id')->middleware('permission:EMPLEADOS_CAMBIAR_ESTADO');
    Route::delete('employees/{id}', [EmployeeController::class, 'destroy'])->whereNumber('id')->middleware('permission:EMPLEADOS_ELIMINAR');
    Route::get('users', [UserController::class, 'index'])->middleware('permission:USUARIOS_LISTAR');
    Route::get('users/{id}', [UserController::class, 'show'])->whereNumber('id')->middleware('permission:USUARIOS_VER');
    Route::post('users', [UserController::class, 'store'])->middleware('permission:USUARIOS_CREAR');
    Route::patch('users/{id}', [UserController::class, 'update'])->whereNumber('id')->middleware('permission:USUARIOS_EDITAR');
    Route::patch('users/{id}/estado', [UserController::class, 'changeStatus'])->whereNumber('id')->middleware('permission:USUARIOS_CAMBIAR_ESTADO');
    Route::patch('users/{id}/status', [UserController::class, 'changeStatus'])->whereNumber('id')->middleware('permission:USUARIOS_CAMBIAR_ESTADO');
    Route::post('users/{id}/roles', [UserController::class, 'assignRole'])->whereNumber('id')->middleware('permission:USUARIOS_ASIGNAR_ROL');
    Route::delete('users/{id}/roles/{roleId}', [UserController::class, 'removeRole'])->whereNumber(['id', 'roleId'])->middleware('permission:USUARIOS_QUITAR_ROL');
    Route::get('users/{id}/roles', [UserController::class, 'roles'])->whereNumber('id')->middleware('permission:USUARIOS_VER_ROLES');
    Route::get('users/{id}/permissions', [UserController::class, 'permissions'])->whereNumber('id')->middleware('permission:USUARIOS_VER_PERMISOS');
    Route::get('roles', [RoleController::class, 'roles'])->middleware('permission:ROLES_LISTAR');
    Route::post('roles', [RoleController::class, 'store'])->middleware('permission:ROLES_CREAR');
    Route::patch('roles/{id}/estado', [RoleController::class, 'changeState'])->whereNumber('id')->middleware('permission:ROLES_EDITAR');
    Route::delete('roles/{id}', [RoleController::class, 'destroy'])->whereNumber('id')->middleware('permission:ROLES_EDITAR');
    Route::get('roles/{id}/permissions', [RoleController::class, 'rolePermissions'])->whereNumber('id')->middleware('permission:ROLES_EDITAR');
    Route::post('roles/{id}/permissions', [RoleController::class, 'assignPermission'])->whereNumber('id')->middleware('permission:ROLES_EDITAR');
    Route::delete('roles/{id}/permissions/{permissionId}', [RoleController::class, 'removePermission'])->whereNumber(['id', 'permissionId'])->middleware('permission:ROLES_EDITAR');
    Route::get('domains', [DomainController::class, 'domains'])->middleware('permission:DOMINIOS_LISTAR');
    Route::post('domains', [DomainController::class, 'store'])->middleware('permission:DOMINIOS_CREAR');
    Route::patch('domains/{id}/estado', [DomainController::class, 'changeState'])->whereNumber('id')->middleware('permission:DOMINIOS_EDITAR');
    Route::get('permissions', [RoleController::class, 'permissions'])->middleware('permission:PERMISOS_LISTAR');
    Route::prefix('dotations')->group(function (): void {
        Route::get('types', [DotationController::class, 'types'])->middleware('permission:DOTACIONES_CATALOGOS_VER');
        Route::get('sizes', [DotationController::class, 'sizes'])->middleware('permission:DOTACIONES_CATALOGOS_VER');
        Route::get('my-sizes', [DotationController::class, 'mySizes'])->middleware('permission:DOTACIONES_MIS_TALLAS_VER');
        Route::post('my-sizes', [DotationController::class, 'saveMySize'])->middleware('permission:DOTACIONES_MIS_TALLAS_EDITAR');
        Route::get('my-deliveries', [DotationController::class, 'myDeliveries'])->middleware('permission:DOTACIONES_MIS_ENTREGAS_VER');
        Route::get('employees', [DotationController::class, 'employees'])->middleware('permission:DOTACIONES_ADMIN_VER');
        Route::get('employees/{employeeId}/history', [DotationController::class, 'employeeHistory'])->whereNumber('employeeId')->middleware('permission:DOTACIONES_EMPLEADO_VER');
        Route::get('employees/{employeeId}/sizes', [DotationController::class, 'employeeSizes'])->whereNumber('employeeId')->middleware('permission:DOTACIONES_EMPLEADO_VER');
        Route::post('deliveries', [DotationController::class, 'createDelivery'])->middleware('permission:DOTACIONES_ENTREGAS_CREAR');
        Route::get('deliveries', [DotationController::class, 'deliveries'])->middleware('permission:DOTACIONES_ENTREGAS_VER');
        Route::delete('deliveries/{deliveryId}', [DotationController::class, 'deleteDelivery'])->whereNumber('deliveryId')->middleware('permission:DOTACIONES_ENTREGAS_ELIMINAR');
        Route::post('deliveries/{deliveryId}/confirm', [DotationController::class, 'confirmDeliveryReceived'])->whereNumber('deliveryId')->middleware('permission:DOTACIONES_MIS_ENTREGAS_CONFIRMAR');
        Route::get('deliveries/{deliveryId}/details', [DotationController::class, 'deliveryDetails'])->whereNumber('deliveryId')->middleware('permission:DOTACIONES_ENTREGAS_VER');
    });
    Route::prefix('contracting')->group(function (): void {
        Route::get('employees', [ContractingController::class, 'indexEmployees'])->middleware('permission:CONTRATACION_VER');
        Route::get('contract-templates', [ContractingController::class, 'listContractTemplates'])->middleware('permission:CONTRATACION_VER');
        Route::get('contract-templates/by-type', [ContractingController::class, 'getContractTemplateByType'])->middleware('permission:CONTRATACION_VER');
        Route::get('contract-templates/{templateId}', [ContractingController::class, 'getContractTemplate'])->whereNumber('templateId')->middleware('permission:CONTRATACION_VER');
        Route::get('contracts/{employeeContractId}/generation-data', [ContractingController::class, 'getContractGenerationData'])->whereNumber('employeeContractId')->middleware('permission:CONTRATACION_VER');
        Route::get('employees/{employeeId}/profile', [ContractingController::class, 'getProfile'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_VER');
        Route::post('employees/{employeeId}/profile', [ContractingController::class, 'saveProfile'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_CREAR,CONTRATACION_EDITAR');
        Route::get('employees/{employeeId}/contracts', [ContractingController::class, 'listContracts'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_HISTORIAL_VER');
        Route::post('employees/{employeeId}/contracts', [ContractingController::class, 'createContract'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_CREAR');
        Route::get('employees/{employeeId}/social-security', [ContractingController::class, 'getSocialSecurity'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_SEGURIDAD_SOCIAL_VER');
        Route::post('employees/{employeeId}/social-security', [ContractingController::class, 'saveSocialSecurity'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_SEGURIDAD_SOCIAL_EDITAR');
        Route::get('employees/{employeeId}/medical-exams', [ContractingController::class, 'listMedicalExams'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_EXAMENES_VER');
        Route::post('employees/{employeeId}/medical-exams', [ContractingController::class, 'createMedicalExam'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_EXAMENES_CREAR');
        Route::get('employees/{employeeId}/documents', [ContractingController::class, 'listDocuments'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_DOCUMENTOS_VER');
        Route::post('employees/{employeeId}/documents', [ContractingController::class, 'registerDocument'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_DOCUMENTOS_SUBIR');
        Route::get('alerts', [ContractingController::class, 'listAlerts'])->middleware('permission:CONTRATACION_ALERTAS_VER');
    });
});
