import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({ standalone: true, imports: [RouterLink], template: `<section class="state-page"><div class="state-code">403</div><h1>Acceso no autorizado</h1><p class="muted">Tu cuenta no tiene permisos para consultar esta sección.</p><a class="btn primary" routerLink="/admin/dashboard">Volver al dashboard</a></section>` })
export class UnauthorizedComponent {}

@Component({ standalone: true, template: `<div class="page-heading"><div><p class="eyebrow">Próximamente</p><h1>Empleados</h1><p class="muted">Este módulo quedará disponible en una siguiente etapa.</p></div></div><section class="panel empty tall">Módulo de empleados en preparación.</section>` })
export class EmployeesPlaceholderComponent {}
