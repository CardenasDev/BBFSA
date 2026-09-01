<?php

use App\Http\Controllers\Api\ApplicantController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BulkLoadEmployeeController;
use App\Http\Controllers\Api\CatalogController;
use App\Http\Controllers\Api\ContractingController;
use App\Http\Controllers\Api\DomainController;
use App\Http\Controllers\Api\DotationController;
use App\Http\Controllers\Api\EmployeeController;
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\MyToolDeliveryController;
use App\Http\Controllers\Api\NoveltyController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ReturnController;
use App\Http\Controllers\Api\RetirementController;
use App\Http\Controllers\Api\RoleController;
use App\Http\Controllers\Api\ToolController;
use App\Http\Controllers\Api\TrainingController;
use App\Http\Controllers\Api\UserController;
use Illuminate\Support\Facades\Route;

Route::get('health', HealthController::class);

Route::prefix('auth')->group(function (): void {
    Route::post('login', [AuthController::class, 'login']);
    Route::post('refresh', [AuthController::class, 'refresh']);

    Route::middleware('auth.jwt')->group(function (): void {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('me', [AuthController::class, 'me']);
        Route::post('change-password', [AuthController::class, 'changePassword']);
    });
});

Route::middleware('auth.jwt')->group(function (): void {
    Route::prefix('bulk-load/employees')->group(function (): void {
        Route::get('template', [BulkLoadEmployeeController::class, 'template'])->middleware('permission:EMPLEADOS_VER,EMPLEADOS_CREAR');
        Route::post('validate', [BulkLoadEmployeeController::class, 'validateFile'])->middleware('permission:EMPLEADOS_VER,EMPLEADOS_CREAR');
        Route::post('import', [BulkLoadEmployeeController::class, 'import'])->middleware('permission:EMPLEADOS_CREAR');
    });
    Route::get('catalogs/document-types', [CatalogController::class, 'documentTypes'])->middleware('permission:EMPLEADOS_VER,EMPLEADOS_CREAR');
    Route::get('catalogs/areas', [CatalogController::class, 'areas'])->middleware('permission:EMPLEADOS_VER,EMPLEADOS_CREAR');
    Route::get('catalogs/positions', [CatalogController::class, 'positions'])->middleware('permission:EMPLEADOS_VER,EMPLEADOS_CREAR');
    Route::get('catalogs/contract-types', [CatalogController::class, 'contractTypes'])->middleware('permission:EMPLEADOS_VER,EMPLEADOS_CREAR');
    Route::get('catalogs/departments', [CatalogController::class, 'departments'])->middleware('permission:ASPIRANTES_VER,ASPIRANTES_CREAR,ASPIRANTES_EDITAR,CONTRATACION_VER,CONTRATACION_CREAR,CONTRATACION_EDITAR');
    Route::get('catalogs/departments/{departmentId}/municipalities', [CatalogController::class, 'municipalities'])->whereNumber('departmentId')->middleware('permission:ASPIRANTES_VER,ASPIRANTES_CREAR,ASPIRANTES_EDITAR,CONTRATACION_VER,CONTRATACION_CREAR,CONTRATACION_EDITAR');
    Route::get('catalogs/social-security-entities', [CatalogController::class, 'socialSecurityEntities'])->middleware('permission:CONTRATACION_SEGURIDAD_SOCIAL_VER,CONTRATACION_SEGURIDAD_SOCIAL_EDITAR,NOVEDADES_CREAR,NOVEDADES_EDITAR');
    Route::get('catalogs/medical-exam-types', [CatalogController::class, 'medicalExamTypes'])->middleware('permission:CONTRATACION_EXAMENES_VER,CONTRATACION_EXAMENES_CREAR');
    Route::get('catalogs/labor-document-types', [CatalogController::class, 'laborDocumentTypes'])->middleware('permission:ASPIRANTES_DOCUMENTOS_VER,CONTRATACION_DOCUMENTOS_VER');
    // Parámetros administrativos centralizados
    Route::prefix('parameters')->group(function (): void {
        Route::get('departments', [\App\Http\Controllers\Api\ParametersController::class, 'departments'])->middleware('permission:PARAMETROS_VER');
        Route::post('departments', [\App\Http\Controllers\Api\ParametersController::class, 'storeDepartment'])->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::put('departments/{id}', [\App\Http\Controllers\Api\ParametersController::class, 'updateDepartment'])->whereNumber('id')->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::get('municipalities', [\App\Http\Controllers\Api\ParametersController::class, 'municipalities'])->middleware('permission:PARAMETROS_VER');
        Route::post('municipalities', [\App\Http\Controllers\Api\ParametersController::class, 'storeMunicipality'])->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::put('municipalities/{id}', [\App\Http\Controllers\Api\ParametersController::class, 'updateMunicipality'])->whereNumber('id')->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::get('areas', [\App\Http\Controllers\Api\ParametersController::class, 'areas'])->middleware('permission:PARAMETROS_VER');
        Route::post('areas', [\App\Http\Controllers\Api\ParametersController::class, 'storeArea'])->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::put('areas/{id}', [\App\Http\Controllers\Api\ParametersController::class, 'updateArea'])->whereNumber('id')->middleware('permission:PARAMETROS_ADMINISTRAR');

        Route::get('positions', [\App\Http\Controllers\Api\ParametersController::class, 'positions'])->middleware('permission:PARAMETROS_VER');
        Route::post('positions', [\App\Http\Controllers\Api\ParametersController::class, 'storePosition'])->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::put('positions/{id}', [\App\Http\Controllers\Api\ParametersController::class, 'updatePosition'])->whereNumber('id')->middleware('permission:PARAMETROS_ADMINISTRAR');

        Route::get('contract-types', [\App\Http\Controllers\Api\ParametersController::class, 'contractTypes'])->middleware('permission:PARAMETROS_VER');
        Route::post('contract-types', [\App\Http\Controllers\Api\ParametersController::class, 'storeContractType'])->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::put('contract-types/{id}', [\App\Http\Controllers\Api\ParametersController::class, 'updateContractType'])->whereNumber('id')->middleware('permission:PARAMETROS_ADMINISTRAR');

        Route::get('document-types', [\App\Http\Controllers\Api\ParametersController::class, 'documentTypes'])->middleware('permission:PARAMETROS_VER');
        Route::post('document-types', [\App\Http\Controllers\Api\ParametersController::class, 'storeDocumentType'])->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::put('document-types/{id}', [\App\Http\Controllers\Api\ParametersController::class, 'updateDocumentType'])->whereNumber('id')->middleware('permission:PARAMETROS_ADMINISTRAR');

        Route::get('labor-document-types', [\App\Http\Controllers\Api\ParametersController::class, 'laborDocumentTypes'])->middleware('permission:PARAMETROS_VER');
        Route::post('labor-document-types', [\App\Http\Controllers\Api\ParametersController::class, 'storeLaborDocument'])->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::put('labor-document-types/{id}', [\App\Http\Controllers\Api\ParametersController::class, 'updateLaborDocument'])->whereNumber('id')->middleware('permission:PARAMETROS_ADMINISTRAR');

        Route::get('social-security-entities', [\App\Http\Controllers\Api\ParametersController::class, 'socialSecurityEntities'])->middleware('permission:PARAMETROS_VER');
        Route::post('social-security-entities', [\App\Http\Controllers\Api\ParametersController::class, 'storeSocialSecurityEntity'])->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::put('social-security-entities/{id}', [\App\Http\Controllers\Api\ParametersController::class, 'updateSocialSecurityEntity'])->whereNumber('id')->middleware('permission:PARAMETROS_ADMINISTRAR');

        Route::get('medical-exam-types', [\App\Http\Controllers\Api\ParametersController::class, 'medicalExamTypes'])->middleware('permission:PARAMETROS_VER');
        Route::post('medical-exam-types', [\App\Http\Controllers\Api\ParametersController::class, 'storeMedicalExamType'])->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::put('medical-exam-types/{id}', [\App\Http\Controllers\Api\ParametersController::class, 'updateMedicalExamType'])->whereNumber('id')->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::get('novelty-types', [\App\Http\Controllers\Api\ParametersController::class, 'noveltyTypes'])->middleware('permission:PARAMETROS_VER');
        Route::post('novelty-types', [\App\Http\Controllers\Api\ParametersController::class, 'storeNoveltyType'])->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::put('novelty-types/{id}', [\App\Http\Controllers\Api\ParametersController::class, 'updateNoveltyType'])->whereNumber('id')->middleware('permission:PARAMETROS_ADMINISTRAR');

        Route::get('uniform-items', [\App\Http\Controllers\Api\ParametersController::class, 'uniformItems'])->middleware('permission:PARAMETROS_VER');
        Route::get('uniform-item-families', [\App\Http\Controllers\Api\ParametersController::class, 'uniformItemFamilies'])->middleware('permission:PARAMETROS_VER');
        Route::post('uniform-items', [\App\Http\Controllers\Api\ParametersController::class, 'storeUniformItem'])->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::put('uniform-items/{id}', [\App\Http\Controllers\Api\ParametersController::class, 'updateUniformItem'])->whereNumber('id')->middleware('permission:PARAMETROS_ADMINISTRAR');

        Route::get('system', [\App\Http\Controllers\Api\ParametersController::class, 'systemParametersList'])->middleware('permission:PARAMETROS_VER');
        Route::post('system', [\App\Http\Controllers\Api\ParametersController::class, 'storeSystemParameter'])->middleware('permission:PARAMETROS_ADMINISTRAR');
        Route::put('system/{id}', [\App\Http\Controllers\Api\ParametersController::class, 'updateSystemParameter'])->whereNumber('id')->middleware('permission:PARAMETROS_ADMINISTRAR');
    });
    Route::prefix('applicants')->group(function (): void {
        Route::get('/', [ApplicantController::class, 'index'])->middleware('permission:ASPIRANTES_VER');
        Route::post('/', [ApplicantController::class, 'store'])->middleware('permission:ASPIRANTES_CREAR');
        Route::get('{applicantId}', [ApplicantController::class, 'show'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_VER');
        Route::put('{applicantId}', [ApplicantController::class, 'update'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_EDITAR');
        Route::patch('{applicantId}/status', [ApplicantController::class, 'changeStatus'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_CAMBIAR_ESTADO');
        Route::post('{applicantId}/approve-contracting', [ApplicantController::class, 'approveForContracting'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_APROBAR_CONTRATACION');
        Route::get('{applicantId}/documents', [ApplicantController::class, 'documents'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_DOCUMENTOS_VER');
        Route::post('{applicantId}/documents', [ApplicantController::class, 'registerDocument'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_DOCUMENTOS_SUBIR');
        Route::post('{applicantId}/documents/{documentId}', [ApplicantController::class, 'updateDocument'])->whereNumber(['applicantId', 'documentId'])->middleware('permission:ASPIRANTES_DOCUMENTOS_SUBIR');
        Route::get('{applicantId}/status-history', [ApplicantController::class, 'statusHistory'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_VER');
        Route::post('{applicantId}/convert-to-employee', [ApplicantController::class, 'convertToEmployee'])->whereNumber('applicantId')->middleware('permission:ASPIRANTES_CONVERTIR_EMPLEADO');
    });
    Route::get('employees', [EmployeeController::class, 'index'])->middleware('permission:EMPLEADOS_LISTAR,EMPLEADOS_VER,USUARIOS_CREAR,USUARIOS_EDITAR,NOVEDADES_VER,NOVEDADES_CREAR,RETIROS_VER,RETIROS_CREAR,RETIROS_VER,RETIROS_CREAR');
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
    Route::prefix('tools')->group(function (): void {
        Route::get('/', [ToolController::class, 'index'])->middleware('permission:HERRAMIENTAS_LISTAR');
        Route::post('/', [ToolController::class, 'store'])->middleware('permission:HERRAMIENTAS_CREAR');
        Route::put('{id}', [ToolController::class, 'update'])->whereNumber('id')->middleware('permission:HERRAMIENTAS_EDITAR');
        Route::patch('{id}/status', [ToolController::class, 'changeStatus'])->whereNumber('id')->middleware('permission:HERRAMIENTAS_EDITAR');
    });
    Route::prefix('tool-deliveries')->group(function (): void {
        Route::get('/', [ToolController::class, 'deliveries'])->middleware('permission:HERRAMIENTAS_LISTAR');
        Route::post('/', [ToolController::class, 'storeDelivery'])->middleware('permission:HERRAMIENTAS_ENTREGAR');
        Route::get('{id}', [ToolController::class, 'showDelivery'])->whereNumber('id')->middleware('permission:HERRAMIENTAS_LISTAR');
        Route::post('{id}/confirm', [ToolController::class, 'confirmDelivery'])->whereNumber('id')->middleware('permission:HERRAMIENTAS_CONFIRMAR');
        Route::delete('{id}', [ToolController::class, 'deleteDelivery'])->whereNumber('id')->middleware('permission:HERRAMIENTAS_ELIMINAR');
    });
    Route::prefix('my-tool-deliveries')->group(function (): void {
        Route::get('/', [MyToolDeliveryController::class, 'index'])->middleware('permission:HERRAMIENTAS_MIS_ENTREGAS_VER');
        Route::get('{id}', [MyToolDeliveryController::class, 'show'])->whereNumber('id')->middleware('permission:HERRAMIENTAS_MIS_ENTREGAS_VER');
        Route::post('{id}/confirm', [MyToolDeliveryController::class, 'confirm'])->whereNumber('id')->middleware('permission:HERRAMIENTAS_CONFIRMAR');
    });
    Route::prefix('dotations')->group(function (): void {
        Route::get('types', [DotationController::class, 'types'])->middleware('permission:DOTACIONES_CATALOGOS_VER');
        Route::get('sizes', [DotationController::class, 'sizes'])->middleware('permission:DOTACIONES_CATALOGOS_VER');
        Route::get('articles', [DotationController::class, 'articles'])->middleware('permission:DOTACIONES_CATALOGOS_VER');
        Route::get('combinations', [DotationController::class, 'combinations'])->middleware('permission:DOTACIONES_CATALOGOS_VER');
        Route::get('combinations/{combinationId}', [DotationController::class, 'combinationDetails'])->whereNumber('combinationId')->middleware('permission:DOTACIONES_CATALOGOS_VER');
        Route::get('my-sizes', [DotationController::class, 'mySizes'])->middleware('permission:DOTACIONES_MIS_TALLAS_VER');
        Route::post('my-sizes', [DotationController::class, 'saveMySize'])->middleware('permission:DOTACIONES_MIS_TALLAS_EDITAR');
        Route::get('my-deliveries', [DotationController::class, 'myDeliveries'])->middleware('permission:DOTACIONES_MIS_ENTREGAS_VER');
        Route::get('employees', [DotationController::class, 'employees'])->middleware('permission:DOTACIONES_ADMIN_VER');
        Route::get('quotation/export', [DotationController::class, 'exportQuotation'])->middleware('permission:DOTACIONES_ADMIN_VER');
        Route::get('purchase-quotation/export', [DotationController::class, 'exportPurchaseQuotation'])->middleware('permission:DOTACIONES_ADMIN_VER');
        Route::get('employees/{employeeId}/history', [DotationController::class, 'employeeHistory'])->whereNumber('employeeId')->middleware('permission:DOTACIONES_EMPLEADO_VER');
        Route::get('employees/{employeeId}/sizes', [DotationController::class, 'employeeSizes'])->whereNumber('employeeId')->middleware('permission:DOTACIONES_EMPLEADO_VER');
        Route::get('employees/{employeeId}/article-sizes', [DotationController::class, 'employeeArticleSizes'])->whereNumber('employeeId')->middleware('permission:DOTACIONES_EMPLEADO_VER');
        Route::put('employees/{employeeId}/article-sizes/{articleId}', [DotationController::class, 'saveEmployeeArticleSize'])->whereNumber(['employeeId', 'articleId'])->middleware('permission:DOTACIONES_ADMIN_VER');
        Route::post('deliveries', [DotationController::class, 'createDelivery'])->middleware('permission:DOTACIONES_ENTREGAS_CREAR');
        Route::post('deliveries/{deliveryId}/prepare', [DotationController::class, 'prepareDelivery'])->whereNumber('deliveryId')->middleware('permission:DOTACIONES_ENTREGAS_CREAR');
        Route::get('deliveries', [DotationController::class, 'deliveries'])->middleware('permission:DOTACIONES_ENTREGAS_VER');
        Route::delete('deliveries/{deliveryId}', [DotationController::class, 'deleteDelivery'])->whereNumber('deliveryId')->middleware('permission:DOTACIONES_ENTREGAS_ELIMINAR');
        Route::post('deliveries/{deliveryId}/confirm', [DotationController::class, 'confirmDeliveryReceived'])->whereNumber('deliveryId')->middleware('permission:DOTACIONES_MIS_ENTREGAS_CONFIRMAR');
        Route::post('deliveries/{deliveryId}/confirm-by-hr', [DotationController::class, 'confirmDeliveryByHr'])->whereNumber('deliveryId')->middleware('permission:DOTACIONES_ENTREGAS_CREAR');
        Route::get('deliveries/{deliveryId}/details', [DotationController::class, 'deliveryDetails'])->whereNumber('deliveryId')->middleware('permission:DOTACIONES_ENTREGAS_VER');
        Route::post('deliveries/{deliveryId}/evidence', [DotationController::class, 'replaceDeliveryEvidence'])->whereNumber('deliveryId')->middleware('permission:DOTACIONES_ENTREGAS_CREAR');
        Route::delete('deliveries/{deliveryId}/evidence', [DotationController::class, 'deleteDeliveryEvidence'])->whereNumber('deliveryId')->middleware('permission:DOTACIONES_ENTREGAS_CREAR');
    });
    Route::prefix('trainings')->group(function (): void {
        Route::get('tasks', [TrainingController::class, 'tasks'])->middleware('permission:CAPACITACIONES_VER');
        Route::post('tasks', [TrainingController::class, 'saveTask'])->middleware('permission:CAPACITACIONES_ADMINISTRAR');
        Route::get('/', [TrainingController::class, 'index'])->middleware('permission:CAPACITACIONES_VER');
        Route::post('/', [TrainingController::class, 'save'])->middleware('permission:CAPACITACIONES_ADMINISTRAR');
        Route::get('{trainingId}/tasks', [TrainingController::class, 'attachedTasks'])->whereNumber('trainingId')->middleware('permission:CAPACITACIONES_VER');
        Route::post('tasks/attach', [TrainingController::class, 'attachTask'])->middleware('permission:CAPACITACIONES_ADMINISTRAR');
        Route::get('sessions', [TrainingController::class, 'sessions'])->middleware('permission:CAPACITACIONES_VER');
        Route::post('sessions', [TrainingController::class, 'createSession'])->middleware('permission:CAPACITACIONES_ADMINISTRAR');
        Route::get('sessions/{sessionId}', [TrainingController::class, 'session'])->whereNumber('sessionId')->middleware('permission:CAPACITACIONES_VER');
        Route::patch('sessions/{sessionId}/status', [TrainingController::class, 'changeStatus'])->whereNumber('sessionId')->middleware('permission:CAPACITACIONES_ADMINISTRAR');
        Route::post('sessions/{sessionId}/participants', [TrainingController::class, 'participant'])->whereNumber('sessionId')->middleware('permission:CAPACITACIONES_ADMINISTRAR');
        Route::post('sessions/{sessionId}/import', [TrainingController::class, 'import'])->whereNumber('sessionId')->middleware('permission:CAPACITACIONES_IMPORTAR');
        Route::patch('participants/{participantId}/attendance', [TrainingController::class, 'attendance'])->whereNumber('participantId')->middleware('permission:CAPACITACIONES_ADMINISTRAR');
        Route::post('evaluations', [TrainingController::class, 'evaluation'])->middleware('permission:CAPACITACIONES_EVALUAR');
        Route::post('results', [TrainingController::class, 'result'])->middleware('permission:CAPACITACIONES_EVALUAR');
        Route::post('participants/{participantId}/confirm', [TrainingController::class, 'confirm'])->whereNumber('participantId')->middleware('permission:CAPACITACIONES_CONFIRMAR');
        Route::post('participants/{participantId}/confirm-by-hr', [TrainingController::class, 'confirmHr'])->whereNumber('participantId')->middleware('permission:CAPACITACIONES_ADMINISTRAR');
        Route::get('my/records', [TrainingController::class, 'mine'])->middleware('permission:CAPACITACIONES_MIS_REGISTROS_VER');
        Route::get('alerts', [TrainingController::class, 'alerts'])->middleware('permission:CAPACITACIONES_VER');
        Route::get('commitments', [TrainingController::class, 'commitments'])->middleware('permission:CAPACITACIONES_COMPROMISOS');
        Route::get('commitments/{commitmentId}', [TrainingController::class, 'commitment'])->whereNumber('commitmentId')->middleware('permission:CAPACITACIONES_COMPROMISOS');
        Route::post('commitments', [TrainingController::class, 'createCommitment'])->middleware('permission:CAPACITACIONES_COMPROMISOS');
        Route::patch('commitments/{commitmentId}', [TrainingController::class, 'updateCommitment'])->whereNumber('commitmentId')->middleware('permission:CAPACITACIONES_COMPROMISOS');
    });
    Route::prefix('returns')->group(function (): void {
        Route::get('available', [ReturnController::class, 'available'])->middleware('permission:DEVOLUCIONES_CREAR');
        Route::get('/', [ReturnController::class, 'index'])->middleware('permission:DEVOLUCIONES_VER');
        Route::post('/', [ReturnController::class, 'store'])->middleware('permission:DEVOLUCIONES_CREAR');
        Route::get('{id}', [ReturnController::class, 'show'])->whereNumber('id')->middleware('permission:DEVOLUCIONES_VER');
        Route::post('{id}/confirm', [ReturnController::class, 'confirm'])->whereNumber('id')->middleware('permission:DEVOLUCIONES_CONFIRMAR');
        Route::post('{id}/cancel', [ReturnController::class, 'cancel'])->whereNumber('id')->middleware('permission:DEVOLUCIONES_ANULAR');
    });
    Route::prefix('novelties')->group(function (): void {
        Route::get('types', [NoveltyController::class, 'types'])->middleware('permission:NOVEDADES_VER');
        Route::get('/', [NoveltyController::class, 'index'])->middleware('permission:NOVEDADES_VER');
        Route::post('/', [NoveltyController::class, 'store'])->middleware('permission:NOVEDADES_CREAR');
        Route::post('disabilities', [NoveltyController::class, 'storeDisability'])->middleware('permission:NOVEDADES_CREAR');
        Route::get('disabilities/tracking/export', [NoveltyController::class, 'exportDisabilityTracking'])->middleware('permission:NOVEDADES_VER');
        Route::get('{id}', [NoveltyController::class, 'show'])->whereNumber('id')->middleware('permission:NOVEDADES_VER');
        Route::put('{id}', [NoveltyController::class, 'update'])->whereNumber('id')->middleware('permission:NOVEDADES_EDITAR');
        Route::put('{id}/disability', [NoveltyController::class, 'updateDisability'])->whereNumber('id')->middleware('permission:NOVEDADES_EDITAR');
        Route::get('{id}/disability-tracking', [NoveltyController::class, 'disabilityTracking'])->whereNumber('id')->middleware('permission:NOVEDADES_VER');
        Route::put('{id}/disability-tracking', [NoveltyController::class, 'saveDisabilityTracking'])->whereNumber('id')->middleware('permission:NOVEDADES_EDITAR');
        Route::patch('{id}/status', [NoveltyController::class, 'status'])->whereNumber('id')->middleware('permission:NOVEDADES_CAMBIAR_ESTADO');
        Route::post('{id}/evidence', [NoveltyController::class, 'addEvidence'])->whereNumber('id')->middleware('permission:NOVEDADES_SOPORTES');
    });
    Route::prefix('retirements')->group(function (): void {
        Route::get('reasons', [RetirementController::class, 'reasons'])->middleware('permission:RETIROS_VER,RETIROS_CREAR');
        Route::get('document-types', [RetirementController::class, 'documentTypes'])->middleware('permission:RETIROS_VER,RETIROS_DOCUMENTOS');
        Route::get('/', [RetirementController::class, 'index'])->middleware('permission:RETIROS_VER');
        Route::post('/', [RetirementController::class, 'store'])->middleware('permission:RETIROS_CREAR');
        Route::get('{id}', [RetirementController::class, 'show'])->whereNumber('id')->middleware('permission:RETIROS_VER');
        Route::get('{id}/certificate', [RetirementController::class, 'certificate'])->whereNumber('id')->middleware('permission:RETIROS_CERTIFICADO_GENERAR');
        Route::patch('{id}/activities', [RetirementController::class, 'activity'])->whereNumber('id')->middleware('permission:RETIROS_EDITAR');
        Route::put('{id}/interview', [RetirementController::class, 'interview'])->whereNumber('id')->middleware('permission:RETIROS_ENTREVISTA');
        Route::post('{id}/documents', [RetirementController::class, 'document'])->whereNumber('id')->middleware('permission:RETIROS_DOCUMENTOS');
        Route::post('{id}/finalize', [RetirementController::class, 'finalize'])->whereNumber('id')->middleware('permission:RETIROS_FINALIZAR');
        Route::post('{id}/cancel', [RetirementController::class, 'cancel'])->whereNumber('id')->middleware('permission:RETIROS_CANCELAR');
    });
    Route::prefix('notifications')->group(function (): void {
        Route::get('summary', [NotificationController::class, 'summary'])->middleware('permission:NOTIFICACIONES_VER');
        Route::get('/', [NotificationController::class, 'index'])->middleware('permission:NOTIFICACIONES_VER');
        Route::patch('{id}/read', [NotificationController::class, 'markRead'])->whereNumber('id')->middleware('permission:NOTIFICACIONES_VER');
        Route::patch('{id}/archive', [NotificationController::class, 'archive'])->whereNumber('id')->middleware('permission:NOTIFICACIONES_VER');
        Route::patch('{id}/resolve', [NotificationController::class, 'resolve'])->whereNumber('id')->middleware('permission:NOTIFICACIONES_GESTIONAR');
    });
    Route::prefix('contracting')->group(function (): void {
        Route::get('employees', [ContractingController::class, 'indexEmployees'])->middleware('permission:CONTRATACION_VER');
        Route::get('contract-templates', [ContractingController::class, 'listContractTemplates'])->middleware('permission:CONTRATACION_VER');
        Route::get('parameters/minimum-salary', [ContractingController::class, 'minimumSalary'])->middleware('permission:CONTRATACION_CREAR');
        Route::get('contracts/{employeeContractId}/generation-data', [ContractingController::class, 'getContractGenerationData'])->whereNumber('employeeContractId')->middleware('permission:CONTRATACION_VER');
        Route::post('contracts/{employeeContractId}/sign', [ContractingController::class, 'signContract'])->whereNumber('employeeContractId')->middleware('permission:CONTRATACION_EDITAR');
        Route::get('employees/{employeeId}/profile', [ContractingController::class, 'getProfile'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_VER');
        Route::post('employees/{employeeId}/profile', [ContractingController::class, 'saveProfile'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_CREAR,CONTRATACION_EDITAR');
        Route::get('employees/{employeeId}/contracts', [ContractingController::class, 'listContracts'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_HISTORIAL_VER');
        Route::post('employees/{employeeId}/contracts', [ContractingController::class, 'createContract'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_CREAR');
        Route::put('employees/{employeeId}/contracts/{employeeContractId}', [ContractingController::class, 'updateContract'])->whereNumber(['employeeId', 'employeeContractId'])->middleware('permission:CONTRATACION_EDITAR');
        Route::get('employees/{employeeId}/social-security', [ContractingController::class, 'getSocialSecurity'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_SEGURIDAD_SOCIAL_VER');
        Route::post('employees/{employeeId}/social-security', [ContractingController::class, 'saveSocialSecurity'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_SEGURIDAD_SOCIAL_EDITAR');
        Route::get('employees/{employeeId}/medical-exams', [ContractingController::class, 'listMedicalExams'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_EXAMENES_VER');
        Route::post('employees/{employeeId}/medical-exams', [ContractingController::class, 'createMedicalExam'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_EXAMENES_CREAR');
        Route::get('employees/{employeeId}/documents', [ContractingController::class, 'listDocuments'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_DOCUMENTOS_VER');
        Route::post('employees/{employeeId}/documents', [ContractingController::class, 'registerDocument'])->whereNumber('employeeId')->middleware('permission:CONTRATACION_DOCUMENTOS_SUBIR');
        Route::get('alerts', [ContractingController::class, 'listAlerts'])->middleware('permission:CONTRATACION_ALERTAS_VER');
    });
});
