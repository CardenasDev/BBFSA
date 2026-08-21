import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { finalize } from 'rxjs/operators';
import { NoveltyTypeParameter, SaveNoveltyTypePayload } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { ParametersService } from '../../core/services/parameters.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [FormsModule],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Parámetros</p><h1>Tipos de novedad</h1><p>Define las novedades laborales disponibles y sus requisitos.</p></div>
      @if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) { <button class="btn primary" (click)="openCreate()">Agregar</button> }
    </div>
    <section class="panel">
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      <div class="table-wrap"><table><thead><tr><th>Tipo</th><th>Fecha final</th><th>Soporte</th><th>Formulario</th><th>Registros</th><th>Estado</th><th>Acciones</th></tr></thead>
      <tbody>@for (item of items(); track item.id_tipo_novedad) {
        <tr><td><strong>{{ item.nombre }}</strong><small>{{ item.descripcion || item.codigo }}</small></td>
        <td>{{ item.requiere_fecha_fin ? 'Requerida' : 'Opcional' }}</td><td>{{ item.requiere_soporte ? 'Requerido' : 'Opcional' }}</td>
        <td>{{ item.es_incapacidad ? 'Incapacidad' : 'General' }}</td><td>{{ item.total_novedades }}</td>
        <td><span class="badge" [class.success]="item.activo">{{ item.activo ? 'ACTIVO' : 'INACTIVO' }}</span></td>
        <td>@if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) { <button class="btn small" (click)="openEdit(item)">Editar</button> <button class="btn small secondary" (click)="toggle(item)">{{ item.activo ? 'Inactivar' : 'Activar' }}</button> }</td></tr>
      } @empty { <tr><td colspan="7" class="empty">No hay tipos de novedad.</td></tr> }</tbody></table></div>
    </section>
    @if (modal()) { <section class="panel modal"><div class="modal-content"><header><h2>{{ editingId ? 'Editar' : 'Agregar' }} tipo de novedad</h2><button class="icon-btn" (click)="close()">×</button></header>
      <form (ngSubmit)="save()"><label>Nombre *<input [(ngModel)]="form.nombre" name="nombre" maxlength="150" required /></label>
      <label>Descripción<textarea [(ngModel)]="form.descripcion" name="descripcion" maxlength="500"></textarea></label>
      <label class="check"><input type="checkbox" [(ngModel)]="form.requiere_fecha_fin" name="fechaFin" /> Requiere fecha final</label>
      <label class="check"><input type="checkbox" [(ngModel)]="form.requiere_soporte" name="soporte" /> Requiere soporte</label>
      <label class="check"><input type="checkbox" [(ngModel)]="form.es_incapacidad" name="incapacidad" [disabled]="editingTotal > 0" /> Usa el formulario detallado de incapacidad</label>
      @if (editingTotal > 0) { <small>Esta clasificación no puede cambiarse porque el tipo ya tiene registros.</small> }
      @if (formError()) { <div class="alert error">{{ formError() }}</div> }
      <div class="modal-actions"><button class="btn secondary" type="button" (click)="close()">Cancelar</button><button class="btn primary" [disabled]="loading()">{{ loading() ? 'Guardando…' : 'Guardar' }}</button></div></form>
    </div></section> }
  `,
})
export class ParametersNoveltyTypesComponent implements OnInit {
  private readonly service = inject(ParametersService);
  readonly auth = inject(AuthService);
  readonly items = signal<NoveltyTypeParameter[]>([]);
  readonly error = signal(''); readonly formError = signal(''); readonly loading = signal(false); readonly modal = signal(false);
  editingId: number | null = null; editingTotal = 0;
  form: SaveNoveltyTypePayload = this.emptyForm();
  ngOnInit(): void { this.load(); }
  private emptyForm(): SaveNoveltyTypePayload { return { nombre:'', descripcion:'', requiere_fecha_fin:false, requiere_soporte:false, es_incapacidad:false, activo:true }; }
  load(): void { this.error.set(''); this.service.listNoveltyTypes().subscribe({next:r=>this.items.set(r), error:e=>this.error.set(apiErrorMessage(e,'No fue posible cargar los tipos de novedad.'))}); }
  openCreate(): void { this.editingId=null; this.editingTotal=0; this.form=this.emptyForm(); this.formError.set(''); this.modal.set(true); }
  openEdit(item: NoveltyTypeParameter): void { this.editingId=item.id_tipo_novedad; this.editingTotal=item.total_novedades; this.form={nombre:item.nombre, descripcion:item.descripcion, requiere_fecha_fin:item.requiere_fecha_fin, requiere_soporte:item.requiere_soporte, es_incapacidad:item.es_incapacidad, activo:item.activo}; this.formError.set(''); this.modal.set(true); }
  close(): void { this.modal.set(false); }
  save(): void { this.form.nombre=this.form.nombre.trim(); if(!this.form.nombre){this.formError.set('El nombre es obligatorio.'); return;} this.loading.set(true); const op=this.editingId ? this.service.updateNoveltyType(this.editingId,this.form) : this.service.createNoveltyType(this.form); op.pipe(finalize(()=>this.loading.set(false))).subscribe({next:()=>{this.close();this.load();},error:e=>this.formError.set(apiErrorMessage(e,'No fue posible guardar el tipo de novedad.'))}); }
  toggle(item: NoveltyTypeParameter): void { if(item.activo && !confirm(`¿Desea inactivar ${item.nombre}?`)) return; const payload: SaveNoveltyTypePayload={nombre:item.nombre,descripcion:item.descripcion,requiere_fecha_fin:item.requiere_fecha_fin,requiere_soporte:item.requiere_soporte,es_incapacidad:item.es_incapacidad,activo:!item.activo}; this.loading.set(true); this.service.updateNoveltyType(item.id_tipo_novedad,payload).pipe(finalize(()=>this.loading.set(false))).subscribe({next:()=>this.load(),error:e=>this.error.set(apiErrorMessage(e,'No fue posible cambiar el estado.'))}); }
}
