import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { finalize } from 'rxjs/operators';
import { ParametersService } from '../../core/services/parameters.service';
import { apiErrorMessage } from '../../shared/api-error';
import { AuthService } from '../../core/services/auth.service';

@Component({
  standalone: true,
  imports: [FormsModule],
  template: `
    <div class="page-heading"><div><p class="eyebrow">Parámetros</p><h1>Documentos laborales</h1></div>
      @if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) { <button class="btn primary" (click)="openCreate()">Agregar</button> }
    </div>
    <section class="panel">
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      <div class="table-wrap"><table><thead><tr><th>Nombre</th><th>Obligatorio</th><th>Estado</th><th>Acciones</th></tr></thead>
        <tbody>
          @for (d of items(); track d.id_tipo_documento_laboral) {
            <tr><td><strong>{{ d.nombre }}</strong></td><td>{{ d.obligatorio ? 'Sí' : 'No' }}</td>
            <td><span class="badge" [class.success]="d.activo">{{ d.activo ? 'ACTIVO' : 'INACTIVO' }}</span></td>
            <td>@if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) { <button class="btn small secondary" (click)="toggleState(d)">{{ d.activo ? 'Inactivar' : 'Activar' }}</button> <button class="btn small" (click)="openEdit(d)">Editar</button> }</td></tr>
          } @empty { <tr><td colspan="4" class="empty">Cargando…</td></tr> }
        </tbody></table></div>
    </section>
    @if (createOpen()) { <section class="panel modal"><div class="modal-content"><header><h2>{{ editMode() ? 'Editar' : 'Agregar' }}</h2><button class="icon-btn" (click)="closeCreate()">×</button></header>
      <form (ngSubmit)="save()"><label>Nombre<input type="text" [(ngModel)]="form.nombre" name="nombre" required /></label>
      <label><input type="checkbox" [(ngModel)]="form.obligatorio" name="obligatorio" /> Obligatorio</label>
      @if (formError()) { <div class="alert error">{{ formError() }}</div> }
      <div class="modal-actions"><button class="btn secondary" type="button" (click)="closeCreate()">Cancelar</button>
      <button class="btn primary" type="submit" [disabled]="loading()">{{ editMode() ? 'Actualizar' : 'Crear' }}</button></div></form></div></section> }
  `,
})
export class ParametersLaborDocumentTypesComponent implements OnInit {
  private readonly svc = inject(ParametersService);
  readonly auth = inject(AuthService);
  readonly items = signal<any[]>([]);
  readonly error = signal('');
  readonly formError = signal('');
  readonly loading = signal(false);
  readonly createOpen = signal(false);
  readonly editMode = signal(false);
  private editingId: number | null = null;
  form: { nombre: string; obligatorio?: boolean | null; descripcion?: string | null } = { nombre: '', obligatorio: false, descripcion: '' };
  ngOnInit(): void { this.load(); }
  load(){ this.error.set(''); this.svc.listLaborDocumentTypes().subscribe({ next:(r)=>this.items.set(r), error:(e)=>this.error.set(apiErrorMessage(e,'No fue posible cargar.')) }); }
  openCreate(){ this.formError.set(''); this.form={nombre:'',obligatorio:false,descripcion:''}; this.editingId=null; this.editMode.set(false); this.createOpen.set(true); }
  openEdit(d:any){ this.formError.set(''); this.form={nombre:d.nombre,obligatorio:!!d.obligatorio,descripcion:d.descripcion??''}; this.editingId=d.id_tipo_documento_laboral; this.editMode.set(true); this.createOpen.set(true); }
  closeCreate(){ this.createOpen.set(false); }
  save(){ const nombre=this.form.nombre?.trim(); if(!nombre){ this.formError.set('El nombre es obligatorio'); return;} this.loading.set(true); const op = this.editingId? this.svc.updateLaborDocument(this.editingId,{nombre:this.form.nombre, descripcion:this.form.descripcion, activo: undefined}) : this.svc.createLaborDocument({nombre:this.form.nombre, descripcion:this.form.descripcion}); op.pipe(finalize(()=>this.loading.set(false))).subscribe({ next:()=>{ this.closeCreate(); this.load(); }, error:(e)=>this.formError.set(apiErrorMessage(e,'No fue posible guardar.')) }); }
  toggleState(d:any){ if(d.activo && !confirm(`¿Desea inactivar ${d.nombre}?`)) return; this.loading.set(true); this.svc.updateLaborDocument(d.id_tipo_documento_laboral,{ nombre:d.nombre, descripcion:d.descripcion??'', activo: !d.activo }).pipe(finalize(()=>this.loading.set(false))).subscribe({ next:()=>this.load(), error:(e)=>this.error.set(apiErrorMessage(e,'No fue posible cambiar el estado.')) }); }
}
