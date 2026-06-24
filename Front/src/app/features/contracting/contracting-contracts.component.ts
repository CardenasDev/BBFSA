import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize, forkJoin } from 'rxjs';
import { Area, ContractChargeType, ContractType, CreateEmployeeContractRequest, EmployeeContract, Position } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { CatalogService } from '../../core/services/catalog.service';
import { ContractingService } from '../../core/services/contracting.service';
import { apiErrorMessage } from '../../shared/api-error';

const CONTRACT_STATUSES = ['ACTIVO', 'VENCIDO', 'RENOVADO', 'FINALIZADO', 'ANULADO'];
const CONTRACT_CHARGE_TYPES: ContractChargeType[] = ['ADMINISTRATIVO', 'OPERATIVO', 'OTRO'];
const PAYMENT_PERIODS = ['QUINCENAL', 'MENSUAL', 'SEMANAL', 'OTRO'];

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
          <thead><tr><th>Numero</th><th>Tipo</th><th>Cargo</th><th>Area</th><th>Inicio</th><th>Fin</th><th>Estado</th><th>Salario</th><th>Auxilio</th><th>Periodo pago</th><th>Acciones</th></tr></thead>
          <tbody>
            @for (contract of contracts(); track contractKey(contract)) {
              <tr>
                <td><strong>{{ contract.numero_contrato || 'Sin numero' }}</strong><small class="muted">{{ contract.tipo_cargo_contrato || 'Sin tipo cargo' }}</small></td>
                <td>{{ contract.tipo_contrato || displayId(contract.id_tipo_contrato) }}</td>
                <td>{{ contract.cargo || displayId(contract.id_cargo) }}</td>
                <td>{{ contract.area || displayId(contract.id_area) }}</td>
                <td>{{ contract.fecha_inicio }}</td>
                <td>{{ contract.fecha_fin || 'Sin fecha' }}</td>
                <td><span class="badge" [class.success]="contract.estado_contrato === 'ACTIVO'" [class.danger]="contract.estado_contrato === 'VENCIDO' || contract.estado_contrato === 'ANULADO'">{{ contract.estado_contrato || 'Sin estado' }}</span></td>
                <td>{{ contract.salario_base ?? 'Sin dato' }}</td>
                <td>{{ formatBooleanSiNo(contract.auxilio_transporte) }}</td>
                <td>{{ contract.periodo_pago || 'Sin dato' }}</td>
                <td><button class="btn small ghost" type="button" (click)="toggleDetail(contract)">{{ isExpanded(contract) ? 'Ocultar' : 'Ver detalle' }}</button></td>
              </tr>
              @if (isExpanded(contract)) {
                <tr>
                  <td colspan="11">
                    <div class="employee-summary">
                      <div><small>Lugar labores</small><span>{{ contract.lugar_labores || 'Sin dato' }}</span></div>
                      <div><small>Objeto obra/labor</small><span>{{ contract.objeto_obra_labor || 'Sin dato' }}</span></div>
                      <div><small>Prorroga dias</small><span>{{ contract.prorroga_dias ?? 'Sin dato' }}</span></div>
                      <div><small>Jornada laboral</small><span>{{ contract.jornada_laboral || 'Sin dato' }}</span></div>
                      <div><small>Periodo prueba</small><span>{{ contract.periodo_prueba_dias ?? 'Sin dato' }}</span></div>
                      <div><small>Registrado por</small><span>{{ contract.registrado_por || 'Sin dato' }}</span></div>
                      <div><small>Clausula funciones</small><span>{{ contract.clausula_funciones || 'Sin dato' }}</span></div>
                      <div><small>Observaciones</small><span>{{ contract.observaciones || 'Sin dato' }}</span></div>
                      <div><small>Archivo contrato</small><span>@if (contract.archivo_contrato_url) { <a [href]="contract.archivo_contrato_url" target="_blank" rel="noopener">Abrir archivo</a> } @else { Sin archivo }</span></div>
                    </div>
                  </td>
                </tr>
              }
            } @empty {
              <tr><td colspan="11" class="empty">{{ loading() ? 'Cargando contratos...' : 'No hay registros para mostrar.' }}</td></tr>
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
        <form class="form-grid" (ngSubmit)="createContract()">
          <label>Tipo contrato
            <select name="id_tipo_contrato" [(ngModel)]="form.id_tipo_contrato">
              <option [ngValue]="null">Seleccione...</option>
              @for (item of contractTypes(); track item.id_tipo_contrato) { <option [ngValue]="item.id_tipo_contrato">{{ item.nombre }}</option> }
            </select>
          </label>
          <label>Numero de contrato<input name="numero_contrato" [(ngModel)]="form.numero_contrato" maxlength="100" /></label>
          <label>Area
            <select name="id_area" [(ngModel)]="form.id_area">
              <option [ngValue]="null">Seleccione...</option>
              @for (item of areas(); track item.id_area) { <option [ngValue]="item.id_area">{{ item.nombre }}</option> }
            </select>
          </label>
          <label>Cargo
            <select name="id_cargo" [(ngModel)]="form.id_cargo">
              <option [ngValue]="null">Seleccione...</option>
              @for (item of positions(); track item.id_cargo) { <option [ngValue]="item.id_cargo">{{ item.nombre }}</option> }
            </select>
          </label>
          <label>Tipo cargo contrato
            <select name="tipo_cargo_contrato" [(ngModel)]="form.tipo_cargo_contrato">
              <option [ngValue]="null">No definido</option>
              @for (item of chargeTypes; track item) { <option [value]="item">{{ item }}</option> }
            </select>
          </label>
          <label>Auxilio de transporte
            <select name="auxilio_transporte" [(ngModel)]="form.auxilio_transporte">
              <option [ngValue]="null">No definido</option>
              <option [ngValue]="true">Si</option>
              <option [ngValue]="false">No</option>
            </select>
          </label>
          <label>Periodo de pago
            <select name="periodo_pago" [(ngModel)]="form.periodo_pago">
              <option [ngValue]="null">No definido</option>
              @for (item of paymentPeriods; track item) { <option [value]="item">{{ item }}</option> }
            </select>
          </label>
          <label>Lugar de labores<input name="lugar_labores" [(ngModel)]="form.lugar_labores" maxlength="250" placeholder="VEREDA SAN JOSE, FINCA BARRO BLANCO" /></label>
          <label>Fecha inicio<input type="date" name="fecha_inicio" [(ngModel)]="form.fecha_inicio" required /></label>
          <label>Fecha fin<input type="date" name="fecha_fin" [(ngModel)]="form.fecha_fin" /></label>
          <label>Duracion meses<input type="number" min="0" name="duracion_meses" [(ngModel)]="form.duracion_meses" /></label>
          <label>Salario base<input type="number" min="0" name="salario_base" [(ngModel)]="form.salario_base" /></label>
          <label>Jornada laboral<input name="jornada_laboral" [(ngModel)]="form.jornada_laboral" maxlength="150" /></label>
          <label>Periodo prueba dias<input type="number" min="0" name="periodo_prueba_dias" [(ngModel)]="form.periodo_prueba_dias" /></label>
          <label>Prorroga dias<input type="number" min="0" name="prorroga_dias" [(ngModel)]="form.prorroga_dias" /></label>
          <label>Estado
            <select name="estado_contrato" [(ngModel)]="form.estado_contrato">
              <option [ngValue]="null">Seleccione...</option>
              @for (item of statuses; track item) { <option [value]="item">{{ item }}</option> }
            </select>
          </label>
          <section class="drawer-section form-wide">
            <h3>Datos de obra o labor</h3>
            <p class="muted">{{ workSectionHint() }}</p>
            <div class="form-grid">
              <label class="form-wide">Objeto obra/labor<textarea rows="3" name="objeto_obra_labor" [(ngModel)]="form.objeto_obra_labor"></textarea></label>
              <label class="form-wide">Funciones / clausula de funciones<textarea rows="3" name="clausula_funciones" [(ngModel)]="form.clausula_funciones"></textarea></label>
            </div>
          </section>
          <label class="form-wide">Archivo contrato URL<input name="archivo_contrato_url" [(ngModel)]="form.archivo_contrato_url" maxlength="500" /></label>
          <label class="form-wide">Observaciones<textarea rows="3" name="observaciones" [(ngModel)]="form.observaciones"></textarea></label>
          <div class="form-actions form-wide">
            <button class="btn secondary" type="button" (click)="closeCreate()" [disabled]="saving()">Cancelar</button>
            <button class="btn primary" type="submit" [disabled]="saving()">{{ saving() ? 'Guardando...' : 'Registrar contrato' }}</button>
          </div>
        </form>
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
  readonly areas = signal<Area[]>([]);
  readonly positions = signal<Position[]>([]);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly createOpen = signal(false);
  readonly error = signal('');
  readonly formError = signal('');
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
    this.service.getContracts(this.employeeId).pipe(finalize(() => this.loading.set(false))).subscribe({
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
    this.formError.set('');
    this.success.set('');
    this.createOpen.set(true);
  }

  closeCreate(): void {
    if (this.saving()) return;
    this.createOpen.set(false);
  }

  createContract(): void {
    const validation = this.validate();
    if (validation) {
      this.formError.set(validation);
      return;
    }
    this.saving.set(true);
    this.formError.set('');
    this.service.createContract(this.employeeId, this.normalize()).pipe(finalize(() => this.saving.set(false))).subscribe({
      next: () => {
        this.success.set('Contrato registrado correctamente.');
        this.form = this.emptyForm();
        this.createOpen.set(false);
        this.load();
      },
      error: (error) => this.formError.set(apiErrorMessage(error, 'No fue posible registrar el contrato.')),
    });
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

  workSectionHint(): string {
    if (this.form.tipo_cargo_contrato === 'OPERATIVO' || this.selectedContractTypeLooksLikeWork()) {
      return 'Estos datos ayudan a describir contratos por obra o labor.';
    }
    if (this.form.tipo_cargo_contrato === 'ADMINISTRATIVO') {
      return 'Usa la clausula para registrar funciones administrativas del cargo.';
    }
    return 'Completa estos campos cuando el contrato lo requiera.';
  }

  private validate(): string {
    if (!this.form.fecha_inicio) return 'La fecha de inicio es obligatoria.';
    if (this.form.fecha_fin && this.form.fecha_fin < this.form.fecha_inicio) return 'La fecha fin no puede ser menor que la fecha inicio.';
    if (Number(this.form.salario_base ?? 0) < 0) return 'El salario base debe ser mayor o igual a cero.';
    if (Number(this.form.duracion_meses ?? 0) < 0) return 'La duracion en meses debe ser mayor o igual a cero.';
    if (Number(this.form.periodo_prueba_dias ?? 0) < 0) return 'El periodo de prueba debe ser mayor o igual a cero.';
    if (Number(this.form.prorroga_dias ?? 0) < 0) return 'La prorroga en dias debe ser mayor o igual a cero.';
    if ((this.form.numero_contrato ?? '').length > 100) return 'El numero de contrato no puede superar 100 caracteres.';
    if ((this.form.periodo_pago ?? '').length > 100) return 'El periodo de pago no puede superar 100 caracteres.';
    if ((this.form.lugar_labores ?? '').length > 250) return 'El lugar de labores no puede superar 250 caracteres.';
    if (this.form.tipo_cargo_contrato && !CONTRACT_CHARGE_TYPES.includes(this.form.tipo_cargo_contrato)) return 'El tipo cargo contrato no es valido.';
    return '';
  }

  private normalize(): CreateEmployeeContractRequest {
    return {
      id_tipo_contrato: this.numberOrNull(this.form.id_tipo_contrato),
      id_area: this.numberOrNull(this.form.id_area),
      id_cargo: this.numberOrNull(this.form.id_cargo),
      fecha_inicio: this.stringOrNull(this.form.fecha_inicio) ?? '',
      fecha_fin: this.stringOrNull(this.form.fecha_fin),
      duracion_meses: this.numberOrNull(this.form.duracion_meses),
      salario_base: this.numberOrNull(this.form.salario_base),
      auxilio_transporte: this.booleanOrNull(this.form.auxilio_transporte),
      periodo_pago: this.stringOrNull(this.form.periodo_pago),
      lugar_labores: this.stringOrNull(this.form.lugar_labores),
      numero_contrato: this.stringOrNull(this.form.numero_contrato),
      tipo_cargo_contrato: this.form.tipo_cargo_contrato ?? null,
      objeto_obra_labor: this.stringOrNull(this.form.objeto_obra_labor),
      prorroga_dias: this.numberOrNull(this.form.prorroga_dias),
      clausula_funciones: this.stringOrNull(this.form.clausula_funciones),
      jornada_laboral: this.stringOrNull(this.form.jornada_laboral),
      periodo_prueba_dias: this.numberOrNull(this.form.periodo_prueba_dias),
      estado_contrato: this.stringOrNull(this.form.estado_contrato),
      archivo_contrato_url: this.stringOrNull(this.form.archivo_contrato_url),
      observaciones: this.stringOrNull(this.form.observaciones),
    };
  }

  private emptyForm(): CreateEmployeeContractRequest {
    return {
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

  private stringOrNull(value: unknown): string | null {
    return typeof value === 'string' && value.trim() !== '' ? value.trim() : null;
  }

  private booleanOrNull(value: unknown): boolean | null {
    if (value === true || value === 'true' || value === 1 || value === '1') return true;
    if (value === false || value === 'false' || value === 0 || value === '0') return false;
    return null;
  }

  private selectedContractTypeLooksLikeWork(): boolean {
    const selected = this.contractTypes().find((item) => item.id_tipo_contrato === this.numberOrNull(this.form.id_tipo_contrato));
    const name = selected?.nombre?.toUpperCase() ?? '';
    return name.includes('OBRA') || name.includes('LABOR');
  }
}
