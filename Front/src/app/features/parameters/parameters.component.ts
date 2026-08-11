import { Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({
  standalone: true,
  imports: [RouterLink],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Parámetros</p>
        <h1>Administración de catálogos</h1>
        <p class="muted">Centraliza la administración de los catálogos del sistema.</p>
      </div>
    </div>

    <section class="panel">
      <div class="grid cards">
        <a class="card" routerLink="/admin/parameters/areas">Áreas</a>
        <a class="card" routerLink="/admin/parameters/positions">Cargos</a>
        <a class="card" routerLink="/admin/parameters/contract-types">Tipos de contrato</a>
        <a class="card" routerLink="/admin/parameters/document-types">Tipos de documento</a>
        <a class="card" routerLink="/admin/parameters/labor-document-types">Documentos laborales</a>
        <a class="card" routerLink="/admin/parameters/social-security-entities">Seguridad social</a>
        <a class="card" routerLink="/admin/parameters/medical-exam-types">Exámenes médicos</a>
        <a class="card" routerLink="/admin/parameters/uniform-items">Artículos de dotación</a>
        <a class="card" routerLink="/admin/parameters/system">Parámetros sistema</a>
      </div>
    </section>
  `,
})
export class ParametersComponent {
  readonly auth = inject(AuthService);
}
