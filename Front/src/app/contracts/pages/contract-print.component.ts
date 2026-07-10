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

      @page {
        size: A4;
        margin: 0;
      }

      @media print {
        .print-toolbar {
          display: none !important;
        }

        body {
          margin: 0;
          background: #fff;
        }

        .print-view {
          background: #fff;
        }

        .print-content {
          padding: 0;
        }

        .contract-page {
          box-shadow: none !important;
          margin: 0 !important;
        }
      }
    `,
  ],
  template: `
    <div class="print-view">
      <div class="print-toolbar">
        <button class="btn primary" type="button" (click)="printContract()">Imprimir / Guardar como PDF</button>
        <button class="btn ghost" type="button" (click)="closeWindow()">Cerrar</button>
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

  closeWindow(): void {
    window.close();
  }

  private loadContract(employeeContractId: number): void {
    this.loading.set(true);
    this.error.set('');

    this.contractService.getContractGenerationData(employeeContractId)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (data) => {
          this.contractData.set(data);
          this.renderer.set(this.suggestRenderer(data));
        },
        error: (error) => {
          this.error.set(apiErrorMessage(error, 'No fue posible cargar la vista de impresion del contrato.'));
          this.contractData.set(null);
        },
      });
  }

  private suggestRenderer(data: ContractGenerationData): ContractRendererType {
    const type = (
      data.contrato.tipo_contrato
      || data.contrato.nombre_tipo_contrato
      || data.parametros.plantilla.tipo_contrato
      || ''
    ).toUpperCase();

    if (type.includes('OBRA') || type.includes('LABOR')) {
      return 'work';
    }

    if (type.includes('FIJO')) {
      return 'fixed-term';
    }

    if (type.includes('INDEFIN')) {
      return 'indefinite';
    }

    return 'base';
  }
}
