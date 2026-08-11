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
    <div class="page-heading"><div><p class="eyebrow">Parámetros</p><h1>Artículos de dotación</h1><p class="muted">Administra los artículos individuales de dotación.</p></div>
      @if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) { <button class="btn primary" (click)="openCreate()">Agregar artículo</button> }
    </div>
    <section class="panel">
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      <div class="table-wrap"><table><thead><tr><th>Nombre</th><th>Familia</th><th>Requiere talla</th><th>Estado</th><th>Acciones</th></tr></thead>
        <tbody>
          @for (it of items(); track it.id_articulo) {
            <tr><td><strong>{{ it.nombre }}</strong></td><td>{{ it.familia_nombre }}</td><td>{{ it.requiere_talla ? 'Sí' : 'No' }}</td>
            <td><span class="badge" [class.success]="it.activo">{{ it.activo ? 'ACTIVO' : 'INACTIVO' }}</span></td>
            <td>@if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) { <button class="btn small secondary" (click)="toggleState(it)">{{ it.activo ? 'Inactivar' : 'Activar' }}</button> <button class="btn small" (click)="openEdit(it)">Editar</button> }</td></tr>
          } @empty { <tr><td colspan="5" class="empty">Cargando…</td></tr> }
        </tbody></table></div>
    </section>
    @if (createOpen()) { <section class="panel modal"><div class="modal-content"><header><h2>{{ editMode() ? 'Editar' : 'Agregar' }}</h2><button class="icon-btn" (click)="closeCreate()">×</button></header>
      <form (ngSubmit)="save()">
        <label>Nombre<input type="text" [(ngModel)]="form.nombre" name="nombre" required /></label>
        <label>Familia<select [(ngModel)]="form.id_tipo_dotacion" name="id_tipo_dotacion"><option *ngFor="let f of families" [value]="f.id_tipo_dotacion">{{ f.nombre }}</option></select></label>
        <label><input type="checkbox" [(ngModel)]="form.requiere_talla" name="requiere_talla" /> Requiere talla</label>
      @if (formError()) { <div class="alert error">{{ formError() }}</div> }
      <div class="modal-actions"><button class="btn secondary" type="button" (click)="closeCreate()">Cancelar</button>
      <button class="btn primary" type="submit" [disabled]="loading()">{{ editMode() ? 'Actualizar' : 'Crear' }}</button></div></form></div></section> }
  `,
})
export class ParametersUniformItemsComponent implements OnInit {
  private readonly svc = inject(ParametersService);
  readonly auth = inject(AuthService);
  readonly items = signal<any[]>([]);
  readonly families = signal<any[]>([]);
  readonly error = signal('');
  readonly formError = signal('');
  readonly loading = signal(false);
  readonly createOpen = signal(false);
  readonly editMode = signal(false);
  private editingId: number | null = null;
  form: { nombre: string; id_tipo_dotacion?: number | null; requiere_talla?: boolean } = { nombre: '', id_tipo_dotacion: null, requiere_talla: false };
  ngOnInit(): void { this.loadFamilies(); this.load(); }
  load(){ this.error.set(''); this.svc.listUniformItems().subscribe({ next:(r)=>this.items.set(r), error:(e)=>this.error.set(apiErrorMessage(e,'No fue posible cargar artículos.')) }); }
  loadFamilies(){ this.svc.getUniformItemFamilies().subscribe({ next:(r)=>this.families.set(r), error:()=>this.families.set([]) }); }
  openCreate(){ this.formError.set(''); this.form={nombre:'',id_tipo_dotacion:this.families()[0]?.id_tipo_dotacion ?? null,requiere_talla:false}; this.editingId=null; this.editMode.set(false); this.createOpen.set(true); }
  openEdit(it:any){ this.formError.set(''); this.form={nombre:it.nombre,id_tipo_dotacion:it.id_tipo_dotacion,requiere_talla:!!it.requiere_talla}; this.editingId=it.id_articulo; this.editMode.set(true); this.createOpen.set(true); }
  closeCreate(){ this.createOpen.set(false); }
  save(){ const nombre=this.form.nombre?.trim(); if(!nombre){ this.formError.set('El nombre es obligatorio'); return;} if(!this.form.id_tipo_dotacion){ this.formError.set('La familia es obligatoria'); return;} this.loading.set(true); const op = this.editingId? this.svc.updateUniformItem(this.editingId,{ nombre:this.form.nombre, id_tipo_dotacion:this.form.id_tipo_dotacion, requiere_talla: !!this.form.requiere_talla }) : this.svc.createUniformItem({ nombre:this.form.nombre, id_tipo_dotacion:this.form.id_tipo_dotacion, requiere_talla: !!this.form.requiere_talla }); op.pipe(finalize(()=>this.loading.set(false))).subscribe({ next:()=>{ this.closeCreate(); this.load(); }, error:(e)=>this.formError.set(apiErrorMessage(e,'No fue posible guardar.')) }); }
  toggleState(it:any){ if(it.activo && !confirm(`¿Desea inactivar ${it.nombre}?`)) return; this.loading.set(true); this.svc.updateUniformItem(it.id_articulo,{ nombre:it.nombre, id_tipo_dotacion:it.id_tipo_dotacion, requiere_talla: !!it.requiere_talla, activo: !it.activo }).pipe(finalize(()=>this.loading.set(false))).subscribe({ next:()=>this.load(), error:(e)=>this.error.set(apiErrorMessage(e,'No fue posible cambiar el estado.')) }); }
}
