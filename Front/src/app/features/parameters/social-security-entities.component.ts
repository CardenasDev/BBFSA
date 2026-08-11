import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { finalize } from 'rxjs/operators';
import { ParametersService } from '../../core/services/parameters.service';
import { apiErrorMessage } from '../../shared/api-error';
import { AuthService } from '../../core/services/auth.service';
import { ParametersSocialSecurityEntity, SaveSocialSecurityEntityPayload, SocialSecurityType } from '../../core/models/api.models';

@Component({
  standalone: true,
  imports: [FormsModule],
  template: `
    <div class="page-heading"><div><p class="eyebrow">Parámetros</p><h1>Seguridad social</h1><p class="muted">EPS / ARL / Pensiones / Cesantías / Cajas de compensación</p></div>
      @if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) { <button class="btn primary" (click)="openCreate()">Agregar entidad</button> }
    </div>
    <section class="panel">
      <div class="filters">
        <label>Tipo
          <select [(ngModel)]="filterType" name="filterType" (change)="load()">
            <option value="">Todos</option>
            <option value="EPS">EPS</option>
            <option value="ARL">ARL</option>
            <option value="PENSION">Pensión</option>
            <option value="CESANTIAS">Cesantías</option>
            <option value="CAJA_COMPENSACION">Caja de compensación</option>
          </select>
        </label>
      </div>
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      <div class="table-wrap"><table><thead><tr><th>Nombre</th><th>Tipo</th><th>Estado</th><th>Acciones</th></tr></thead>
        <tbody>
          @for (e of items(); track e.id_entidad) {
            <tr><td><strong>{{ e.nombre }}</strong></td><td>{{ e.tipo }}</td><td><span class="badge" [class.success]="e.activo">{{ e.activo ? 'ACTIVO' : 'INACTIVO' }}</span></td>
            <td>@if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) { <button class="btn small secondary" (click)="toggleState(e)">{{ e.activo ? 'Inactivar' : 'Activar' }}</button> <button class="btn small" (click)="openEdit(e)">Editar</button> }</td></tr>
          } @empty { <tr><td colspan="4" class="empty">Cargando…</td></tr> }
        </tbody></table></div>
    </section>
    @if (createOpen()) { <section class="panel modal"><div class="modal-content"><header><h2>{{ editMode() ? 'Editar' : 'Agregar' }}</h2><button class="icon-btn" (click)="closeCreate()">×</button></header>
      <form (ngSubmit)="save()"><label>Nombre<input type="text" [(ngModel)]="form.nombre" name="nombre" required /></label>
      <label>Tipo<select [(ngModel)]="form.tipo" name="tipo"><option value="EPS">EPS</option><option value="ARL">ARL</option><option value="PENSION">Pensión</option><option value="CESANTIAS">Cesantías</option><option value="CAJA_COMPENSACION">Caja</option></select></label>
      @if (formError()) { <div class="alert error">{{ formError() }}</div> }
      <div class="modal-actions"><button class="btn secondary" type="button" (click)="closeCreate()">Cancelar</button>
      <button class="btn primary" type="submit" [disabled]="loading()">{{ editMode() ? 'Actualizar' : 'Crear' }}</button></div></form></div></section> }
  `,
})
export class ParametersSocialSecurityEntitiesComponent implements OnInit {
  private readonly svc = inject(ParametersService);
  readonly auth = inject(AuthService);
  readonly items = signal<ParametersSocialSecurityEntity[]>([]);
  readonly error = signal('');
  readonly formError = signal('');
  readonly loading = signal(false);
  readonly createOpen = signal(false);
  readonly editMode = signal(false);
  filterType: SocialSecurityType | '' = '';
  private editingId: number | null = null;
  form: { nombre: string; tipo: SocialSecurityType } = { nombre: '', tipo: 'EPS' };
  ngOnInit(): void { this.load(); }
  load(){
    this.error.set('');
    this.svc.listSocialSecurityEntities(this.filterType || undefined).subscribe({
      next:(r)=>this.items.set(r),
      error:(e)=>this.error.set(apiErrorMessage(e,'No fue posible cargar.')),
    });
  }
  openCreate(){
    this.formError.set('');
    this.form={nombre:'',tipo:'EPS'};
    this.editingId=null;
    this.editMode.set(false);
    this.createOpen.set(true);
  }
  openEdit(e: ParametersSocialSecurityEntity){
    this.formError.set('');
    this.form={nombre:e.nombre,tipo:e.tipo};
    this.editingId=e.id_entidad;
    this.editMode.set(true);
    this.createOpen.set(true);
  }
  closeCreate(){ this.createOpen.set(false); }
  save(){
    const nombre=this.form.nombre.trim();
    if(!nombre){
      this.formError.set('El nombre es obligatorio');
      return;
    }

    const payload: SaveSocialSecurityEntityPayload = {
      tipo_entidad: this.form.tipo,
      nombre,
    };

    const op = this.editingId
      ? this.svc.updateSocialSecurityEntity(this.editingId, payload)
      : this.svc.createSocialSecurityEntity(payload);

    this.loading.set(true);
    op.pipe(finalize(()=>this.loading.set(false))).subscribe({
      next:()=>{
        this.closeCreate();
        this.load();
      },
      error:(e)=>this.formError.set(apiErrorMessage(e,'No fue posible guardar.')),
    });
  }
  toggleState(e: ParametersSocialSecurityEntity){
    if(e.activo && !confirm(`¿Desea inactivar ${e.nombre}?`)) return;

    this.loading.set(true);
    this.svc.updateSocialSecurityEntity(e.id_entidad, {
      tipo_entidad: e.tipo,
      nombre: e.nombre,
      activo: !e.activo,
    }).pipe(finalize(()=>this.loading.set(false))).subscribe({
      next:()=>this.load(),
      error:(e)=>this.error.set(apiErrorMessage(e,'No fue posible cambiar el estado.')),
    });
  }
}
