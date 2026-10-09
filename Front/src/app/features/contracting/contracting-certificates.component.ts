import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { AuthService } from '../../core/services/auth.service';
import { ContractingService } from '../../core/services/contracting.service';
import { apiErrorMessage } from '../../shared/api-error';
import { EmployeeContract } from '../../core/models/api.models';

export interface CertificateFormat {
  id_documento_formato?: number | null;
  clave_formato?: string | null;
  codigo_formato?: string | null;
  nombre?: string | null;
  variante?: string | null;
  version_formato?: string | null;
  titulo?: string | null;
  proceso?: string | null;
}

const FIRST_CERTIFICATE_KEY = 'CERTIFICADO_LABORAL_ACTIVO';
const FIRST_CERTIFICATE_CODE = 'F-002';

@Component({
  standalone: true,
  imports: [RouterLink],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Contratacion</p>
        <h1>Certificados laborales</h1>
        <p class="muted">Tipos de certificado disponibles para la ficha de ingreso.</p>
      </div>
      <a class="btn ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'profile']">Volver a ficha</a>
    </div>

    <section class="panel">
      <div class="row-actions" style="margin-bottom:1rem">
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'profile']">Ficha</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'contracts']">Contratos</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'social-security']">Seguridad social</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'medical-exams']">Examenes</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'documents']">Documentos</a>
        <a class="btn small secondary" [routerLink]="['/admin/contracting/employees', employeeId, 'certificates']">Certificados</a>
      </div>

      @if (error()) {
        <div class="alert error" role="alert">
          {{ error() }}
          <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button>
        </div>
      }

      <div class="table-wrap">
        <table>
          <thead>
            <tr><th>Tipo</th><th>Codigo</th><th>Version</th><th>Proceso</th><th>Contrato</th><th>Acción</th></tr>
          </thead>
          <tbody>
            @for (certificate of displayedCertificates(); track certificate.clave_formato + ':' + certificate.variante) {
              <tr>
                <td><strong>{{ certificate.nombre || certificate.titulo || certificate.clave_formato }}</strong></td>
                <td><span class="badge">BBTH - {{ formatCode(certificate) }}</span></td>
                <td>{{ certificate.version_formato || 'Sin version' }}</td>
                <td>{{ certificate.proceso || 'Sin proceso' }}</td>
                <td>{{ selectedContractLabel() }}</td>
                <td class="actions-cell">
                  @if (isFirstCertificate(certificate)) {
                    @if (certificate.variante === 'SALARIO_AFILIACIONES') {
                      <label>Fondo de solidaridad
                        <input maxlength="200" [value]="solidarity()" (input)="updateSupplied('solidarity', $any($event.target).value)" [disabled]="generating() || downloading()" />
                      </label>
                      <label>Retención en la fuente
                        <input maxlength="200" [value]="withholding()" (input)="updateSupplied('withholding', $any($event.target).value)" [disabled]="generating() || downloading()" />
                      </label>
                      <p class="muted">Ambos campos son obligatorios. Escriba «No aplica» solo cuando corresponda.</p>
                    }
                    <button
                      class="btn small primary"
                      type="button"
                      (click)="generate(certificate)"
                      [disabled]="generating() || downloading() || !selectedContract() || !isConfigured(certificate)"
                      [title]="isConfigured(certificate) ? 'Generar datos oficiales del certificado' : 'Configuración de generación pendiente'"
                    >
                      {{ generating() ? 'Cargando...' : 'Generar' }}
                    </button>
                  } @else {
                    <span class="muted">Próximamente</span>
                  }
                </td>
              </tr>
            } @empty {
              <tr><td colspan="6" class="empty">{{ loading() ? 'Cargando certificados...' : 'No hay certificados disponibles para este empleado.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>

      @if (generationData()) {
        <section class="panel" style="margin-top:1rem">
          <div class="section-title">
            <div>
              <p class="eyebrow">Vista previa de generación</p>
              <h2>{{ firstCertificateName() }}</h2>
            </div>
            <span class="badge success">Datos oficiales consultados</span>
          </div>
          <pre class="code-block">{{ generationDataJson }}</pre>
          <button
            class="btn small primary"
            type="button"
            (click)="download()"
            [disabled]="downloading()"
          >
            {{ downloading() ? 'Descargando...' : 'Descargar PDF' }}
          </button>
        </section>
      }
    </section>
  `,
})
export class ContractingCertificatesComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly route = inject(ActivatedRoute);
  private readonly service = inject(ContractingService);
  readonly certificates = signal<CertificateFormat[]>([]);
  readonly contracts = signal<EmployeeContract[]>([]);
  readonly generationData = signal<Record<string, unknown> | null>(null);
  readonly loading = signal(false);
  readonly generating = signal(false);
  readonly downloading = signal(false);
  readonly error = signal('');
  readonly firstCertificateCode = FIRST_CERTIFICATE_CODE;
  readonly solidarity = signal('');
  readonly withholding = signal('');
  readonly selectedFormat = signal<CertificateFormat | null>(null);
  private confirmed: { key: string; variant: string; contractId: number; supplied?: { fondo_solidaridad: string; retencion_fuente: string } } | null = null;
  private contextRevision = 0;
  employeeId = 0;

  ngOnInit(): void {
    this.employeeId = Number(this.route.snapshot.paramMap.get('employeeId'));
    this.load();
  }

  load(): void {
    this.contextRevision++;
    this.loading.set(true);
    this.error.set('');
    this.generationData.set(null);
    this.confirmed = null;
    this.service.getCertificates(this.employeeId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (certificates) => this.certificates.set(certificates),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar los certificados.')),
    });
    this.service.getContracts(this.employeeId).subscribe({
      next: (contracts) => this.contracts.set(contracts),
      error: () => this.contracts.set([]),
    });
  }

  generate(certificate: CertificateFormat): void {
    const revision = ++this.contextRevision;
    const contract = this.selectedContract();
    if (!contract || !this.isFirstCertificate(certificate)) return;
    const contractId = contract.id_empleado_contrato ?? contract.id_contrato_empleado;
    if (!contractId) {
      this.error.set('No fue posible identificar el contrato seleccionado.');
      return;
    }
    const variant = certificate.variante || 'GENERAL';
    const supplied = variant === 'SALARIO_AFILIACIONES' ? { fondo_solidaridad: this.solidarity().trim(), retencion_fuente: this.withholding().trim() } : undefined;
    if (supplied && Object.values(supplied).some(value => !value || value.length > 200 || /[<>\r\n]/.test(value))) {
      this.error.set('Complete fondo de solidaridad y retención en la fuente: hasta 200 caracteres, sin HTML ni saltos de línea.');
      this.generationData.set(null);
      this.confirmed = null;
      return;
    }
    const context = { key: certificate.clave_formato!, variant, contractId, supplied };
    this.selectedFormat.set({ ...certificate });
    this.confirmed = null;
    this.generating.set(true);
    this.error.set('');
    this.generationData.set(null);
    this.service
      .getCertificateGenerationData(this.employeeId, context.key, contractId, variant, supplied)
      .pipe(finalize(() => {
        if (revision === this.contextRevision) this.generating.set(false);
      }))
      .subscribe({
        next: (data) => { if (revision === this.contextRevision) { this.confirmed = context; this.generationData.set(data); } },
        error: (error) => {
          if (revision === this.contextRevision) this.error.set(apiErrorMessage(error, 'No fue posible generar los datos del certificado.'));
        },
      });
  }
download(): void {
    const context = this.confirmed;
    if (!context || !this.generationData()) {
      this.error.set('No fue posible identificar el contrato seleccionado.');
      return;
    }
    this.downloading.set(true);
    this.error.set('');
    this.service.downloadCertificate(this.employeeId, context.key, context.contractId, context.variant, context.supplied).subscribe({
      next: async (blob) => {
        const header = new TextDecoder().decode(await blob.slice(0, 8).arrayBuffer());
        if (!header.startsWith('%PDF-')) {
          this.downloading.set(false);
          this.error.set('La respuesta del servidor no es un archivo PDF válido.');
          return;
        }

        const url = URL.createObjectURL(blob);
        const anchor = document.createElement('a');
        anchor.href = url;
        anchor.download = 'BBTH-F-002-CERTIFICADO-LABORAL.pdf';
        anchor.style.display = 'none';
        document.body.appendChild(anchor);
        try {
          anchor.click();
        } finally {
          anchor.remove();
          setTimeout(() => URL.revokeObjectURL(url), 60_000);
          this.downloading.set(false);
        }
      },
      error: (error) => {
        this.downloading.set(false);
        this.error.set(apiErrorMessage(error, 'No fue posible descargar el certificado.'));
      },
    });
  }

  
  selectedContract(): EmployeeContract | null {
    return this.contracts().find((contract) => contract.estado_contrato === 'ACTIVO') ?? this.contracts()[0] ?? null;
  }

  selectedContractLabel(): string {
    const contract = this.selectedContract();
    return contract?.id_empleado_contrato || contract?.id_contrato_empleado
      ? `Contrato #${contract.id_empleado_contrato ?? contract.id_contrato_empleado}`
      : 'Sin contrato';
  }

  isFirstCertificate(certificate: CertificateFormat): boolean {
    return certificate.clave_formato === FIRST_CERTIFICATE_KEY
      && ['GENERAL', 'SALARIO_AFILIACIONES'].includes(certificate.variante || 'GENERAL');
  }

  isConfigured(certificate: CertificateFormat): boolean {
    return !!certificate.id_documento_formato
      && !!certificate.clave_formato
      && !!certificate.codigo_formato;
  }

  formatCode(certificate: CertificateFormat): string {
    const code = certificate.codigo_formato?.trim();
    return code?.replace(/^BBTH[-_]?/, '') || FIRST_CERTIFICATE_CODE;
  }

  displayedCertificates(): CertificateFormat[] {
    if (this.certificates().length) return this.certificates();
    return [{
      clave_formato: FIRST_CERTIFICATE_KEY,
      codigo_formato: 'BBTH-F-002',
      nombre: 'CERTIFICADO LABORAL A COLABORADOR',
      variante: 'GENERAL',
      version_formato: 'Pendiente de configuración',
      titulo: 'Certificado laboral activo',
      proceso: 'Emisión de certificado laboral',
    }];
  }

  firstCertificateName(): string {
    return this.selectedFormat()?.nombre || 'BBTH - F-002 - CERTIFICADO LABORAL A COLABORADOR';
  }

  updateSupplied(field: 'solidarity' | 'withholding', value: string): void {
    this.contextRevision++;
    this[field].set(value);
    this.confirmed = null;
    this.generationData.set(null);
  }

  get generationDataJson(): string {
    return this.generationData() ? JSON.stringify(this.generationData(), null, 2) : '';
  }
}
