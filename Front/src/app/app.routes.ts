import { Routes } from '@angular/router';
import {
  authGuard,
  guestGuard,
  passwordChangeGuard,
  permissionGuard,
} from './core/guards/auth.guards';
import { AdminLayoutComponent } from './layout/admin-layout.component';

export const routes: Routes = [
  {
    path: 'login',
    canActivate: [guestGuard],
    loadComponent: () => import('./features/auth/login.component').then((m) => m.LoginComponent),
  },
  {
    path: 'admin/contracting/contracts/:employeeContractId/print',
    canActivate: [authGuard, permissionGuard],
    data: { permissions: ['CONTRATACION_VER'] },
    loadComponent: () =>
      import('./contracts/pages/contract-print.component').then((m) => m.ContractPrintComponent),
  },
  {
    path: 'admin/trainings/commitments/:commitmentId/print',
    canActivate: [authGuard, permissionGuard],
    data: { permissions: ['CAPACITACIONES_COMPROMISOS'] },
    loadComponent: () =>
      import('./features/trainings/training-commitment-print.component').then(
        (m) => m.TrainingCommitmentPrintComponent,
      ),
  },
  {
    path: 'admin',
    canActivate: [authGuard],
    canActivateChild: [passwordChangeGuard],
    component: AdminLayoutComponent,
    children: [
      {
        path: 'dashboard',
        loadComponent: () =>
          import('./features/dashboard/dashboard.component').then((m) => m.DashboardComponent),
      },
      {
        path: 'applicants',
        canActivate: [permissionGuard],
        data: { permissions: ['ASPIRANTES_VER'] },
        loadComponent: () =>
          import('./features/applicants/applicants-list.component').then(
            (m) => m.ApplicantsListComponent,
          ),
      },
      {
        path: 'applicants/create',
        canActivate: [permissionGuard],
        data: { permissions: ['ASPIRANTES_CREAR'] },
        loadComponent: () =>
          import('./features/applicants/applicant-form.component').then(
            (m) => m.ApplicantFormComponent,
          ),
      },
      {
        path: 'applicants/:applicantId',
        canActivate: [permissionGuard],
        data: { permissions: ['ASPIRANTES_VER'] },
        loadComponent: () =>
          import('./features/applicants/applicant-detail.component').then(
            (m) => m.ApplicantDetailComponent,
          ),
      },
      {
        path: 'applicants/:applicantId/edit',
        canActivate: [permissionGuard],
        data: { permissions: ['ASPIRANTES_EDITAR'] },
        loadComponent: () =>
          import('./features/applicants/applicant-form.component').then(
            (m) => m.ApplicantFormComponent,
          ),
      },
      {
        path: 'applicants/:applicantId/documents',
        canActivate: [permissionGuard],
        data: { permissions: ['ASPIRANTES_DOCUMENTOS_VER'] },
        loadComponent: () =>
          import('./features/applicants/applicant-documents.component').then(
            (m) => m.ApplicantDocumentsComponent,
          ),
      },
      {
        path: 'applicants/:applicantId/history',
        canActivate: [permissionGuard],
        data: { permissions: ['ASPIRANTES_VER'] },
        loadComponent: () =>
          import('./features/applicants/applicant-history.component').then(
            (m) => m.ApplicantHistoryComponent,
          ),
      },
      {
        path: 'applicants/:applicantId/convert',
        canActivate: [permissionGuard],
        data: { permissions: ['ASPIRANTES_CONVERTIR_EMPLEADO'] },
        loadComponent: () =>
          import('./features/applicants/applicant-convert.component').then(
            (m) => m.ApplicantConvertComponent,
          ),
      },
      {
        path: 'employees',
        canActivate: [permissionGuard],
        data: { permissions: ['EMPLEADOS_LISTAR', 'EMPLEADOS_VER'] },
        loadComponent: () =>
          import('./features/employees/employees.component').then((m) => m.EmployeesComponent),
      },
      {
        path: 'bulk-load',
        canActivate: [permissionGuard],
        data: { permissions: ['EMPLEADOS_VER', 'EMPLEADOS_CREAR'] },
        loadComponent: () =>
          import('./features/bulk-load/bulk-load.component').then((m) => m.BulkLoadComponent),
      },
      {
        path: 'bulk-load/employees',
        canActivate: [permissionGuard],
        data: { permissions: ['EMPLEADOS_VER', 'EMPLEADOS_CREAR'] },
        loadComponent: () =>
          import('./features/bulk-load/employee-bulk-load.component').then(
            (m) => m.EmployeeBulkLoadComponent,
          ),
      },
      {
        path: 'tools',
        canActivate: [permissionGuard],
        data: { permissions: ['HERRAMIENTAS_LISTAR'] },
        loadComponent: () =>
          import('./features/tools/tools.component').then((m) => m.ToolsComponent),
      },
      {
        path: 'tool-deliveries',
        canActivate: [permissionGuard],
        data: { permissions: ['HERRAMIENTAS_LISTAR'] },
        loadComponent: () =>
          import('./features/tools/tool-deliveries.component').then(
            (m) => m.ToolDeliveriesComponent,
          ),
      },
      {
        path: 'tool-deliveries/create',
        canActivate: [permissionGuard],
        data: { permissions: ['HERRAMIENTAS_ENTREGAR'] },
        loadComponent: () =>
          import('./features/tools/tool-delivery-create.component').then(
            (m) => m.ToolDeliveryCreateComponent,
          ),
      },
      {
        path: 'tool-deliveries/:id',
        canActivate: [permissionGuard],
        data: { permissions: ['HERRAMIENTAS_LISTAR'] },
        loadComponent: () =>
          import('./features/tools/tool-delivery-detail.component').then(
            (m) => m.ToolDeliveryDetailComponent,
          ),
      },
      {
        path: 'my-tool-deliveries',
        canActivate: [permissionGuard],
        data: { permissions: ['HERRAMIENTAS_MIS_ENTREGAS_VER'] },
        loadComponent: () =>
          import('./features/tools/my-tool-deliveries.component').then(
            (m) => m.MyToolDeliveriesComponent,
          ),
      },
      {
        path: 'my-tool-deliveries/:id',
        canActivate: [permissionGuard],
        data: { permissions: ['HERRAMIENTAS_MIS_ENTREGAS_VER'] },
        loadComponent: () =>
          import('./features/tools/my-tool-delivery-detail.component').then(
            (m) => m.MyToolDeliveryDetailComponent,
          ),
      },
      {
        path: 'dotations/my-sizes',
        canActivate: [permissionGuard],
        data: { permissions: ['DOTACIONES_MIS_TALLAS_VER'] },
        loadComponent: () =>
          import('./features/dotations/my-sizes.component').then((m) => m.MyDotationSizesComponent),
      },
      {
        path: 'dotations/my-deliveries',
        canActivate: [permissionGuard],
        data: { permissions: ['DOTACIONES_MIS_ENTREGAS_VER'] },
        loadComponent: () =>
          import('./features/dotations/my-deliveries.component').then(
            (m) => m.MyDotationDeliveriesComponent,
          ),
      },
      {
        path: 'dotations/employees',
        canActivate: [permissionGuard],
        data: { permissions: ['DOTACIONES_ADMIN_VER'] },
        loadComponent: () =>
          import('./features/dotations/dotation-employees.component').then(
            (m) => m.DotationEmployeesComponent,
          ),
      },
      {
        path: 'dotations/employees/:employeeId/history',
        canActivate: [permissionGuard],
        data: { permissions: ['DOTACIONES_EMPLEADO_VER'] },
        loadComponent: () =>
          import('./features/dotations/employee-history.component').then(
            (m) => m.EmployeeDotationHistoryComponent,
          ),
      },
      {
        path: 'dotations/employees/:employeeId/sizes',
        canActivate: [permissionGuard],
        data: { permissions: ['DOTACIONES_EMPLEADO_VER'] },
        loadComponent: () =>
          import('./features/dotations/employee-sizes.component').then(
            (m) => m.EmployeeDotationSizesComponent,
          ),
      },
      {
        path: 'dotations/deliveries',
        canActivate: [permissionGuard],
        data: { permissions: ['DOTACIONES_ENTREGAS_VER'] },
        loadComponent: () =>
          import('./features/dotations/deliveries.component').then(
            (m) => m.DotationDeliveriesComponent,
          ),
      },
      {
        path: 'dotations/deliveries/create',
        canActivate: [permissionGuard],
        data: { permissions: ['DOTACIONES_ENTREGAS_CREAR'] },
        loadComponent: () =>
          import('./features/dotations/delivery-create.component').then(
            (m) => m.DotationDeliveryCreateComponent,
          ),
      },
      {
        path: 'dotations/deliveries/:deliveryId',
        canActivate: [permissionGuard],
        data: { permissions: ['DOTACIONES_ENTREGAS_VER'] },
        loadComponent: () =>
          import('./features/dotations/delivery-detail.component').then(
            (m) => m.DotationDeliveryDetailComponent,
          ),
      },
      {
        path: 'returns',
        canActivate: [permissionGuard],
        data: { permissions: ['DEVOLUCIONES_VER'] },
        loadComponent: () =>
          import('./features/returns/returns.component').then((m) => m.ReturnsComponent),
      },
      {
        path: 'returns/create',
        canActivate: [permissionGuard],
        data: { permissions: ['DEVOLUCIONES_CREAR'] },
        loadComponent: () =>
          import('./features/returns/return-create.component').then((m) => m.ReturnCreateComponent),
      },
      {
        path: 'returns/:id',
        canActivate: [permissionGuard],
        data: { permissions: ['DEVOLUCIONES_VER'] },
        loadComponent: () =>
          import('./features/returns/return-detail.component').then((m) => m.ReturnDetailComponent),
      },
      {
        path: 'trainings',
        canActivate: [permissionGuard],
        data: { permissions: ['CAPACITACIONES_VER'] },
        loadComponent: () =>
          import('./features/trainings/training-sessions.component').then(
            (m) => m.TrainingSessionsComponent,
          ),
      },
      {
        path: 'trainings/catalog',
        canActivate: [permissionGuard],
        data: { permissions: ['CAPACITACIONES_VER'] },
        loadComponent: () =>
          import('./features/trainings/training-catalog.component').then(
            (m) => m.TrainingCatalogComponent,
          ),
      },
      {
        path: 'trainings/sessions',
        canActivate: [permissionGuard],
        data: { permissions: ['CAPACITACIONES_VER'] },
        loadComponent: () =>
          import('./features/trainings/training-sessions.component').then(
            (m) => m.TrainingSessionsComponent,
          ),
      },
      {
        path: 'trainings/sessions/:sessionId',
        canActivate: [permissionGuard],
        data: { permissions: ['CAPACITACIONES_VER'] },
        loadComponent: () =>
          import('./features/trainings/training-session-detail.component').then(
            (m) => m.TrainingSessionDetailComponent,
          ),
      },
      {
        path: 'trainings/follow-up',
        canActivate: [permissionGuard],
        data: { permissions: ['CAPACITACIONES_VER', 'CAPACITACIONES_COMPROMISOS'] },
        loadComponent: () =>
          import('./features/trainings/training-follow-up.component').then(
            (m) => m.TrainingFollowUpComponent,
          ),
      },
      {
        path: 'trainings/my-records',
        canActivate: [permissionGuard],
        data: { permissions: ['CAPACITACIONES_MIS_REGISTROS_VER'] },
        loadComponent: () =>
          import('./features/trainings/my-trainings.component').then((m) => m.MyTrainingsComponent),
      },
      {
        path: 'contracting',
        canActivate: [permissionGuard],
        data: { permissions: ['CONTRATACION_VER'] },
        loadComponent: () =>
          import('./features/contracting/contracting-employees.component').then(
            (m) => m.ContractingEmployeesComponent,
          ),
      },
      {
        path: 'contracting/contracts/:employeeContractId/preview',
        canActivate: [permissionGuard],
        data: { permissions: ['CONTRATACION_VER'] },
        loadComponent: () =>
          import('./contracts/pages/contract-preview.component').then(
            (m) => m.ContractPreviewComponent,
          ),
      },
      {
        path: 'contracting/employees/:employeeId/profile',
        canActivate: [permissionGuard],
        data: { permissions: ['CONTRATACION_VER'] },
        loadComponent: () =>
          import('./features/contracting/contracting-profile.component').then(
            (m) => m.ContractingProfileComponent,
          ),
      },
      {
        path: 'contracting/employees/:employeeId/contracts',
        canActivate: [permissionGuard],
        data: { permissions: ['CONTRATACION_HISTORIAL_VER'] },
        loadComponent: () =>
          import('./features/contracting/contracting-contracts.component').then(
            (m) => m.ContractingContractsComponent,
          ),
      },
      {
        path: 'contracting/employees/:employeeId/social-security',
        canActivate: [permissionGuard],
        data: { permissions: ['CONTRATACION_SEGURIDAD_SOCIAL_VER'] },
        loadComponent: () =>
          import('./features/contracting/contracting-social-security.component').then(
            (m) => m.ContractingSocialSecurityComponent,
          ),
      },
      {
        path: 'contracting/employees/:employeeId/medical-exams',
        canActivate: [permissionGuard],
        data: { permissions: ['CONTRATACION_EXAMENES_VER'] },
        loadComponent: () =>
          import('./features/contracting/contracting-medical-exams.component').then(
            (m) => m.ContractingMedicalExamsComponent,
          ),
      },
      {
        path: 'contracting/employees/:employeeId/documents',
        canActivate: [permissionGuard],
        data: { permissions: ['CONTRATACION_DOCUMENTOS_VER'] },
        loadComponent: () =>
          import('./features/contracting/contracting-documents.component').then(
            (m) => m.ContractingDocumentsComponent,
          ),
      },
      {
        path: 'contracting/alerts',
        canActivate: [permissionGuard],
        data: { permissions: ['CONTRATACION_ALERTAS_VER'] },
        loadComponent: () =>
          import('./features/contracting/contracting-alerts.component').then(
            (m) => m.ContractingAlertsComponent,
          ),
      },
      {
        path: 'users',
        canActivate: [permissionGuard],
        data: { permissions: ['USUARIOS_LISTAR', 'USUARIOS_VER'] },
        loadComponent: () =>
          import('./features/users/users.component').then((m) => m.UsersComponent),
      },
      {
        path: 'users/create',
        canActivate: [permissionGuard],
        data: { permissions: ['USUARIOS_CREAR'] },
        loadComponent: () =>
          import('./features/users/user-create.component').then((m) => m.UserCreateComponent),
      },
      {
        path: 'users/:id',
        canActivate: [permissionGuard],
        data: { permissions: ['USUARIOS_VER'] },
        loadComponent: () =>
          import('./features/users/user-detail.component').then((m) => m.UserDetailComponent),
      },
      {
        path: 'roles',
        canActivate: [permissionGuard],
        data: { permissions: ['ROLES_LISTAR', 'ROLES_VER'] },
        loadComponent: () =>
          import('./features/catalogs/roles.component').then((m) => m.RolesComponent),
      },
      {
        path: 'domains',
        canActivate: [permissionGuard],
        data: { permissions: ['DOMINIOS_LISTAR'] },
        loadComponent: () =>
          import('./features/catalogs/domains.component').then((m) => m.DomainsComponent),
      },
      {
        path: 'permissions',
        canActivate: [permissionGuard],
        data: { permissions: ['PERMISOS_LISTAR', 'PERMISOS_VER'] },
        loadComponent: () =>
          import('./features/catalogs/permissions.component').then((m) => m.PermissionsComponent),
      },
      {
        path: 'parameters',
        canActivate: [permissionGuard],
        data: { permissions: ['PARAMETROS_VER'] },
        loadComponent: () => import('./features/parameters/parameters.component').then((m) => m.ParametersComponent),
      },
      {
        path: 'parameters/areas',
        canActivate: [permissionGuard],
        data: { permissions: ['PARAMETROS_VER'] },
        loadComponent: () => import('./features/parameters/areas.component').then((m) => m.ParametersAreasComponent),
      },
      {
        path: 'parameters/positions',
        canActivate: [permissionGuard],
        data: { permissions: ['PARAMETROS_VER'] },
        loadComponent: () => import('./features/parameters/positions.component').then((m) => m.ParametersPositionsComponent),
      },
      {
        path: 'parameters/contract-types',
        canActivate: [permissionGuard],
        data: { permissions: ['PARAMETROS_VER'] },
        loadComponent: () => import('./features/parameters/contract-types.component').then((m) => m.ParametersContractTypesComponent),
      },
      {
        path: 'parameters/document-types',
        canActivate: [permissionGuard],
        data: { permissions: ['PARAMETROS_VER'] },
        loadComponent: () => import('./features/parameters/document-types.component').then((m) => m.ParametersDocumentTypesComponent),
      },
      {
        path: 'parameters/labor-document-types',
        canActivate: [permissionGuard],
        data: { permissions: ['PARAMETROS_VER'] },
        loadComponent: () => import('./features/parameters/labor-document-types.component').then((m) => m.ParametersLaborDocumentTypesComponent),
      },
      {
        path: 'parameters/social-security-entities',
        canActivate: [permissionGuard],
        data: { permissions: ['PARAMETROS_VER'] },
        loadComponent: () => import('./features/parameters/social-security-entities.component').then((m) => m.ParametersSocialSecurityEntitiesComponent),
      },
      {
        path: 'parameters/medical-exam-types',
        canActivate: [permissionGuard],
        data: { permissions: ['PARAMETROS_VER'] },
        loadComponent: () => import('./features/parameters/medical-exam-types.component').then((m) => m.ParametersMedicalExamTypesComponent),
      },
      {
        path: 'parameters/uniform-items',
        canActivate: [permissionGuard],
        data: { permissions: ['PARAMETROS_VER'] },
        loadComponent: () => import('./features/parameters/uniform-items.component').then((m) => m.ParametersUniformItemsComponent),
      },
      {
        path: 'parameters/system',
        canActivate: [permissionGuard],
        data: { permissions: ['PARAMETROS_VER'] },
        loadComponent: () => import('./features/parameters/system-parameters.component').then((m) => m.ParametersSystemParametersComponent),
      },
      {
        path: 'profile',
        loadComponent: () =>
          import('./features/profile/profile.component').then((m) => m.ProfileComponent),
      },
      {
        path: 'change-password',
        loadComponent: () =>
          import('./features/profile/change-password.component').then(
            (m) => m.ChangePasswordComponent,
          ),
      },
      {
        path: 'unauthorized',
        loadComponent: () =>
          import('./features/system/system-pages.component').then((m) => m.UnauthorizedComponent),
      },
      { path: '', pathMatch: 'full', redirectTo: 'dashboard' },
    ],
  },
  { path: '', pathMatch: 'full', redirectTo: 'login' },
  { path: '**', redirectTo: 'login' },
];
