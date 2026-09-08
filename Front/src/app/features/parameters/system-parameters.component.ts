import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { finalize } from 'rxjs/operators';
import { ParametersService } from '../../core/services/parameters.service';
import { apiErrorMessage } from '../../shared/api-error';
import { AuthService } from '../../core/services/auth.service';
import { SaveSystemParameterPayload, SystemParameter } from '../../core/models/api.models';

@Component({
  standalone: true,
  imports: [FormsModule],
  template: `
    <div class="page-heading"><div><p class="eyebrow">Parámetros</p><h1>Parámetros del sistema</h1><p class="muted">Valores de configuración accesibles por el sistema.</p></div>
      @if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) { <div class="row-actions"><button class="btn secondary" (click)="openSalaryPeriod()">Nueva vigencia salarial</button><button class="btn primary" (click)="openCreate()">Agregar parámetro</button></div> }
    </div>
    <section class="panel">
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      @if (success()) { <div class="alert success">{{ success() }}</div> }
      <div class="table-wrap"><table><thead><tr><th>Código</th><th>Nombre</th><th>Valor</th><th>Vigencia</th><th>Estado</th><th>Acciones</th></tr></thead>
        <tbody>
          @for (p of items(); track p.id_parametro) {
            <tr><td>{{ p.codigo }}</td><td><strong>{{ p.nombre }}</strong><small class="muted">{{ p.grupo || 'GENERAL' }}</small></td><td>{{ displayValue(p) }}</td><td>{{ p.vigencia_desde || 'Sin definir' }}<br><small>hasta {{ p.vigencia_hasta || 'sin fecha final' }}</small></td><td><span class="badge" [class.success]="p.activo">{{ p.activo ? 'ACTIVO' : 'INACTIVO' }}</span></td>
            <td>@if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) { <button class="btn small" (click)="openEdit(p)">Editar</button> }</td></tr>
          } @empty { <tr><td colspan="5" class="empty">Cargando…</td></tr> }
        </tbody></table></div>
    </section>
    @if (createOpen()) { <section class="panel modal"><div class="modal-content"><header><h2>{{ editMode() ? 'Editar' : 'Agregar' }}</h2><button class="icon-btn" (click)="closeCreate()">×</button></header>
      <form (ngSubmit)="save()"><label>Código<input type="text" [(ngModel)]="form.codigo" name="codigo" required /></label>
      <label>Nombre<input type="text" [(ngModel)]="form.nombre" name="nombre" required /></label>
      <label>Grupo<input type="text" [(ngModel)]="form.grupo" name="grupo" maxlength="100" /></label>
      <label>Tipo de dato<select [(ngModel)]="form.tipo_dato" name="tipo_dato">
          <option value="TEXTO">Texto</option>
          <option value="NUMERICO">Numérico</option>
          <option value="FECHA">Fecha</option>
          <option value="BOOLEANO">Booleano</option>
          <option value="JSON">JSON</option>
        </select></label>
      <label>Valor<input [type]="form.tipo_dato === 'NUMERICO' ? 'number' : 'text'" [(ngModel)]="form.valor" name="valor" [min]="form.codigo === 'SALARIO_MINIMO' ? 1 : null" required /></label>
      <label>Unidad de medida<input type="text" [(ngModel)]="form.unidad_medida" name="unidad_medida" maxlength="50" placeholder="Ej. COP" /></label>
      <label>Vigencia desde<input type="date" [(ngModel)]="form.vigencia_desde" name="vigencia_desde" required /></label>
      <label>Vigencia hasta<input type="date" [(ngModel)]="form.vigencia_hasta" name="vigencia_hasta" /></label>
      <label class="form-wide">Descripción<textarea [(ngModel)]="form.descripcion" name="descripcion" rows="3"></textarea></label>
      <label class="check"><input type="checkbox" [(ngModel)]="form.activo" name="activo" /> Activo</label>
      @if (formError()) { <div class="alert error">{{ formError() }}</div> }
      <div class="modal-actions"><button class="btn secondary" type="button" (click)="closeCreate()">Cancelar</button>
      <button class="btn primary" type="submit" [disabled]="loading()">{{ editMode() ? 'Actualizar' : 'Crear' }}</button></div></form></div></section> }
  `,
})
export class ParametersSystemParametersComponent implements OnInit {
  private readonly svc = inject(ParametersService);
  readonly auth = inject(AuthService);
  readonly items = signal<SystemParameter[]>([]);
  readonly error = signal('');
  readonly success = signal('');
  readonly formError = signal('');
  readonly loading = signal(false);
  readonly createOpen = signal(false);
  readonly editMode = signal(false);
  private editingId: number | null = null;
  form: SaveSystemParameterPayload = this.emptyForm();
  ngOnInit(): void { this.load(); }
  load(){ this.error.set(''); this.svc.listSystemParameters().subscribe({ next:(r)=>this.items.set(r), error:(e)=>this.error.set(apiErrorMessage(e,'No fue posible cargar.')) }); }
  openCreate(){
    this.formError.set('');
    this.form=this.emptyForm();
    this.editingId=null;
    this.editMode.set(false);
    this.createOpen.set(true);
  }
  openSalaryPeriod(){
    const nextYear=new Date().getFullYear()+1;
    this.formError.set('');
    this.form={codigo:'SALARIO_MINIMO',nombre:'Salario mínimo legal vigente',grupo:'LABORAL',descripcion:'Valor mínimo permitido para el salario base de los contratos.',tipo_dato:'NUMERICO',valor:'',unidad_medida:'COP',vigencia_desde:`${nextYear}-01-01`,vigencia_hasta:`${nextYear}-12-31`,activo:true,editable:true};
    this.editingId=null;this.editMode.set(false);this.createOpen.set(true);
  }
  openEdit(p:SystemParameter){
    this.formError.set('');
    this.form={codigo:p.codigo,nombre:p.nombre,grupo:p.grupo??'',descripcion:p.descripcion??'',tipo_dato:p.tipo_dato??'TEXTO',valor:p.valor??'',unidad_medida:p.unidad_medida??'',vigencia_desde:p.vigencia_desde??'',vigencia_hasta:p.vigencia_hasta??'',activo:p.activo,editable:p.editable};
    this.editingId=p.id_parametro;
    this.editMode.set(true);
    this.createOpen.set(true);
  }
  closeCreate(){ this.createOpen.set(false); }
  save(){
    this.formError.set('');
    const nombre=this.form.nombre.trim();
    if(!nombre){
      this.formError.set('El nombre es obligatorio');
      return;
    }
    const codigo=this.form.codigo.trim().toUpperCase();
    if(!codigo){this.formError.set('El código es obligatorio.');return;}
    if(!this.form.vigencia_desde){this.formError.set('La fecha de inicio de vigencia es obligatoria.');return;}
    if(this.form.vigencia_hasta&&this.form.vigencia_hasta<this.form.vigencia_desde){this.formError.set('La vigencia final no puede ser anterior a la inicial.');return;}
    if(this.form.tipo_dato==='NUMERICO'&&(!Number.isFinite(Number(this.form.valor))||Number(this.form.valor)<=0)){this.formError.set('Ingresa un valor numérico mayor que cero.');return;}
    if(this.hasOverlap(codigo)){this.formError.set('Ya existe una vigencia activa para este código que se cruza con las fechas indicadas.');return;}

    this.loading.set(true);
    const payload = {
      ...this.form,
      codigo,
      nombre: this.form.nombre,
    };
    const op = this.editingId
      ? this.svc.updateSystemParameter(this.editingId, payload)
      : this.svc.createSystemParameter(payload);

    op.pipe(finalize(()=>this.loading.set(false))).subscribe({
      next:()=>{
        this.success.set(this.editingId?'Parámetro actualizado correctamente.':'Nueva vigencia creada correctamente.');
        this.closeCreate();
        this.load();
      },
      error:(e)=>this.formError.set(apiErrorMessage(e,'No fue posible guardar.')),
    });
  }
  displayValue(p:SystemParameter):string{return p.tipo_dato==='NUMERICO'?`${Number(p.valor??0).toLocaleString('es-CO')} ${p.unidad_medida??''}`.trim():String(p.valor??'—');}
  private emptyForm():SaveSystemParameterPayload{return{codigo:'',nombre:'',grupo:'GENERAL',descripcion:'',tipo_dato:'TEXTO',valor:'',unidad_medida:'',vigencia_desde:new Date().toISOString().slice(0,10),vigencia_hasta:'',activo:true,editable:true};}
  private hasOverlap(codigo:string):boolean{const start=this.form.vigencia_desde!;const end=this.form.vigencia_hasta||'9999-12-31';return this.items().some(p=>p.id_parametro!==this.editingId&&p.activo&&p.codigo.toUpperCase()===codigo&&(p.vigencia_desde||'0000-01-01')<=end&&(p.vigencia_hasta||'9999-12-31')>=start);}
}
