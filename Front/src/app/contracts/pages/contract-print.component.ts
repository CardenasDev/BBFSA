import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { finalize } from 'rxjs';
import { ContractFixedTermComponent } from '../components/contract-fixed-term.component';
import { ContractIndefiniteComponent } from '../components/contract-indefinite.component';
import { ContractWorkComponent } from '../components/contract-work.component';
import { BaseContractComponent } from '../components/base-contract.component';
import { ContractGenerationData, ContractRendererType } from '../models/contract-generation.models';
import { ContractService } from '../services/contract.service';
import { apiErrorMessage } from '../../shared/api-error';
import { resolveContractRenderer } from '../contract-renderer.util';
import { validateWorkContractData } from '../contract-work-validation.util';

@Component({
  standalone: true,
  imports: [BaseContractComponent, ContractIndefiniteComponent, ContractFixedTermComponent, ContractWorkComponent],
  styles: [
    `
      :host {
        display: block;
      }

      .print-view {
        min-height: 100vh;
        background: #f0f2f5;
      }

      .print-toolbar {
        position: sticky;
        top: 0;
        z-index: 100;
        display: flex;
        gap: 10px;
        align-items: center;
        justify-content: flex-end;
        padding: 12px 16px;
        background: #ffffff;
        border-bottom: 1px solid #dfe3e8;
      }

      .print-content {
        padding: 12px 0 20px;
      }

      .print-message {
        width: min(920px, calc(100% - 24px));
        margin: 12px auto;
        padding: 12px;
        border-radius: 8px;
        border: 1px solid #d8dee6;
        background: #fff;
      }

      @media print {
        :host {
          display: block;
          width: 210mm;
          margin: 0;
          padding: 0;
        }

        .print-toolbar {
          display: none !important;
        }

        .print-view {
          width: 210mm;
          min-height: 0;
          margin: 0;
          padding: 0;
          background: #fff;
        }

        .print-content {
          width: 210mm;
          margin: 0;
          padding: 0;
        }

      }
    `,
  ],
  template: `
    <div class="print-view">
      <div class="print-toolbar">
        <button class="btn primary" type="button" (click)="printContract()">Imprimir / Guardar como PDF</button>
        <button class="btn ghost" type="button" (click)="goBack()">Volver</button>
      </div>

      @if (error()) {
        <div class="print-message alert error" role="alert">{{ error() }}</div>
      }

      @if (loading()) {
        <div class="print-message">Cargando datos del contrato...</div>
      }

      @if (!loading() && contractData(); as data) {
        <div class="print-content" aria-label="Vista de impresion del contrato">
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
        </div>
      }
    </div>
  `,
})
export class ContractPrintComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly contractService = inject(ContractService);

  readonly loading = signal(false);
  readonly error = signal('');
  readonly contractData = signal<ContractGenerationData | null>(null);
  readonly renderer = signal<ContractRendererType>('base');

  ngOnInit(): void {
    const employeeContractId = Number(this.route.snapshot.paramMap.get('employeeContractId'));
    if (!employeeContractId || Number.isNaN(employeeContractId)) {
      this.error.set('Id de contrato invalido.');
      return;
    }

    this.loadContract(employeeContractId);
  }

  printContract(): void {
    window.print();
  }

  goBack(): void {
    if (window.history.length > 1) {
      window.history.back();
      return;
    }

    window.close();
  }

  private loadContract(employeeContractId: number): void {
    this.loading.set(true);
    this.error.set('');

    this.contractService.getContractGenerationData(employeeContractId)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (data) => {
          const renderer = resolveContractRenderer(data);
          const workValidationError = renderer === 'work' ? validateWorkContractData(data) : '';

          if (workValidationError) {
            this.error.set(workValidationError);
            this.contractData.set(null);
            return;
          }

          this.contractData.set(data);
          this.renderer.set(renderer);
        },
        error: (error) => {
          this.error.set(apiErrorMessage(error, 'No fue posible cargar la vista de impresion del contrato.'));
          this.contractData.set(null);
        },
      });
  }

}
