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
    <div class="page-heading"><div><p class="eyebrow">Parámetros</p><h1>Parámetros del sistema</h1><p class="muted">Valores de configuración accesibles por el sistema.</p></div>
      @if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) { <button class="btn primary" (click)="openCreate()">Agregar parámetro</button> }
    </div>
    <section class="panel">
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      <div class="table-wrap"><table><thead><tr><th>Código</th><th>Nombre</th><th>Valor</th><th>Estado</th><th>Acciones</th></tr></thead>
        <tbody>
          @for (p of items(); track p.id_parametro) {
            <tr><td>{{ p.codigo }}</td><td><strong>{{ p.nombre }}</strong></td><td>{{ p.valor }}</td><td><span class="badge" [class.success]="p.activo">{{ p.activo ? 'ACTIVO' : 'INACTIVO' }}</span></td>
            <td>@if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) { <button class="btn small" (click)="openEdit(p)">Editar</button> }</td></tr>
          } @empty { <tr><td colspan="5" class="empty">Cargando…</td></tr> }
        </tbody></table></div>
    </section>
    @if (createOpen()) { <section class="panel modal"><div class="modal-content"><header><h2>{{ editMode() ? 'Editar' : 'Agregar' }}</h2><button class="icon-btn" (click)="closeCreate()">×</button></header>
      <form (ngSubmit)="save()"><label>Código<input type="text" [(ngModel)]="form.codigo" name="codigo" required /></label>
      <label>Nombre<input type="text" [(ngModel)]="form.nombre" name="nombre" required /></label>
      <label>Tipo de dato<select [(ngModel)]="form.tipo_dato" name="tipo_dato">
          <option value="TEXTO">Texto</option>
          <option value="NUMERICO">Numérico</option>
          <option value="FECHA">Fecha</option>
          <option value="BOOLEANO">Booleano</option>
          <option value="JSON">JSON</option>
        </select></label>
      <label>Valor<input type="text" [(ngModel)]="form.valor" name="valor" /></label>
      @if (formError()) { <div class="alert error">{{ formError() }}</div> }
      <div class="modal-actions"><button class="btn secondary" type="button" (click)="closeCreate()">Cancelar</button>
      <button class="btn primary" type="submit" [disabled]="loading()">{{ editMode() ? 'Actualizar' : 'Crear' }}</button></div></form></div></section> }
  `,
})
export class ParametersSystemParametersComponent implements OnInit {
  private readonly svc = inject(ParametersService);
  readonly auth = inject(AuthService);
  readonly items = signal<any[]>([]);
  readonly error = signal('');
  readonly formError = signal('');
  readonly loading = signal(false);
  readonly createOpen = signal(false);
  readonly editMode = signal(false);
  private editingId: number | null = null;
  form: { codigo: string; nombre: string; tipo_dato: 'TEXTO' | 'NUMERICO' | 'FECHA' | 'BOOLEANO' | 'JSON'; valor: string } = {
    codigo: '',
    nombre: '',
    tipo_dato: 'TEXTO',
    valor: '',
  };
  ngOnInit(): void { this.load(); }
  load(){ this.error.set(''); this.svc.listSystemParameters().subscribe({ next:(r)=>this.items.set(r), error:(e)=>this.error.set(apiErrorMessage(e,'No fue posible cargar.')) }); }
  openCreate(){
    this.formError.set('');
    this.form={codigo:'',nombre:'',tipo_dato:'TEXTO',valor:''};
    this.editingId=null;
    this.editMode.set(false);
    this.createOpen.set(true);
  }
  openEdit(p:any){
    this.formError.set('');
    this.form={codigo:p.codigo,nombre:p.nombre,tipo_dato:p.tipo_dato ?? 'TEXTO',valor:p.valor ?? ''};
    this.editingId=p.id_parametro;
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

    this.loading.set(true);
    const payload = {
      codigo: this.form.codigo,
      nombre: this.form.nombre,
      tipo_dato: this.form.tipo_dato,
      valor: this.form.valor,
    };
    const op = this.editingId
      ? this.svc.updateSystemParameter(this.editingId, payload)
      : this.svc.createSystemParameter(payload);

    op.pipe(finalize(()=>this.loading.set(false))).subscribe({
      next:()=>{
        this.closeCreate();
        this.load();
      },
      error:(e)=>this.formError.set(apiErrorMessage(e,'No fue posible guardar.')),
    });
  }
}
