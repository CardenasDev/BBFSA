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
    <div class="page-heading">
      <div>
        <p class="eyebrow">Parámetros</p>
        <h1>Tipos de contrato</h1>
      </div>
      @if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) {
        <button class="btn primary" type="button" (click)="openCreate()">Agregar tipo de contrato</button>
      }
    </div>
    <section class="panel">
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      <div class="table-wrap">
        <table>
          <thead><tr><th>Nombre</th><th>Descripción</th><th>Estado</th><th>Acciones</th></tr></thead>
          <tbody>
            @for (t of items(); track t.id_tipo_contrato) {
              <tr>
                <td><strong>{{ t.nombre }}</strong></td>
                <td>{{ t.descripcion }}</td>
                <td><span class="badge" [class.success]="t.activo">{{ t.activo ? 'ACTIVO' : 'INACTIVO' }}</span></td>
                <td>
                  @if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) {
                    <button class="btn small secondary" type="button" (click)="toggleState(t)" [disabled]="loading()">{{ t.activo ? 'Inactivar' : 'Activar' }}</button>
                    <button class="btn small" type="button" (click)="openEdit(t)">Editar</button>
                  }
                </td>
              </tr>
            } @empty { <tr><td colspan="4" class="empty">Cargando…</td></tr> }
          </tbody>
        </table>
      </div>
    </section>

    @if (createOpen()) {
      <section class="panel modal"><div class="modal-content"><header>
        <h2>{{ editMode() ? 'Editar' : 'Agregar' }}</h2>
        <button class="icon-btn" type="button" (click)="closeCreate()" aria-label="Cerrar">×</button>
      </header>
      <form (ngSubmit)="save()">
        <label>Nombre<input type="text" [(ngModel)]="form.nombre" name="nombre" required maxlength="255" /></label>
        <label>Descripción<input type="text" [(ngModel)]="form.descripcion" name="descripcion" maxlength="1000" /></label>
        @if (formError()) { <div class="alert error">{{ formError() }}</div> }
        <div class="modal-actions"><button class="btn secondary" type="button" (click)="closeCreate()">Cancelar</button>
        <button class="btn primary" type="submit" [disabled]="loading()">{{ editMode() ? 'Actualizar' : 'Crear' }}</button></div>
      </form></div></section>
    }
  `,
})
export class ParametersContractTypesComponent implements OnInit {
  private readonly svc = inject(ParametersService);
  readonly auth = inject(AuthService);
  readonly items = signal<any[]>([]);
  readonly error = signal('');
  readonly formError = signal('');
  readonly loading = signal(false);
  readonly createOpen = signal(false);
  readonly editMode = signal(false);
  private editingId: number | null = null;
  form: { nombre: string; descripcion?: string | null } = { nombre: '', descripcion: '' };

  ngOnInit(): void { this.load(); }
  load(): void { this.error.set(''); this.svc.listContractTypes().subscribe({ next: (r) => this.items.set(r), error: (e) => this.error.set(apiErrorMessage(e,'No fue posible cargar los tipos de contrato.')) }); }
  openCreate(){ this.formError.set(''); this.form={nombre:'',descripcion:''}; this.editingId=null; this.editMode.set(false); this.createOpen.set(true); }
  openEdit(t:any){ this.formError.set(''); this.form={nombre:t.nombre,descripcion:t.descripcion??''}; this.editingId=t.id_tipo_contrato; this.editMode.set(true); this.createOpen.set(true); }
  closeCreate(){ this.createOpen.set(false); }
  save(){ const nombre=this.form.nombre?.trim(); if(!nombre){ this.formError.set('El nombre es obligatorio.'); return;} this.loading.set(true); this.formError.set(''); const op = this.editingId? this.svc.updateContractType(this.editingId,{nombre:this.form.nombre, descripcion:this.form.descripcion}) : this.svc.createContractType({nombre:this.form.nombre, descripcion:this.form.descripcion}); op.pipe(finalize(()=>this.loading.set(false))).subscribe({ next:()=>{ this.closeCreate(); this.load(); }, error:(e)=>this.formError.set(apiErrorMessage(e,'No fue posible guardar el tipo de contrato.')) }); }
  toggleState(t:any){ if(t.activo && !confirm(`¿Desea inactivar el tipo de contrato ${t.nombre}?`)) return; this.loading.set(true); this.svc.updateContractType(t.id_tipo_contrato,{ nombre:t.nombre, descripcion:t.descripcion??'', activo: !t.activo }).pipe(finalize(()=>this.loading.set(false))).subscribe({ next:()=>this.load(), error:(e)=>this.error.set(apiErrorMessage(e,'No fue posible cambiar el estado.')) }); }
}
