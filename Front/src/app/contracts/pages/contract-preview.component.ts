import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { finalize } from 'rxjs';
import { ContractFixedTermComponent } from '../components/contract-fixed-term.component';
import { ContractIndefiniteComponent } from '../components/contract-indefinite.component';
import { ContractWorkComponent } from '../components/contract-work.component';
import { BaseContractComponent } from '../components/base-contract.component';
import { ContractGenerationData, ContractRendererType } from '../models/contract-generation.models';
import { ContractService } from '../services/contract.service';
import { apiErrorMessage } from '../../shared/api-error';
import { resolveContractRenderer } from '../contract-renderer.util';

@Component({
  standalone: true,
  imports: [BaseContractComponent, ContractIndefiniteComponent, ContractFixedTermComponent, ContractWorkComponent],
  template: `
    @if (error()) {
      <section class="panel">
        <div class="alert error" role="alert">{{ error() }}</div>
      </section>
    }

    @if (loading()) {
      <section class="panel">
        <p class="muted">Cargando datos del contrato...</p>
      </section>
    }

    @if (!loading() && contractData(); as data) {
      <section class="panel" style="margin-bottom:12px;">
        <div class="row-actions">
          <button class="btn primary" type="button" (click)="openPrintView()">Abrir vista de impresion</button>
        </div>
      </section>

      @switch (renderer()) {
        @case ('indefinite') {
          <app-contract-indefinite [data]="data"></app-contract-indefinite>
        }
        @case ('fixed-term') {
          <app-contract-fixed-term [data]="data"></app-contract-fixed-term>
        }
        @case ('work') {
          <app-contract-work [data]="data"></app-contract-work>
        }
        @default {
          <app-base-contract [data]="data"></app-base-contract>
        }
      }
    }
  `,
})
export class ContractPreviewComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly contractService = inject(ContractService);

  readonly loading = signal(false);
  readonly error = signal('');
  readonly contractData = signal<ContractGenerationData | null>(null);
  readonly renderer = signal<ContractRendererType>('base');
  readonly employeeContractId = signal<number | null>(null);

  ngOnInit(): void {
    const employeeContractId = Number(this.route.snapshot.paramMap.get('employeeContractId'));
    if (!employeeContractId || Number.isNaN(employeeContractId)) {
      this.error.set('Id de contrato invalido.');
      return;
    }

    this.employeeContractId.set(employeeContractId);
    this.loadContract(employeeContractId);
  }

  openPrintView(): void {
    const employeeContractId = this.employeeContractId();
    if (!employeeContractId) {
      return;
    }

    const printUrl = this.router.serializeUrl(
      this.router.createUrlTree([
        '/admin/contracting/contracts',
        employeeContractId,
        'print',
      ]),
    );
    window.open(printUrl, '_blank', 'noopener,noreferrer');
  }

  private loadContract(employeeContractId: number): void {
    this.loading.set(true);
    this.error.set('');

    this.contractService.getContractGenerationData(employeeContractId)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (data) => {
          this.contractData.set(data);
          this.renderer.set(resolveContractRenderer(data));
        },
        error: (error) => {
          this.error.set(apiErrorMessage(error, 'No fue posible cargar la vista previa del contrato.'));
          this.contractData.set(null);
        },
      });
  }

}
