import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  standalone: true,
  imports: [RouterLink],
  template: `
    <section class="page-header">
      <div><span class="eyebrow">Administración</span><h1>Carga masiva</h1><p>Importa información usando plantillas oficiales y validación previa.</p></div>
    </section>
    <section class="bulk-grid" aria-label="Tipos de carga disponibles">
      <article class="card bulk-card">
        <div class="bulk-icon" aria-hidden="true">E</div>
        <div><h2>Empleados</h2><p>Crea empleados, ficha de ingreso, seguridad social y tallas de dotación.</p></div>
        <a class="btn primary" routerLink="/admin/bulk-load/employees">Iniciar carga</a>
      </article>
    </section>
  `,
  styles: [`
    .bulk-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,420px));gap:1rem}
    .bulk-card{display:grid;grid-template-columns:auto 1fr;gap:1rem;align-items:start;padding:1.4rem}
    .bulk-card .btn{grid-column:1/-1;justify-self:start}.bulk-card h2{margin:.1rem 0 .35rem}
    .bulk-card p{margin:0;color:var(--text-muted,#64748b)}
    .bulk-icon{display:grid;place-items:center;width:48px;height:48px;border-radius:12px;background:#dbeafe;color:#1d4ed8;font-weight:800}
  `],
})
export class BulkLoadComponent {}
