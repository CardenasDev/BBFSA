import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize, forkJoin } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  Area,
  ContractChargeType,
  ContractGenerationData,
  ContractTemplate,
  ContractTemplateDefaultValues,
  ContractTemplateFieldConfig,
  ContractType,
  CreateEmployeeContractRequest,
  EmployeeContract,
  Position,
} from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { CatalogService } from '../../core/services/catalog.service';
import { ContractingService } from '../../core/services/contracting.service';
import { apiErrorMessage } from '../../shared/api-error';

const CONTRACT_STATUSES = ['ACTIVO', 'VENCIDO', 'RENOVADO', 'FINALIZADO', 'ANULADO'];
const CONTRACT_CHARGE_TYPES: ContractChargeType[] = ['ADMINISTRATIVO', 'OPERATIVO', 'OTRO'];
const PAYMENT_PERIODS = ['QUINCENAL', 'MENSUAL', 'SEMANAL', 'OTRO'];
const ESSENTIAL_FIELDS = ['id_tipo_contrato', 'id_plantilla_contrato', 'fecha_inicio', 'observaciones'];
const BASE_FIELDS = [
  ...ESSENTIAL_FIELDS,
  'numero_contrato',
  'id_area',
  'id_cargo',
  'tipo_cargo_contrato',
  'auxilio_transporte',
  'periodo_pago',
  'lugar_labores',
  'salario_base',
  'estado_contrato',
];

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Contratacion</p><h1>Historial contractual</h1><p class="muted">Contratos registrados para el empleado.</p></div>
      <div class="row-actions">
        @if (auth.hasPermission('CONTRATACION_CREAR')) { <button class="btn primary" type="button" (click)="openCreate()">Nuevo contrato</button> }
        <a class="btn ghost" routerLink="/admin/contracting">Volver</a>
      </div>
    </div>

    <section class="panel">
      <div class="row-actions" style="margin-bottom:1rem">
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'profile']">Ficha</a>
        <a class="btn small secondary" [routerLink]="['/admin/contracting/employees', employeeId, 'contracts']">Contratos</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'social-security']">Seguridad social</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'medical-exams']">Examenes</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'documents']">Documentos</a>
      </div>

      @if (success()) { <div class="alert success">{{ success() }}</div> }
      @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }

      <div class="table-wrap">
        <table>
          <thead><tr><th>Tipo contrato</th><th>Plantilla</th><th>Codigo formato</th><th>Version</th><th>Numero contrato</th><th>Fecha inicio</th><th>Fecha fin</th><th>Estado contrato</th><th>Archivo contrato</th><th>Acciones</th></tr></thead>
          <tbody>
            @for (contract of contracts(); track contractKey(contract)) {
              <tr>
                <td><strong>{{ contract.tipo_contrato || displayId(contract.id_tipo_contrato) }}</strong><small class="muted">{{ contract.tipo_cargo_contrato || 'Sin tipo cargo' }}</small></td>
                <td>{{ contract.nombre_plantilla || 'Sin plantilla asociada' }}</td>
                <td>{{ contract.codigo_formato || 'Sin codigo' }}</td>
                <td>{{ contract.version_formato || 'Sin version' }}</td>
                <td>{{ contract.numero_contrato || 'Sin numero' }}</td>
                <td>{{ contract.fecha_inicio }}</td>
                <td>{{ contract.fecha_fin || 'Sin fecha' }}</td>
                <td><span class="badge" [class.success]="contract.estado_contrato === 'ACTIVO'" [class.danger]="contract.estado_contrato === 'VENCIDO' || contract.estado_contrato === 'ANULADO'">{{ contract.estado_contrato || 'Sin estado' }}</span></td>
                <td>
                  @if (getStorageUrl(contract.archivo_contrato_url); as fileUrl) {
                    <a class="btn small ghost" [href]="fileUrl" target="_blank" rel="noopener">Abrir PDF</a>
                  } @else {
                    <span class="muted">Sin PDF generado</span>
                  }
                </td>
                <td class="actions-cell">
                  <button class="btn small ghost" type="button" (click)="toggleDetail(contract)">{{ isExpanded(contract) ? 'Ocultar' : 'Ver detalle' }}</button>
                  <button class="btn small secondary" type="button" (click)="openGenerationData(contract)" [disabled]="generationLoading()">Datos generacion</button>
                  @if (contractId(contract); as printableContractId) {
                    <a
                      class="btn small primary"
                      [routerLink]="['/admin/contracting/contracts', printableContractId, 'print']"
                    >Ver / imprimir contrato</a>
                  } @else {
                    <button class="btn small primary" type="button" [disabled]="true" title="Contrato invalido">Ver / imprimir contrato</button>
                  }
                  @if (getStorageUrl(contract.archivo_contrato_url); as fileUrl) {
                    <a class="btn small ghost" [href]="fileUrl" target="_blank" rel="noopener">Abrir PDF</a>
                  }
                </td>
              </tr>
              @if (isExpanded(contract)) {
                <tr>
                  <td colspan="10">
                    <div class="employee-summary">
                      <div><small>Area</small><span>{{ contract.area || displayId(contract.id_area) }}</span></div>
                      <div><small>Cargo</small><span>{{ contract.cargo || displayId(contract.id_cargo) }}</span></div>
                      <div><small>Lugar labores</small><span>{{ contract.lugar_labores || 'Sin dato' }}</span></div>
                      <div><small>Auxilio transporte</small><span>{{ formatBooleanSiNo(contract.auxilio_transporte) }}</span></div>
                      <div><small>Periodo pago</small><span>{{ contract.periodo_pago || 'Sin dato' }}</span></div>
                      <div><small>Objeto obra/labor</small><span>{{ contract.objeto_obra_labor || 'Sin dato' }}</span></div>
                      <div><small>Prorroga dias</small><span>{{ contract.prorroga_dias ?? 'Sin dato' }}</span></div>
                      <div><small>Jornada laboral</small><span>{{ contract.jornada_laboral || 'Sin dato' }}</span></div>
                      <div><small>Periodo prueba</small><span>{{ contract.periodo_prueba_dias ?? 'Sin dato' }}</span></div>
                      <div><small>Archivo plantilla</small><span>{{ contract.archivo_plantilla_ruta || contract.archivo_plantilla_url || 'Sin dato' }}</span></div>
                      <div><small>Formato salida</small><span>{{ contract.formato_salida_default || 'Sin dato' }}</span></div>
                      <div><small>Archivo contrato</small><span>{{ contract.archivo_contrato_url || 'Sin documento generado' }}</span></div>
                      <div><small>Registrado por</small><span>{{ contract.registrado_por || 'Sin dato' }}</span></div>
                      <div><small>Clausula funciones</small><span>{{ contract.clausula_funciones || 'Sin dato' }}</span></div>
                      <div><small>Observaciones</small><span>{{ contract.observaciones || 'Sin dato' }}</span></div>
                    </div>
                  </td>
                </tr>
              }
            } @empty {
              <tr><td colspan="10" class="empty">{{ loading() ? 'Cargando contratos...' : 'No hay registros para mostrar.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>

    @if (createOpen()) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar contrato" (click)="closeCreate()"></button>
      <aside class="role-drawer" aria-label="Crear contrato" aria-modal="true">
        <header class="drawer-header">
          <div><p class="eyebrow">Nuevo contrato</p><h2>Contrato del empleado</h2></div>
          <button class="icon-btn close-btn" type="button" (click)="closeCreate()" aria-label="Cerrar">x</button>
        </header>

        @if (formError()) { <div class="alert error">{{ formError() }}</div> }
        @if (templateMessage()) { <div class="alert success">{{ templateMessage() }}</div> }
        <form class="form-grid" (ngSubmit)="createContract()">
          <label>Tipo contrato
            <select name="id_tipo_contrato" [(ngModel)]="form.id_tipo_contrato" (ngModelChange)="onContractTypeChange($event)" required>
              <option [ngValue]="null">Seleccione...</option>
              @for (item of contractTypes(); track item.id_tipo_contrato) { <option [ngValue]="item.id_tipo_contrato">{{ item.nombre }}</option> }
            </select>
          </label>

          <label>Tipo cargo contrato
            <select name="tipo_cargo_contrato" [(ngModel)]="form.tipo_cargo_contrato" (ngModelChange)="onChargeTypeChange($event)">
              <option [ngValue]="null">No definido</option>
              @for (item of chargeTypes; track item) { <option [value]="item">{{ item }}</option> }
            </select>
          </label>

          <label class="form-wide">Plantilla contrato
            <select name="id_plantilla_contrato" [(ngModel)]="form.id_plantilla_contrato" (ngModelChange)="onTemplateChange($event)" [disabled]="templatesLoading() || !form.id_tipo_contrato">
              <option [ngValue]="null">{{ templatesLoading() ? 'Cargando plantillas...' : 'Seleccione...' }}</option>
              @for (template of contractTemplates(); track template.id_plantilla_contrato) {
                <option [ngValue]="template.id_plantilla_contrato">{{ templateLabel(template) }}</option>
              }
            </select>
            @if (!templatesLoading() && form.id_tipo_contrato && contractTemplates().length === 0) { <small class="muted">No hay plantillas activas para el tipo de contrato seleccionado.</small> }
          </label>

          @if (selectedTemplate(); as template) {
            <section class="drawer-section form-wide">
              <h3>Plantilla seleccionada</h3>
              <p class="muted">{{ templateLabel(template) }}</p>
              @if (template.descripcion) { <p>{{ template.descripcion }}</p> }
            </section>
          }

          @if (isFieldVisible('numero_contrato')) { <label>Numero de contrato<input name="numero_contrato" [(ngModel)]="form.numero_contrato" maxlength="100" /></label> }
          @if (isFieldVisible('id_area')) {
            <label>Area
              <select name="id_area" [(ngModel)]="form.id_area">
                <option [ngValue]="null">Seleccione...</option>
                @for (item of areas(); track item.id_area) { <option [ngValue]="item.id_area">{{ item.nombre }}</option> }
              </select>
            </label>
          }
          @if (isFieldVisible('id_cargo')) {
            <label>Cargo
              <select name="id_cargo" [(ngModel)]="form.id_cargo">
                <option [ngValue]="null">Seleccione...</option>
                @for (item of positions(); track item.id_cargo) { <option [ngValue]="item.id_cargo">{{ item.nombre }}</option> }
              </select>
            </label>
          }
          @if (isFieldVisible('auxilio_transporte')) {
            <label>Auxilio de transporte
              <select name="auxilio_transporte" [(ngModel)]="form.auxilio_transporte">
                <option [ngValue]="null">No definido</option>
                <option [ngValue]="true">Si</option>
                <option [ngValue]="false">No</option>
              </select>
            </label>
          }
          @if (isFieldVisible('periodo_pago')) {
            <label>Periodo de pago
              <select name="periodo_pago" [(ngModel)]="form.periodo_pago">
                <option [ngValue]="null">No definido</option>
                @for (item of paymentPeriods; track item) { <option [value]="item">{{ item }}</option> }
              </select>
            </label>
          }
          @if (isFieldVisible('lugar_labores')) { <label>Lugar de labores<input name="lugar_labores" [(ngModel)]="form.lugar_labores" maxlength="250" placeholder="VEREDA SAN JOSE, FINCA BARRO BLANCO" /></label> }
          <label>Fecha inicio<input type="date" name="fecha_inicio" [(ngModel)]="form.fecha_inicio" required /></label>
          @if (isFieldVisible('fecha_fin')) { <label>Fecha fin<input type="date" name="fecha_fin" [(ngModel)]="form.fecha_fin" /></label> }
          @if (isFieldVisible('duracion_meses')) { <label>Duracion meses<input type="number" min="0" name="duracion_meses" [(ngModel)]="form.duracion_meses" /></label> }
          @if (isFieldVisible('salario_base')) { <label>Salario base<input type="number" min="0" name="salario_base" [(ngModel)]="form.salario_base" /></label> }
          @if (isFieldVisible('jornada_laboral')) { <label>Jornada laboral<input name="jornada_laboral" [(ngModel)]="form.jornada_laboral" maxlength="150" /></label> }
          @if (isFieldVisible('periodo_prueba_dias')) { <label>Periodo prueba dias<input type="number" min="0" name="periodo_prueba_dias" [(ngModel)]="form.periodo_prueba_dias" /></label> }
          @if (isFieldVisible('prorroga_dias')) { <label>Prorroga dias<input type="number" min="0" name="prorroga_dias" [(ngModel)]="form.prorroga_dias" /></label> }
          @if (isFieldVisible('estado_contrato')) {
            <label>Estado
              <select name="estado_contrato" [(ngModel)]="form.estado_contrato">
                <option [ngValue]="null">Seleccione...</option>
                @for (item of statuses; track item) { <option [value]="item">{{ item }}</option> }
              </select>
            </label>
          }
          @if (isFieldVisible('objeto_obra_labor') || isFieldVisible('clausula_funciones')) {
            <section class="drawer-section form-wide">
              <h3>Datos de obra o labor</h3>
              <p class="muted">{{ workSectionHint() }}</p>
              <div class="form-grid">
                @if (isFieldVisible('objeto_obra_labor')) { <label class="form-wide">Objeto obra/labor<textarea rows="3" name="objeto_obra_labor" [(ngModel)]="form.objeto_obra_labor"></textarea></label> }
                @if (isFieldVisible('clausula_funciones')) { <label class="form-wide">Funciones / clausula de funciones<textarea rows="3" name="clausula_funciones" [(ngModel)]="form.clausula_funciones"></textarea></label> }
              </div>
            </section>
          }
          @if (isFieldVisible('archivo_contrato_url')) { <label class="form-wide">Archivo contrato URL<input name="archivo_contrato_url" [(ngModel)]="form.archivo_contrato_url" maxlength="500" /></label> }
          <label class="form-wide">Observaciones<textarea rows="3" name="observaciones" [(ngModel)]="form.observaciones"></textarea></label>
          <div class="form-actions form-wide">
            <button class="btn secondary" type="button" (click)="closeCreate()" [disabled]="saving()">Cancelar</button>
            <button class="btn primary" type="submit" [disabled]="saving()">{{ saving() ? 'Guardando...' : 'Registrar contrato' }}</button>
          </div>
        </form>
      </aside>
    }

    @if (generationOpen()) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar datos de generacion" (click)="closeGenerationData()"></button>
      <aside class="role-drawer" aria-label="Datos para generacion" aria-modal="true">
        <header class="drawer-header">
          <div><p class="eyebrow">Datos para generacion</p><h2>Contrato preparado</h2></div>
          <button class="icon-btn close-btn" type="button" (click)="closeGenerationData()" aria-label="Cerrar">x</button>
        </header>

        <p class="muted">Estos son los datos preparados para el contrato. Esta vista no genera el archivo; la accion Generar PDF crea el documento final.</p>
        @if (generationError()) { <div class="alert error">{{ generationError() }}</div> }
        @if (generationLoading()) { <section class="panel empty">Cargando datos...</section> }
        @if (generationData(); as data) {
          <section class="drawer-section">
            <h3>Empleado</h3>
            <dl>
              <dt>Nombre completo</dt><dd>{{ field(data.employee, 'nombre_completo') }}</dd>
              <dt>Documento</dt><dd>{{ field(data.employee, 'numero_documento') }}</dd>
              <dt>Direccion</dt><dd>{{ field(data.employee, 'direccion_residencia') }}</dd>
              <dt>Fecha nacimiento</dt><dd>{{ field(data.employee, 'fecha_nacimiento') }}</dd>
              <dt>Lugar nacimiento</dt><dd>{{ field(data.employee, 'lugar_nacimiento') }}</dd>
              <dt>Nacionalidad</dt><dd>{{ field(data.employee, 'nacionalidad') }}</dd>
            </dl>
          </section>
          <section class="drawer-section">
            <h3>Contrato</h3>
            <dl>
              <dt>Tipo contrato</dt><dd>{{ field(data.contract, 'tipo_contrato') }}</dd>
              <dt>Plantilla</dt><dd>{{ field(data.template, 'nombre_plantilla') }}</dd>
              <dt>Codigo formato</dt><dd>{{ field(data.template, 'codigo_formato') }}</dd>
              <dt>Version</dt><dd>{{ field(data.template, 'version_formato') }}</dd>
              <dt>Fecha inicio</dt><dd>{{ field(data.contract, 'fecha_inicio') }}</dd>
              <dt>Fecha fin</dt><dd>{{ field(data.contract, 'fecha_fin') }}</dd>
              <dt>Salario</dt><dd>{{ field(data.contract, 'salario_base') }}</dd>
              <dt>Auxilio transporte</dt><dd>{{ formatBooleanSiNo(value(data.contract, 'auxilio_transporte')) }}</dd>
              <dt>Periodo pago</dt><dd>{{ field(data.contract, 'periodo_pago') }}</dd>
              <dt>Lugar labores</dt><dd>{{ field(data.contract, 'lugar_labores') }}</dd>
              <dt>Cargo</dt><dd>{{ field(data.contract, 'cargo') || field(data.employee, 'cargo') }}</dd>
              <dt>Jornada</dt><dd>{{ field(data.contract, 'jornada_laboral') }}</dd>
            </dl>
          </section>
          <section class="drawer-section">
            <h3>Plantilla</h3>
            <dl>
              <dt>Archivo plantilla</dt><dd>{{ field(data.template, 'archivo_plantilla_ruta') || field(data.template, 'archivo_plantilla_url') }}</dd>
              <dt>Formato salida</dt><dd>{{ field(data.generation, 'formato_salida_default') || field(data.template, 'formato_salida_default') }}</dd>
              <dt>Fecha generacion</dt><dd>{{ field(data.generation, 'fecha_generacion') }}</dd>
            </dl>
          </section>
          <div class="alert success">Los datos estan listos para revision previa a la generacion del documento.</div>
        }
      </aside>
    }
  `,
})
export class ContractingContractsComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly route = inject(ActivatedRoute);
  private readonly service = inject(ContractingService);
  private readonly catalogs = inject(CatalogService);
  readonly contracts = signal<EmployeeContract[]>([]);
  readonly contractTypes = signal<ContractType[]>([]);
  readonly contractTemplates = signal<ContractTemplate[]>([]);
  readonly selectedTemplate = signal<ContractTemplate | null>(null);
  readonly areas = signal<Area[]>([]);
  readonly positions = signal<Position[]>([]);
  readonly loading = signal(false);
  readonly templatesLoading = signal(false);
  readonly saving = signal(false);
  readonly createOpen = signal(false);
  readonly generationOpen = signal(false);
  readonly generationLoading = signal(false);
  readonly generationData = signal<ContractGenerationData | null>(null);
  readonly generatingContractId = signal<number | null>(null);
  readonly error = signal('');
  readonly formError = signal('');
  readonly templateMessage = signal('');
  readonly generationError = signal('');
  readonly success = signal('');
  readonly expandedContract = signal<string | null>(null);
  readonly statuses = CONTRACT_STATUSES;
  readonly chargeTypes = CONTRACT_CHARGE_TYPES;
  readonly paymentPeriods = PAYMENT_PERIODS;
  employeeId = 0;
  form: CreateEmployeeContractRequest = this.emptyForm();

  ngOnInit(): void {
    this.employeeId = Number(this.route.snapshot.paramMap.get('employeeId'));
    this.loadCatalogs();
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.service.getEmployeeContracts(this.employeeId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (contracts) => this.contracts.set(contracts),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar la informacion de contratacion.')),
    });
  }

  loadCatalogs(): void {
    forkJoin({
      contractTypes: this.catalogs.getContractTypes(),
      areas: this.catalogs.getAreas(),
      positions: this.catalogs.getPositions(),
    }).subscribe({
      next: ({ contractTypes, areas, positions }) => {
        this.contractTypes.set(contractTypes);
        this.areas.set(areas);
        this.positions.set(positions);
      },
      error: () => undefined,
    });
  }

  openCreate(): void {
    this.form = this.emptyForm();
    this.contractTemplates.set([]);
    this.selectedTemplate.set(null);
    this.formError.set('');
    this.templateMessage.set('');
    this.success.set('');
    this.createOpen.set(true);
  }

  closeCreate(): void {
    if (this.saving()) return;
    this.createOpen.set(false);
  }

  onContractTypeChange(value: unknown): void {
    this.form.id_tipo_contrato = this.numberOrNull(value);
    this.form.id_plantilla_contrato = null;
    this.selectedTemplate.set(null);
    this.templateMessage.set('');
    this.loadTemplatesForCurrentSelection();
  }

  onChargeTypeChange(value: ContractChargeType | null): void {
    this.form.tipo_cargo_contrato = value;
    this.form.id_plantilla_contrato = null;
    this.selectedTemplate.set(null);
    this.templateMessage.set('');
    this.loadTemplatesForCurrentSelection();
  }

  onTemplateChange(value: unknown): void {
    const templateId = this.numberOrNull(value);
    this.form.id_plantilla_contrato = templateId;
    const template = this.contractTemplates().find((item) => item.id_plantilla_contrato === templateId) ?? null;
    this.selectedTemplate.set(template);
    this.templateMessage.set('');
    if (!template) return;

    this.applyTemplateDefaults(template);
    this.templateMessage.set('Se cargaron valores sugeridos por la plantilla. Puedes ajustarlos antes de guardar.');
  }

  createContract(): void {
    const validation = this.validate();
    if (validation) {
      this.formError.set(validation);
      return;
    }
    this.saving.set(true);
    this.formError.set('');
    this.service.createEmployeeContract(this.employeeId, this.normalize()).pipe(finalize(() => this.saving.set(false))).subscribe({
      next: () => {
        this.success.set('Contrato registrado correctamente.');
        this.form = this.emptyForm();
        this.contractTemplates.set([]);
        this.selectedTemplate.set(null);
        this.createOpen.set(false);
        this.load();
      },
      error: (error) => this.formError.set(apiErrorMessage(error, 'No fue posible registrar el contrato.')),
    });
  }

  openGenerationData(contract: EmployeeContract): void {
    const contractId = this.contractId(contract);
    if (!contractId) {
      this.generationError.set('No fue posible identificar el contrato.');
      this.generationOpen.set(true);
      return;
    }

    this.generationOpen.set(true);
    this.generationLoading.set(true);
    this.generationError.set('');
    this.generationData.set(null);
    this.service.getContractGenerationData(contractId).pipe(finalize(() => this.generationLoading.set(false))).subscribe({
      next: (data) => this.generationData.set(data),
      error: (error) => this.generationError.set(apiErrorMessage(error, 'No fue posible cargar los datos de generacion.')),
    });
  }

  closeGenerationData(): void {
    if (this.generationLoading()) return;
    this.generationOpen.set(false);
  }

  isFieldVisible(fieldName: string): boolean {
    if (ESSENTIAL_FIELDS.includes(fieldName)) return true;
    const template = this.selectedTemplate();
    if (!template) return BASE_FIELDS.includes(fieldName);

    const config = template.config_campos ?? {};
    if (config.campos_ocultos?.includes(fieldName)) return false;
    if (config.campos_visibles?.length) return config.campos_visibles.includes(fieldName);

    return true;
  }

  displayId(value?: number | null): string {
    return value ? `ID ${value}` : 'Sin dato';
  }

  formatBooleanSiNo(value: unknown): string {
    if (value === true || value === 1 || value === '1' || value === 'true') return 'Si';
    if (value === false || value === 0 || value === '0' || value === 'false') return 'No';
    return 'No definido';
  }

  contractKey(contract: EmployeeContract): string {
    return String(contract.id_empleado_contrato ?? contract.id_contrato_empleado ?? `${contract.fecha_inicio}-${contract.numero_contrato ?? ''}`);
  }

  toggleDetail(contract: EmployeeContract): void {
    const key = this.contractKey(contract);
    this.expandedContract.set(this.expandedContract() === key ? null : key);
  }

  isExpanded(contract: EmployeeContract): boolean {
    return this.expandedContract() === this.contractKey(contract);
  }

  canGeneratePdf(contract: EmployeeContract): boolean {
    return !!this.contractId(contract) && !!this.numberOrNull(contract.id_plantilla_contrato);
  }

  pdfDisabledReason(contract: EmployeeContract): string {
    if (!this.contractId(contract)) return 'Contrato invalido.';
    if (!this.numberOrNull(contract.id_plantilla_contrato)) return 'Este contrato no tiene plantilla asociada.';
    return '';
  }

  isGeneratingContract(contract: EmployeeContract): boolean {
    const contractId = this.contractId(contract);
    return !!contractId && this.generatingContractId() === contractId;
  }

  getStorageUrl(path?: string | null): string | null {
    if (!path?.trim()) {
      return null;
    }

    if (/^https?:\/\//i.test(path)) {
      return path;
    }

    const baseUrl = environment.backendUrl.replace(/\/$/, '');
    const normalizedPath = path.replace(/^\/+/, '');

    return `${baseUrl}/storage/${normalizedPath}`;
  }

  generatePdf(contract: EmployeeContract): void {
    const contractId = this.contractId(contract);
    if (!contractId) {
      this.error.set('Contrato invalido.');
      this.success.set('');
      return;
    }

    if (!this.numberOrNull(contract.id_plantilla_contrato)) {
      this.error.set('Este contrato no tiene plantilla asociada.');
      this.success.set('');
      return;
    }

    if (this.generatingContractId() === contractId) {
      return;
    }

    const hasGeneratedFile = !!this.getStorageUrl(contract.archivo_contrato_url);
    const confirmed = hasGeneratedFile
      ? window.confirm('Este contrato ya tiene un PDF generado. ¿Deseas generar uno nuevo?')
      : window.confirm('¿Deseas generar el PDF de este contrato?');

    if (!confirmed) {
      return;
    }

    this.generatingContractId.set(contractId);
    this.error.set('');
    this.success.set('');

    this.service.generateContractPdf(contractId).pipe(
      finalize(() => this.generatingContractId.set(null)),
    ).subscribe({
      next: (response) => {
        const generatedPath = response.archivo_contrato_url || response.archivo_generado_url || null;
        this.updateGeneratedContractFile(contractId, generatedPath);
        this.success.set('Contrato PDF generado correctamente. Documento disponible para revision y firma.');
        this.load();
      },
      error: () => {
        this.error.set('No fue posible generar el PDF del contrato. Verifica que el contrato tenga plantilla asociada y datos completos.');
      },
    });
  }

  templateLabel(template: ContractTemplate): string {
    return [template.codigo_formato, template.nombre_plantilla, template.tipo_cargo_contrato].filter(Boolean).join(' - ');
  }

  workSectionHint(): string {
    if (this.form.tipo_cargo_contrato === 'OPERATIVO' || this.selectedContractTypeLooksLikeWork()) {
      return 'Estos datos ayudan a describir contratos por obra o labor.';
    }
    if (this.form.tipo_cargo_contrato === 'ADMINISTRATIVO') {
      return 'Usa la clausula para registrar funciones administrativas del cargo.';
    }
    return 'Completa estos campos cuando el contrato lo requiera.';
  }

  field(source: unknown, key: string): string {
    const value = this.value(source, key);
    return value === null || value === undefined || value === '' ? 'Sin dato' : String(value);
  }

  value(source: unknown, key: string): unknown {
    if (!source || typeof source !== 'object') return null;
    return (source as Record<string, unknown>)[key] ?? null;
  }

  private loadTemplatesForCurrentSelection(): void {
    const contractTypeId = this.numberOrNull(this.form.id_tipo_contrato);
    if (!contractTypeId) {
      this.contractTemplates.set([]);
      return;
    }

    this.templatesLoading.set(true);
    this.service.getContractTemplates({
      id_tipo_contrato: contractTypeId,
      tipo_cargo_contrato: this.form.tipo_cargo_contrato ?? null,
      solo_activas: 1,
    }).pipe(finalize(() => this.templatesLoading.set(false))).subscribe({
      next: (templates) => {
        this.contractTemplates.set(templates);
        if (templates.length === 0) this.templateMessage.set('');
      },
      error: (error) => this.formError.set(apiErrorMessage(error, 'No fue posible cargar las plantillas de contrato.')),
    });
  }

  private applyTemplateDefaults(template: ContractTemplate): void {
    const defaults = template.valores_default ?? {};
    this.applyDefaultValue(defaults, 'auxilio_transporte');
    this.applyDefaultValue(defaults, 'periodo_pago');
    this.applyDefaultValue(defaults, 'lugar_labores');
    this.applyDefaultValue(defaults, 'tipo_cargo_contrato');
    this.applyDefaultValue(defaults, 'duracion_meses');
    this.applyDefaultValue(defaults, 'jornada_laboral');
    this.applyDefaultValue(defaults, 'periodo_prueba_dias');
    this.applyDefaultValue(defaults, 'objeto_obra_labor');
    this.applyDefaultValue(defaults, 'prorroga_dias');
  }

  private applyDefaultValue(defaults: ContractTemplateDefaultValues, field: keyof ContractTemplateDefaultValues): void {
    const value = defaults[field];
    if (value === null || value === undefined || value === '') return;

    const form = this.form as unknown as Record<string, unknown>;
    const current = form[field];
    if (current === null || current === undefined || current === '') {
      form[field] = value;
    }
  }

  private validate(): string {
    const config = this.selectedTemplate()?.config_campos ?? {};
    if (!this.form.id_tipo_contrato) return 'El tipo de contrato es obligatorio.';
    if (this.contractTemplates().length > 0 && !this.form.id_plantilla_contrato) return 'Selecciona una plantilla para el contrato.';
    if (!this.form.fecha_inicio) return 'La fecha de inicio es obligatoria.';
    if (this.isFieldVisible('fecha_fin') && this.form.fecha_fin && this.form.fecha_fin < this.form.fecha_inicio) return 'La fecha fin no puede ser menor que la fecha inicio.';
    if (Number(this.form.salario_base ?? 0) < 0) return 'El salario base debe ser mayor o igual a cero.';
    if (Number(this.form.duracion_meses ?? 0) < 0) return 'La duracion en meses debe ser mayor o igual a cero.';
    if (Number(this.form.periodo_prueba_dias ?? 0) < 0) return 'El periodo de prueba debe ser mayor o igual a cero.';
    if (Number(this.form.prorroga_dias ?? 0) < 0) return 'La prorroga en dias debe ser mayor o igual a cero.';
    if ((this.form.numero_contrato ?? '').length > 100) return 'El numero de contrato no puede superar 100 caracteres.';
    if ((this.form.periodo_pago ?? '').length > 100) return 'El periodo de pago no puede superar 100 caracteres.';
    if ((this.form.lugar_labores ?? '').length > 250) return 'El lugar de labores no puede superar 250 caracteres.';
    if ((this.form.jornada_laboral ?? '').length > 150) return 'La jornada laboral no puede superar 150 caracteres.';
    if (this.form.tipo_cargo_contrato && !CONTRACT_CHARGE_TYPES.includes(this.form.tipo_cargo_contrato)) return 'El tipo cargo contrato no es valido.';
    return this.validateTemplateRequirements(config);
  }

  private validateTemplateRequirements(config: ContractTemplateFieldConfig): string {
    if (config.requiere_fecha_fin && !this.form.fecha_fin) return 'La plantilla seleccionada requiere fecha fin.';
    if (config.requiere_duracion_meses && this.form.duracion_meses == null) return 'La plantilla seleccionada requiere duracion en meses.';
    if (config.requiere_prorroga_dias && this.form.prorroga_dias == null) return 'La plantilla seleccionada requiere prorroga en dias.';
    if (config.requiere_objeto_obra_labor && !this.stringOrNull(this.form.objeto_obra_labor)) return 'La plantilla seleccionada requiere objeto de obra o labor.';
    if (config.requiere_periodo_prueba_dias && this.form.periodo_prueba_dias == null) return 'La plantilla seleccionada requiere periodo de prueba.';
    if (config.requiere_clausula_funciones && !this.stringOrNull(this.form.clausula_funciones)) return 'La plantilla seleccionada requiere clausula de funciones.';
    return '';
  }

  private normalize(): CreateEmployeeContractRequest {
    return {
      id_tipo_contrato: this.numberOrNull(this.form.id_tipo_contrato),
      id_plantilla_contrato: this.numberOrNull(this.form.id_plantilla_contrato),
      id_area: this.numberOrNull(this.form.id_area),
      id_cargo: this.numberOrNull(this.form.id_cargo),
      fecha_inicio: this.stringOrNull(this.form.fecha_inicio) ?? '',
      fecha_fin: this.visibleStringOrNull('fecha_fin', this.form.fecha_fin),
      duracion_meses: this.visibleNumberOrNull('duracion_meses', this.form.duracion_meses),
      salario_base: this.visibleNumberOrNull('salario_base', this.form.salario_base),
      auxilio_transporte: this.isFieldVisible('auxilio_transporte') ? this.booleanOrNull(this.form.auxilio_transporte) : null,
      periodo_pago: this.visibleStringOrNull('periodo_pago', this.form.periodo_pago),
      lugar_labores: this.visibleStringOrNull('lugar_labores', this.form.lugar_labores),
      numero_contrato: this.visibleStringOrNull('numero_contrato', this.form.numero_contrato),
      tipo_cargo_contrato: this.isFieldVisible('tipo_cargo_contrato') ? this.form.tipo_cargo_contrato ?? null : null,
      objeto_obra_labor: this.visibleStringOrNull('objeto_obra_labor', this.form.objeto_obra_labor),
      prorroga_dias: this.visibleNumberOrNull('prorroga_dias', this.form.prorroga_dias),
      clausula_funciones: this.visibleStringOrNull('clausula_funciones', this.form.clausula_funciones),
      jornada_laboral: this.visibleStringOrNull('jornada_laboral', this.form.jornada_laboral),
      periodo_prueba_dias: this.visibleNumberOrNull('periodo_prueba_dias', this.form.periodo_prueba_dias),
      estado_contrato: this.visibleStringOrNull('estado_contrato', this.form.estado_contrato),
      archivo_contrato_url: this.visibleStringOrNull('archivo_contrato_url', this.form.archivo_contrato_url),
      observaciones: this.stringOrNull(this.form.observaciones),
    };
  }

  private emptyForm(): CreateEmployeeContractRequest {
    return {
      id_tipo_contrato: null,
      id_plantilla_contrato: null,
      fecha_inicio: new Date().toISOString().slice(0, 10),
      estado_contrato: 'ACTIVO',
      auxilio_transporte: null,
      tipo_cargo_contrato: null,
    };
  }

  private numberOrNull(value: unknown): number | null {
    const numberValue = Number(value);
    return Number.isFinite(numberValue) && value !== '' && value !== null && value !== undefined ? numberValue : null;
  }

  private visibleNumberOrNull(field: string, value: unknown): number | null {
    return this.isFieldVisible(field) ? this.numberOrNull(value) : null;
  }

  private stringOrNull(value: unknown): string | null {
    return typeof value === 'string' && value.trim() !== '' ? value.trim() : null;
  }

  private visibleStringOrNull(field: string, value: unknown): string | null {
    return this.isFieldVisible(field) ? this.stringOrNull(value) : null;
  }

  private booleanOrNull(value: unknown): boolean | null {
    if (value === true || value === 'true' || value === 1 || value === '1') return true;
    if (value === false || value === 'false' || value === 0 || value === '0') return false;
    return null;
  }

  contractId(contract: EmployeeContract): number | null {
    return this.numberOrNull(contract.id_empleado_contrato ?? contract.id_contrato_empleado);
  }

  private updateGeneratedContractFile(contractId: number, archivoContratoUrl: string | null): void {
    if (!archivoContratoUrl) {
      return;
    }

    this.contracts.set(this.contracts().map((contract) => {
      if (this.contractId(contract) !== contractId) {
        return contract;
      }

      return {
        ...contract,
        archivo_contrato_url: archivoContratoUrl,
      };
    }));
  }

  private selectedContractTypeLooksLikeWork(): boolean {
    const selected = this.contractTypes().find((item) => item.id_tipo_contrato === this.numberOrNull(this.form.id_tipo_contrato));
    const name = selected?.nombre?.toUpperCase() ?? '';
    return name.includes('OBRA') || name.includes('LABOR');
  }
}
