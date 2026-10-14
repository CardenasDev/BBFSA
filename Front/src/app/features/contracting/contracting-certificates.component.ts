import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { AuthService } from '../../core/services/auth.service';
import { ContractingService } from '../../core/services/contracting.service';
import { RetirementService } from '../../core/services/retirement.service';
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
const RETIREMENT_CERTIFICATE_KEY = 'CERTIFICADO_LABORAL_RETIRO';
const RETIREMENT_CERTIFICATE_CODE = 'F-003';
const CHECKLIST_CERTIFICATE_KEY = 'CONSTANCIA_ENTREGA_RETIRO';
const CHECKLIST_CERTIFICATE_CODE = 'F-004';
const ACCEPTANCE_CERTIFICATE_KEY = 'ACEPTACION_RENUNCIA';
const ACCEPTANCE_CERTIFICATE_CODE = 'F-005';
const CESANTIAS_CERTIFICATE_KEY = 'CESANTIAS_VIVIENDA';
const CESANTIAS_CERTIFICATE_CODE = 'F-011';
const CESANTIAS_END_CERTIFICATE_KEY = 'CESANTIAS_FIN_CONTRATO';
const CESANTIAS_END_CERTIFICATE_CODE = 'F-012';
const NON_RENEWAL_CERTIFICATE_KEY = 'NO_RENOVACION_CONTRATO';
const NON_RENEWAL_CERTIFICATE_CODE = 'F-015';

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
        <div class="alert error" role="alert" style="max-width:520px;margin:0 auto 1rem;padding:1.25rem 1.5rem;border-radius:8px">
          <div style="display:flex;gap:0.75rem;align-items:flex-start">
            <span style="flex-shrink:0;width:32px;height:32px;border-radius:50%;background:#fee2e2;color:#dc2626;display:flex;align-items:center;justify-content:center;font-weight:700">!</span>
            <div style="flex:1">
              <p style="margin:0 0 0.5rem;font-weight:600;color:#991b1b">Revisa la información</p>
              @if (errorFieldEntries().length) {
                <div style="margin:0.5rem 0;color:#7f1d1d;font-size:0.9rem;line-height:1.6">
                  @for (entry of errorFieldEntries(); track entry.key) {
                    <p style="margin:0.25rem 0"><strong>{{ fieldLabel(entry.key) }}:</strong> {{ entry.value.join(' ') }}</p>
                  }
                </div>
              } @else {
                <p style="margin:0.5rem 0;color:#7f1d1d;font-size:0.9rem">{{ error() }}</p>
              }
            </div>
          </div>
          <div style="margin-top:1rem;text-align:right">
            <button class="btn small secondary" type="button" (click)="clearError()">Entendido</button>
          </div>
        </div>
      }

      <div class="tabs" style="display:flex;gap:0.5rem;margin-bottom:1rem;border-bottom:2px solid #e5e7eb;padding-bottom:0">
        <button
          type="button"
          class="tab-btn"
          (click)="activeTab.set('F-002')"
          style="padding:0.5rem 1rem;border:none;background:transparent;cursor:pointer;font-weight:500;color:#6b7280;border-bottom:2px solid transparent;margin-bottom:-2px"
          [style.color]="activeTab() === 'F-002' ? '#111827' : ''"
          [style.border-bottom-color]="activeTab() === 'F-002' ? '#3b82f6' : ''"
          [style.font-weight]="activeTab() === 'F-002' ? '600' : ''"
        >F-002</button>
        <button
          type="button"
          class="tab-btn"
          (click)="activeTab.set('F-003')"
          style="padding:0.5rem 1rem;border:none;background:transparent;cursor:pointer;font-weight:500;color:#6b7280;border-bottom:2px solid transparent;margin-bottom:-2px"
          [style.color]="activeTab() === 'F-003' ? '#111827' : ''"
          [style.border-bottom-color]="activeTab() === 'F-003' ? '#3b82f6' : ''"
          [style.font-weight]="activeTab() === 'F-003' ? '600' : ''"
        >F-003</button>
        <button
          type="button"
          class="tab-btn"
          (click)="activeTab.set('F-004')"
          style="padding:0.5rem 1rem;border:none;background:transparent;cursor:pointer;font-weight:500;color:#6b7280;border-bottom:2px solid transparent;margin-bottom:-2px"
          [style.color]="activeTab() === 'F-004' ? '#111827' : ''"
          [style.border-bottom-color]="activeTab() === 'F-004' ? '#3b82f6' : ''"
          [style.font-weight]="activeTab() === 'F-004' ? '600' : ''"
        >F-004</button>
        <button
          type="button"
          class="tab-btn"
          (click)="activeTab.set('F-005')"
          style="padding:0.5rem 1rem;border:none;background:transparent;cursor:pointer;font-weight:500;color:#6b7280;border-bottom:2px solid transparent;margin-bottom:-2px"
          [style.color]="activeTab() === 'F-005' ? '#111827' : ''"
          [style.border-bottom-color]="activeTab() === 'F-005' ? '#3b82f6' : ''"
          [style.font-weight]="activeTab() === 'F-005' ? '600' : ''"
        >F-005</button>
        <button
          type="button"
          class="tab-btn"
          (click)="activeTab.set('F-011')"
          style="padding:0.5rem 1rem;border:none;background:transparent;cursor:pointer;font-weight:500;color:#6b7280;border-bottom:2px solid transparent;margin-bottom:-2px"
          [style.color]="activeTab() === 'F-011' ? '#111827' : ''"
          [style.border-bottom-color]="activeTab() === 'F-011' ? '#3b82f6' : ''"
          [style.font-weight]="activeTab() === 'F-011' ? '600' : ''"
        >F-011</button>
        <button
          type="button"
          class="tab-btn"
          (click)="activeTab.set('F-012')"
          style="padding:0.5rem 1rem;border:none;background:transparent;cursor:pointer;font-weight:500;color:#6b7280;border-bottom:2px solid transparent;margin-bottom:-2px"
          [style.color]="activeTab() === 'F-012' ? '#111827' : ''"
          [style.border-bottom-color]="activeTab() === 'F-012' ? '#3b82f6' : ''"
          [style.font-weight]="activeTab() === 'F-012' ? '600' : ''"
        >F-012</button>
        <button
          type="button"
          class="tab-btn"
          (click)="activeTab.set('F-015')"
          style="padding:0.5rem 1rem;border:none;background:transparent;cursor:pointer;font-weight:500;color:#6b7280;border-bottom:2px solid transparent;margin-bottom:-2px"
          [style.color]="activeTab() === 'F-015' ? '#111827' : ''"
          [style.border-bottom-color]="activeTab() === 'F-015' ? '#3b82f6' : ''"
          [style.font-weight]="activeTab() === 'F-015' ? '600' : ''"
        >F-015</button>
      </div>

      @if (activeTab() === 'F-002') {
        <div class="table-wrap">
          <table>
            <thead>
              <tr><th>Tipo</th><th>Código</th><th>Versión</th><th>Proceso</th><th>Contrato</th><th>Acción</th></tr>
            </thead>
            <tbody>
              @for (certificate of displayedCertificates(); track certificate.clave_formato + ':' + certificate.variante) {
                <tr>
                  <td><strong>{{ certificate.nombre || certificate.titulo || certificate.clave_formato }}</strong></td>
                  <td><span class="badge">BBTH - {{ formatCode(certificate) }}</span></td>
                  <td>{{ certificate.version_formato || 'Sin versión' }}</td>
                  <td>{{ certificate.proceso || 'Sin proceso' }}</td>
                  <td>{{ selectedContractLabel() }}</td>
                  <td class="actions-cell">
                    @if (certificate.variante === 'SALARIO_AFILIACIONES') {
                      <label>Fondo de solidaridad
                        <input maxlength="200" [value]="solidarity()" (input)="updateSupplied('solidarity', $any($event.target).value)" [disabled]="generating() || downloading()" />
                      </label>
                      <label>Retención en la fuente
                        <input maxlength="200" [value]="withholding()" (input)="updateSupplied('withholding', $any($event.target).value)" [disabled]="generating() || downloading()" />
                      </label>
                      <p class="muted">Ambos campos son obligatorios. Escriba «No aplica» solo cuando corresponda.</p>
                    }
                    @if (certificate.variante === 'HISTORIAL_CONTRACTUAL') {
                      <label>Fecha de inicio de labores
                        <input type="date" [value]="workStartDate()" (input)="updateWorkStartDate($any($event.target).value)" [disabled]="generating() || downloading()" />
                      </label>
                      <p class="muted">Fecha autorizada para el certificado. No modifica el registro del empleado.</p>
                    }
                    <button
                      class="btn small primary"
                      type="button"
                      (click)="generate(certificate)"
                      [disabled]="generating() || downloading() || !selectedContract() || !isConfigured(certificate)"
                    >
                      {{ generating() ? 'Cargando...' : 'Generar' }}
                    </button>
                  </td>
                </tr>
              } @empty {
                <tr><td colspan="6" class="empty">{{ loading() ? 'Cargando certificados...' : 'No hay certificados disponibles para este empleado.' }}</td></tr>
              }
            </tbody>
          </table>
        </div>
      }

      @if (activeTab() === 'F-003') {
        <div class="table-wrap">
          <table>
            <thead>
              <tr><th>Tipo</th><th>Código</th><th>Versión</th><th>Retiro</th><th>Acción</th></tr>
            </thead>
            <tbody>
              @for (certificate of retirementCertificates(); track certificate.clave_formato + ':' + certificate.variante) {
                <tr>
                  <td><strong>{{ certificate.nombre || certificate.titulo || certificate.clave_formato }}</strong></td>
                  <td><span class="badge">BBTH - {{ formatCode(certificate) }}</span></td>
                  <td>{{ certificate.version_formato || 'Sin versión' }}</td>
                  <td>{{ selectedRetirement()?.motivo_retiro || 'Sin retiro' }}</td>
                  <td class="actions-cell">
                    <label>Fondo de solidaridad
                      <input maxlength="200" [value]="retirementSolidarity()" (input)="updateRetirementSupplied('solidarity', $any($event.target).value)" [disabled]="generating() || downloading()" />
                    </label>
                    <label>Retención en la fuente
                      <input maxlength="200" [value]="retirementWithholding()" (input)="updateRetirementSupplied('withholding', $any($event.target).value)" [disabled]="generating() || downloading()" />
                    </label>
                    <label>Auxilio de transporte
                      <input maxlength="200" [value]="retirementTransport()" (input)="updateRetirementSupplied('transport', $any($event.target).value)" [disabled]="generating() || downloading()" />
                    </label>
                    <p class="muted">Campos obligatorios suministrados por el usuario autorizado.</p>
                    <button
                      class="btn small primary"
                      type="button"
                      (click)="generateRetirement(certificate)"
                      [disabled]="generating() || downloading() || !selectedRetirement() || !isConfigured(certificate)"
                    >
                      {{ generating() ? 'Cargando...' : 'Generar' }}
                    </button>
                  </td>
                </tr>
              } @empty {
                <tr><td colspan="5" class="empty">{{ loading() ? 'Cargando certificados...' : 'No hay certificados de retiro disponibles.' }}</td></tr>
              }
            </tbody>
          </table>
        </div>
      }

      @if (activeTab() === 'F-004') {        <div class="table-wrap">
          <table>
            <thead>
              <tr><th>Tipo</th><th>Código</th><th>Versión</th><th>Retiro</th><th>Acción</th></tr>
            </thead>
            <tbody>
              @for (certificate of checklistCertificates(); track certificate.clave_formato + ':' + certificate.variante) {
                <tr>
                  <td><strong>{{ certificate.nombre || certificate.titulo || certificate.clave_formato }}</strong></td>
                  <td><span class="badge">BBTH - {{ formatCode(certificate) }}</span></td>
                  <td>{{ certificate.version_formato || 'Sin versión' }}</td>
                  <td>{{ selectedRetirement()?.motivo_retiro || 'Sin retiro' }}</td>
                  <td class="actions-cell">
                    <button
                      class="btn small primary"
                      type="button"
                      (click)="generateChecklist(certificate)"
                      [disabled]="generating() || downloading() || !selectedRetirement() || !isConfigured(certificate)"
                    >
                      {{ generating() ? 'Cargando...' : 'Generar' }}
                    </button>
                  </td>
                </tr>
              } @empty {
                <tr><td colspan="5" class="empty">{{ loading() ? 'Cargando certificados...' : 'No hay checklist de retiro disponibles.' }}</td></tr>
              }
            </tbody>
          </table>
        </div>
      }

      @if (activeTab() === 'F-005') {
        <div class="table-wrap">
          <table>
            <thead>
              <tr><th>Tipo</th><th>Código</th><th>Versión</th><th>Retiro</th><th>Acción</th></tr>
            </thead>
            <tbody>
              @for (certificate of acceptanceCertificates(); track certificate.clave_formato + ':' + certificate.variante) {
                <tr>
                  <td><strong>{{ certificate.nombre || certificate.titulo || certificate.clave_formato }}</strong></td>
                  <td><span class="badge">BBTH - {{ formatCode(certificate) }}</span></td>
                  <td>{{ certificate.version_formato || 'Sin versión' }}</td>
                  <td>{{ selectedRetirement()?.motivo_retiro || 'Sin retiro' }}</td>
                  <td class="actions-cell">
                    <label>Fecha de presentación de la renuncia
                      <input type="date" [value]="acceptancePresentationDate()" (input)="updateAcceptanceDate($any($event.target).value)" [disabled]="generating() || downloading()" />
                    </label>
                    <p class="muted">Fecha de la comunicación de renuncia. No modifica el registro del retiro.</p>
                    <button
                      class="btn small primary"
                      type="button"
                      (click)="generateAcceptance(certificate)"
                      [disabled]="generating() || downloading() || !selectedRetirement() || !isConfigured(certificate)"
                    >
                      {{ generating() ? 'Cargando...' : 'Generar' }}
                    </button>
                  </td>
                </tr>
              } @empty {
                <tr><td colspan="5" class="empty">{{ loading() ? 'Cargando certificados...' : 'No hay cartas de aceptación disponibles.' }}</td></tr>
              }
            </tbody>
          </table>
        </div>
      }

      @if (activeTab() === 'F-011') {
        <div class="table-wrap">
          <table>
            <thead>
              <tr><th>Tipo</th><th>Código</th><th>Versión</th><th>Acción</th></tr>
            </thead>
            <tbody>
              @for (certificate of cesantiasCertificates(); track certificate.clave_formato + ':' + certificate.variante) {
                <tr>
                  <td><strong>{{ certificate.nombre || certificate.titulo || certificate.clave_formato }}</strong></td>
                  <td><span class="badge">BBTH - {{ formatCode(certificate) }}</span></td>
                  <td>{{ certificate.version_formato || 'Sin versión' }}</td>
                  <td class="actions-cell">
                    <label>Modalidad del retiro
                      <select [value]="cesantiasModality()" (change)="updateCesantiasModality($any($event.target).value)" [disabled]="generating() || downloading()">
                        <option value="PARCIAL">Parcial</option>
                        <option value="TOTAL">Total</option>
                      </select>
                    </label>
                    <label>Concepto del retiro
                      <input maxlength="200" [value]="cesantiasConcept()" (input)="updateCesantiasConcept($any($event.target).value)" [disabled]="generating() || downloading()" />
                    </label>
                    <label>Monto a retirar
                      <input inputmode="decimal" placeholder="0.00" [value]="cesantiasAmount()" (input)="updateCesantiasAmount($any($event.target).value)" [disabled]="generating() || downloading()" />
                    </label>
                    <p class="muted">Campos suministrados por el usuario autorizado. No modifican registros del sistema.</p>
                    <button
                      class="btn small primary"
                      type="button"
                      (click)="generateCesantias(certificate)"
                      [disabled]="generating() || downloading() || !isConfigured(certificate)"
                    >
                      {{ generating() ? 'Cargando...' : 'Generar' }}
                    </button>
                  </td>
                </tr>
              } @empty {
                <tr><td colspan="4" class="empty">{{ loading() ? 'Cargando certificados...' : 'No hay cartas de cesantías disponibles.' }}</td></tr>
              }
            </tbody>
          </table>
        </div>
      }

      @if (activeTab() === 'F-012') {
        <div class="table-wrap">
          <table>
            <thead>
              <tr><th>Tipo</th><th>Código</th><th>Versión</th><th>Acción</th></tr>
            </thead>
            <tbody>
              @for (certificate of cesantiasEndCertificates(); track certificate.clave_formato + ':' + certificate.variante) {
                <tr>
                  <td><strong>{{ certificate.nombre || certificate.titulo || certificate.clave_formato }}</strong></td>
                  <td><span class="badge">BBTH - {{ formatCode(certificate) }}</span></td>
                  <td>{{ certificate.version_formato || 'Sin versión' }}</td>
                  <td class="actions-cell">
                    <label>Fecha inicial del periodo
                      <input type="date" [value]="cesantiasEndFrom()" (input)="updateCesantiasEnd('from', $any($event.target).value)" [disabled]="generating() || downloading()" />
                    </label>
                    <label>Fecha final del periodo
                      <input type="date" [value]="cesantiasEndTo()" (input)="updateCesantiasEnd('to', $any($event.target).value)" [disabled]="generating() || downloading()" />
                    </label>
                    <label>NIT de la empresa
                      <input maxlength="20" [value]="cesantiasEndNit()" (input)="updateCesantiasEnd('nit', $any($event.target).value)" [disabled]="generating() || downloading()" />
                    </label>
                    <label>Correo de contacto
                      <input maxlength="150" [value]="cesantiasEndEmail()" (input)="updateCesantiasEnd('email', $any($event.target).value)" [disabled]="generating() || downloading()" />
                    </label>
                    <label>Teléfono de contacto
                      <input maxlength="30" [value]="cesantiasEndPhone()" (input)="updateCesantiasEnd('phone', $any($event.target).value)" [disabled]="generating() || downloading()" />
                    </label>
                    <p class="muted">Campos suministrados por el usuario autorizado. No modifican registros del sistema.</p>
                    <button
                      class="btn small primary"
                      type="button"
                      (click)="generateCesantiasEnd(certificate)"
                      [disabled]="generating() || downloading() || !isConfigured(certificate)"
                    >
                      {{ generating() ? 'Cargando...' : 'Generar' }}
                    </button>
                  </td>
                </tr>
              } @empty {
                <tr><td colspan="4" class="empty">{{ loading() ? 'Cargando certificados...' : 'No hay cartas de cesantías por finalización disponibles.' }}</td></tr>
              }
            </tbody>
          </table>
        </div>
      }

      @if (activeTab() === 'F-015') {
        <div class="table-wrap">
          <table>
            <thead>
              <tr><th>Tipo</th><th>Código</th><th>Versión</th><th>Acción</th></tr>
            </thead>
            <tbody>
              @for (certificate of nonRenewalCertificates(); track certificate.clave_formato + ':' + certificate.variante) {
                <tr>
                  <td><strong>{{ certificate.nombre || certificate.titulo || certificate.clave_formato }}</strong></td>
                  <td><span class="badge">BBTH - {{ formatCode(certificate) }}</span></td>
                  <td>{{ certificate.version_formato || 'Sin versión' }}</td>
                  <td class="actions-cell">
                    <label>Contrato a término fijo
                      <select [value]="nonRenewalContractId() ?? ''" (change)="updateNonRenewalContract($any($event.target).value)" [disabled]="generating() || downloading()">
                        <option value="">Seleccione contrato</option>
                        @for (contract of contracts(); track contract.id_empleado_contrato ?? contract.id_contrato_empleado) {
                          <option [value]="contract.id_empleado_contrato ?? contract.id_contrato_empleado ?? ''">Contrato #{{ contract.id_empleado_contrato ?? contract.id_contrato_empleado }} — {{ contractLabel(contract) }}</option>
                        }
                      </select>
                    </label>
                    <label>NIT de la empresa
                      <input maxlength="20" [value]="nonRenewalNit()" (input)="updateNonRenewalNit($any($event.target).value)" [disabled]="generating() || downloading()" />
                    </label>
                    <p class="muted">Seleccione el contrato a término fijo. El NIT es editable. No modifican registros del sistema.</p>
                    <button
                      class="btn small primary"
                      type="button"
                      (click)="generateNonRenewal(certificate)"
                      [disabled]="generating() || downloading() || !nonRenewalContractId() || !isConfigured(certificate)"
                    >
                      {{ generating() ? 'Cargando...' : 'Generar' }}
                    </button>
                  </td>
                </tr>
              } @empty {
                <tr><td colspan="4" class="empty">{{ loading() ? 'Cargando certificados...' : 'No hay cartas de no renovación disponibles.' }}</td></tr>
              }
            </tbody>
          </table>
        </div>
      }

      @if (generationData()) {
        <div
          role="dialog"
          aria-modal="true"
          aria-label="Certificado listo para descargar"
          style="position:fixed;inset:0;background:rgba(0,0,0,0.5);display:flex;align-items:center;justify-content:center;z-index:50;padding:1rem"
          (click)="closePreview()"
        >
          <div
            style="background:#fff;border-radius:12px;padding:1.5rem;max-width:480px;width:100%;box-shadow:0 20px 50px rgba(0,0,0,0.25)"
            (click)="$event.stopPropagation()"
          >
            <p class="eyebrow">Vista previa de generación</p>
            <h2 style="margin:0.25rem 0 0.5rem">{{ firstCertificateName() }}</h2>
            <p style="margin:0 0 0.5rem"><span class="badge success">Datos oficiales consultados</span></p>
            <p class="muted" style="margin:0 0 0.75rem">El documento está listo con los datos oficiales consultados.</p>
            @if ($any(generationData())?.fecha_expedicion) {
              <p style="margin:0 0 0.75rem"><strong>Fecha de expedición:</strong> {{ $any(generationData())?.fecha_expedicion }}</p>
            }
            @if ($any(generationData())?.advertencias?.length) {
              <div class="alert error" role="alert" style="margin:0 0 0.75rem">
                <p style="margin:0 0 0.5rem"><strong>Advertencias</strong></p>
                <ul style="margin:0;padding-left:1.25rem">
                  @for (warning of $any(generationData())?.advertencias; track warning) {
                    <li>{{ warning }}</li>
                  }
                </ul>
              </div>
            }
            <div class="row-actions" style="margin-top:1rem;justify-content:flex-end">
              <button class="btn small ghost" type="button" (click)="closePreview()" [disabled]="downloading()">Cerrar</button>
              <button class="btn small primary" type="button" (click)="download()" [disabled]="downloading()">
                {{ downloading() ? 'Descargando...' : 'Descargar PDF' }}
              </button>
            </div>
          </div>
        </div>
      }
    </section>
  `,
})
export class ContractingCertificatesComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly route = inject(ActivatedRoute);
  private readonly service = inject(ContractingService);
  private readonly retirementService = inject(RetirementService);
  readonly certificates = signal<CertificateFormat[]>([]);
  readonly retirementCertificates = signal<CertificateFormat[]>([]);
  readonly checklistCertificates = signal<CertificateFormat[]>([]);
  readonly acceptanceCertificates = signal<CertificateFormat[]>([]);
  readonly cesantiasCertificates = signal<CertificateFormat[]>([]);
  readonly cesantiasEndCertificates = signal<CertificateFormat[]>([]);
  readonly nonRenewalCertificates = signal<CertificateFormat[]>([]);
  readonly contracts = signal<EmployeeContract[]>([]);
  readonly retirements = signal<Array<{ id_retiro: number; motivo_retiro: string; fecha_retiro: string }>>([]);
  readonly generationData = signal<Record<string, unknown> | null>(null);
  readonly loading = signal(false);
  readonly generating = signal(false);
  readonly downloading = signal(false);
  readonly error = signal('');
  readonly errorFields = signal<Record<string, string[]>>({});
  readonly firstCertificateCode = FIRST_CERTIFICATE_CODE;
  readonly retirementCertificateCode = RETIREMENT_CERTIFICATE_CODE;
  readonly checklistCertificateCode = CHECKLIST_CERTIFICATE_CODE;
  readonly acceptanceCertificateCode = ACCEPTANCE_CERTIFICATE_CODE;
  readonly cesantiasCertificateCode = CESANTIAS_CERTIFICATE_CODE;
  readonly cesantiasEndCertificateCode = CESANTIAS_END_CERTIFICATE_CODE;
  readonly nonRenewalCertificateCode = NON_RENEWAL_CERTIFICATE_CODE;
  readonly activeTab = signal<'F-002' | 'F-003' | 'F-004' | 'F-005' | 'F-011' | 'F-012' | 'F-015'>('F-002');
  readonly solidarity = signal('');
  readonly withholding = signal('');
  readonly workStartDate = signal('');
  readonly retirementSolidarity = signal('');
  readonly retirementWithholding = signal('');
  readonly retirementTransport = signal('');
  readonly acceptancePresentationDate = signal('');
  readonly cesantiasModality = signal('PARCIAL');
  readonly cesantiasConcept = signal('');
  readonly cesantiasAmount = signal('');
  readonly cesantiasEndFrom = signal('');
  readonly cesantiasEndTo = signal('');
  readonly cesantiasEndNit = signal('900747203-1');
  readonly cesantiasEndEmail = signal('secretariabarroblanco@gmail.com');
  readonly cesantiasEndPhone = signal('3153188486');
  readonly nonRenewalContractId = signal<number | null>(null);
  readonly nonRenewalNit = signal('900747203');
  readonly selectedFormat = signal<CertificateFormat | null>(null);
  private confirmed: { key: string; variant: string; contractId: number; retirementId?: number; supplied?: { fondo_solidaridad?: string; retencion_fuente?: string; fecha_inicio_labores?: string; auxilio_transporte?: string; fecha_presentacion_renuncia?: string; modalidad?: string; concepto_retiro?: string; monto_retiro?: string; fecha_desde?: string; fecha_hasta?: string; nit_empresa?: string; correo_contacto?: string; telefono_contacto?: string } } | null = null;
  private contextRevision = 0;
  employeeId = 0;

  errorFieldEntries(): Array<{ key: string; value: string[] }> {
    return Object.entries(this.errorFields()).map(([key, value]) => ({ key, value }));
  }

  fieldLabel(field: string): string {
    const labels: Record<string, string> = {
      cargo: 'Cargo',
      tipo_contrato: 'Tipo de contrato',
      salario_base: 'Salario base',
      fecha_inicio: 'Fecha de suscripción',
      fecha_fin: 'Fecha de vencimiento',
      fecha_retiro: 'Fecha de retiro',
      fecha_presentacion_renuncia: 'Fecha de presentación',
      modalidad: 'Modalidad',
      concepto_retiro: 'Concepto del retiro',
      monto_retiro: 'Monto a retirar',
      fondo_cesantias: 'Fondo de cesantías',
      fecha_desde: 'Fecha inicial',
      fecha_hasta: 'Fecha final',
      nit_empresa: 'NIT de la empresa',
      correo_contacto: 'Correo de contacto',
      telefono_contacto: 'Teléfono de contacto',
      motivo_retiro: 'Motivo de retiro',
      fecha_ingreso: 'Fecha de ingreso',
      firmantes_json: 'Firmantes',
      id_empleado_contrato: 'Contrato',
      eps: 'EPS',
      arl: 'ARL',
      fondo_pension: 'Fondo de pensión',
      caja_compensacion: 'Caja de compensación',
    };
    return labels[field] || field;
  }

  clearError(): void {
    this.error.set('');
    this.errorFields.set({});
  }

  closePreview(): void {
    this.generationData.set(null);
    this.confirmed = null;
  }

  handleError(error: unknown, genericMessage: string): void {
    const err = error as { error?: { errors?: Record<string, string[]> } };
    const fields = err.error?.errors;
    if (fields && typeof fields === 'object' && Object.keys(fields).length) {
      this.error.set('Faltan datos oficiales o configuración para generar el certificado.');
      this.errorFields.set(fields);
    } else {
      this.error.set(apiErrorMessage(error, genericMessage));
      this.errorFields.set({});
    }
  }

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
      error: (error) => {
        if (this.activeTab() === 'F-002') {
          this.error.set(apiErrorMessage(error, 'No fue posible cargar los certificados.'));
        }
      },
    });
    this.service.getContracts(this.employeeId).subscribe({
      next: (contracts) => this.contracts.set(contracts),
      error: () => this.contracts.set([]),
    });
    this.service.getRetirementCertificates(this.employeeId).subscribe({
      next: (certificates) => this.retirementCertificates.set(certificates),
      error: () => this.retirementCertificates.set([]),
    });
    this.service.getChecklistCertificates(this.employeeId).subscribe({
      next: (certificates) => this.checklistCertificates.set(certificates),
      error: () => this.checklistCertificates.set([]),
    });
    this.service.getAcceptanceCertificates(this.employeeId).subscribe({
      next: (certificates) => this.acceptanceCertificates.set(certificates),
      error: () => this.acceptanceCertificates.set([]),
    });
    this.service.getCesantiasCertificates(this.employeeId).subscribe({
      next: (certificates) => this.cesantiasCertificates.set(certificates),
      error: () => this.cesantiasCertificates.set([]),
    });
    this.service.getCesantiasTerminationCertificates(this.employeeId).subscribe({
      next: (certificates) => this.cesantiasEndCertificates.set(certificates),
      error: () => this.cesantiasEndCertificates.set([]),
    });
    this.service.getNonRenewalCertificates(this.employeeId).subscribe({
      next: (certificates) => this.nonRenewalCertificates.set(certificates),
      error: () => this.nonRenewalCertificates.set([]),
    });
    this.retirementService.list({ employee_id: this.employeeId }).subscribe({
      next: (retirements) => this.retirements.set(retirements),
      error: () => this.retirements.set([]),
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
    let supplied: { fondo_solidaridad?: string; retencion_fuente?: string; fecha_inicio_labores?: string } | undefined;
    if (variant === 'SALARIO_AFILIACIONES') {
      supplied = { fondo_solidaridad: this.solidarity().trim(), retencion_fuente: this.withholding().trim() };
      if (Object.values(supplied).some(value => !value || value.length > 200 || /[<>\r\n]/.test(value))) {
        this.error.set('Complete fondo de solidaridad y retención en la fuente: hasta 200 caracteres, sin HTML ni saltos de línea.');
        this.generationData.set(null);
        this.confirmed = null;
        return;
      }
    } else if (variant === 'HISTORIAL_CONTRACTUAL') {
      const date = this.workStartDate().trim();
      if (!date) {
        this.error.set('Indique la fecha de inicio de labores.');
        this.generationData.set(null);
        this.confirmed = null;
        return;
      }
      supplied = { fecha_inicio_labores: date };
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
          if (revision === this.contextRevision) this.handleError(error, 'No fue posible generar los datos del certificado.');
        },
      });
  }

  generateRetirement(certificate: CertificateFormat): void {
    const revision = ++this.contextRevision;
    const retirement = this.selectedRetirement();
    if (!retirement || !this.isRetirementCertificate(certificate)) return;
    const retirementId = retirement.id_retiro;
    if (!retirementId) {
      this.error.set('No fue posible identificar el retiro seleccionado.');
      return;
    }
    const supplied = {
      fondo_solidaridad: this.retirementSolidarity().trim(),
      retencion_fuente: this.retirementWithholding().trim(),
      auxilio_transporte: this.retirementTransport().trim(),
    };
    if (Object.values(supplied).some(value => !value || value.length > 200 || /[<>\r\n]/.test(value))) {
      this.error.set('Complete fondo de solidaridad, retención en la fuente y auxilio de transporte: hasta 200 caracteres, sin HTML ni saltos de línea.');
      this.generationData.set(null);
      this.confirmed = null;
      return;
    }
    const context = { key: certificate.clave_formato!, variant: 'RETIRO', contractId: 0, retirementId, supplied };
    this.selectedFormat.set({ ...certificate });
    this.confirmed = null;
    this.generating.set(true);
    this.error.set('');
    this.generationData.set(null);
    this.service
      .getRetirementCertificateGenerationData(this.employeeId, retirementId, supplied)
      .pipe(finalize(() => {
        if (revision === this.contextRevision) this.generating.set(false);
      }))
      .subscribe({
        next: (data) => { if (revision === this.contextRevision) { this.confirmed = context; this.generationData.set(data); } },
        error: (error) => {
          if (revision === this.contextRevision) this.handleError(error, 'No fue posible generar los datos del certificado de retiro.');
        },
      });
  }

  generateChecklist(certificate: CertificateFormat): void {
    const revision = ++this.contextRevision;
    const retirement = this.selectedRetirement();
    if (!retirement || !this.isChecklistCertificate(certificate)) return;
    const retirementId = retirement.id_retiro;
    if (!retirementId) {
      this.error.set('No fue posible identificar el retiro seleccionado.');
      return;
    }
    const context = { key: certificate.clave_formato!, variant: 'CHECKLIST', contractId: 0, retirementId, supplied: undefined };
    this.selectedFormat.set({ ...certificate });
    this.confirmed = null;
    this.generating.set(true);
    this.error.set('');
    this.errorFields.set({});
    this.generationData.set(null);
    this.service
      .getChecklistGenerationData(this.employeeId, retirementId)
      .pipe(finalize(() => {
        if (revision === this.contextRevision) this.generating.set(false);
      }))
      .subscribe({
        next: (data) => { if (revision === this.contextRevision) { this.confirmed = context; this.generationData.set(data); } },
        error: (error) => {
          if (revision === this.contextRevision) this.handleError(error, 'No fue posible generar los datos del checklist de retiro.');
        },
      });
  }

  isChecklistCertificate(certificate: CertificateFormat): boolean {
    return certificate.clave_formato === CHECKLIST_CERTIFICATE_KEY;
  }

  isAcceptanceCertificate(certificate: CertificateFormat): boolean {
    return certificate.clave_formato === ACCEPTANCE_CERTIFICATE_KEY;
  }

  isCesantiasCertificate(certificate: CertificateFormat): boolean {
    return certificate.clave_formato === CESANTIAS_CERTIFICATE_KEY;
  }

  isCesantiasEndCertificate(certificate: CertificateFormat): boolean {
    return certificate.clave_formato === CESANTIAS_END_CERTIFICATE_KEY;
  }

  isNonRenewalCertificate(certificate: CertificateFormat): boolean {
    return certificate.clave_formato === NON_RENEWAL_CERTIFICATE_KEY;
  }

  updateNonRenewalContract(value: string): void {
    this.contextRevision++;
    this.nonRenewalContractId.set(value ? Number(value) : null);
    this.confirmed = null;
    this.generationData.set(null);
  }

  updateNonRenewalNit(value: string): void {
    this.contextRevision++;
    this.nonRenewalNit.set(value);
    this.confirmed = null;
    this.generationData.set(null);
  }

  generateNonRenewal(certificate: CertificateFormat): void {
    const revision = ++this.contextRevision;
    if (!this.isNonRenewalCertificate(certificate)) return;
    const contractId = this.nonRenewalContractId();
    if (!contractId) {
      this.error.set('Seleccione el contrato a término fijo.');
      this.errorFields.set({});
      this.generationData.set(null);
      this.confirmed = null;
      return;
    }
    const supplied = { nit_empresa: this.nonRenewalNit().trim() };
    if (!/^\d{5,12}(-\d)?$/.test(supplied.nit_empresa)) {
      this.error.set('Indique el NIT de la empresa con formato de dígitos y dígito de verificación opcional.');
      this.errorFields.set({});
      this.generationData.set(null);
      this.confirmed = null;
      return;
    }
    const context = { key: certificate.clave_formato!, variant: 'NON_RENEWAL', contractId, supplied };
    this.selectedFormat.set({ ...certificate });
    this.confirmed = null;
    this.generating.set(true);
    this.error.set('');
    this.errorFields.set({});
    this.generationData.set(null);
    this.service
      .getNonRenewalGenerationData(this.employeeId, contractId, supplied)
      .pipe(finalize(() => {
        if (revision === this.contextRevision) this.generating.set(false);
      }))
      .subscribe({
        next: (data) => { if (revision === this.contextRevision) { this.confirmed = context; this.generationData.set(data); } },
        error: (error) => {
          if (revision === this.contextRevision) this.handleError(error, 'No fue posible generar los datos de la carta de no renovación.');
        },
      });
  }

  updateCesantiasEnd(field: 'from' | 'to' | 'nit' | 'email' | 'phone', value: string): void {
    this.contextRevision++;
    if (field === 'from') this.cesantiasEndFrom.set(value);
    else if (field === 'to') this.cesantiasEndTo.set(value);
    else if (field === 'nit') this.cesantiasEndNit.set(value);
    else if (field === 'email') this.cesantiasEndEmail.set(value);
    else this.cesantiasEndPhone.set(value);
    this.confirmed = null;
    this.generationData.set(null);
  }

  generateCesantiasEnd(certificate: CertificateFormat): void {
    const revision = ++this.contextRevision;
    if (!this.isCesantiasEndCertificate(certificate)) return;
    const supplied = {
      fecha_desde: this.cesantiasEndFrom().trim(),
      fecha_hasta: this.cesantiasEndTo().trim(),
      nit_empresa: this.cesantiasEndNit().trim(),
      correo_contacto: this.cesantiasEndEmail().trim(),
      telefono_contacto: this.cesantiasEndPhone().trim(),
    };
    if (!supplied.fecha_desde || !supplied.fecha_hasta) {
      this.error.set('Indique las fechas inicial y final del periodo.');
      this.errorFields.set({});
      this.generationData.set(null);
      this.confirmed = null;
      return;
    }
    if (supplied.fecha_hasta < supplied.fecha_desde) {
      this.error.set('La fecha final del periodo no puede ser anterior a la inicial.');
      this.errorFields.set({});
      this.generationData.set(null);
      this.confirmed = null;
      return;
    }
    if (!/^\d{5,12}-\d$/.test(supplied.nit_empresa)) {
      this.error.set('Indique el NIT de la empresa con formato de dígitos y dígito de verificación.');
      this.errorFields.set({});
      this.generationData.set(null);
      this.confirmed = null;
      return;
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(supplied.correo_contacto) || supplied.correo_contacto.length > 150) {
      this.error.set('Indique un correo electrónico de contacto válido.');
      this.errorFields.set({});
      this.generationData.set(null);
      this.confirmed = null;
      return;
    }
    if (!/^[\d\s\-+]{6,30}$/.test(supplied.telefono_contacto)) {
      this.error.set('Indique un teléfono de contacto válido.');
      this.errorFields.set({});
      this.generationData.set(null);
      this.confirmed = null;
      return;
    }
    const context = { key: certificate.clave_formato!, variant: 'CESANTIAS_END', contractId: 0, supplied };
    this.selectedFormat.set({ ...certificate });
    this.confirmed = null;
    this.generating.set(true);
    this.error.set('');
    this.errorFields.set({});
    this.generationData.set(null);
    this.service
      .getCesantiasTerminationGenerationData(this.employeeId, supplied)
      .pipe(finalize(() => {
        if (revision === this.contextRevision) this.generating.set(false);
      }))
      .subscribe({
        next: (data) => { if (revision === this.contextRevision) { this.confirmed = context; this.generationData.set(data); } },
        error: (error) => {
          if (revision === this.contextRevision) this.handleError(error, 'No fue posible generar los datos de la carta de cesantías.');
        },
      });
  }

  updateCesantiasModality(value: string): void {
    this.contextRevision++;
    this.cesantiasModality.set(value);
    this.confirmed = null;
    this.generationData.set(null);
  }

  updateCesantiasConcept(value: string): void {
    this.contextRevision++;
    this.cesantiasConcept.set(value);
    this.confirmed = null;
    this.generationData.set(null);
  }

  updateCesantiasAmount(value: string): void {
    this.contextRevision++;
    this.cesantiasAmount.set(value);
    this.confirmed = null;
    this.generationData.set(null);
  }

  generateCesantias(certificate: CertificateFormat): void {
    const revision = ++this.contextRevision;
    if (!this.isCesantiasCertificate(certificate)) return;
    const supplied = {
      modalidad: this.cesantiasModality(),
      concepto_retiro: this.cesantiasConcept().trim(),
      monto_retiro: this.cesantiasAmount().trim(),
    };
    if (!['TOTAL', 'PARCIAL'].includes(supplied.modalidad)) {
      this.error.set('Seleccione la modalidad del retiro: TOTAL o PARCIAL.');
      this.errorFields.set({});
      this.generationData.set(null);
      this.confirmed = null;
      return;
    }
    if (!supplied.concepto_retiro || supplied.concepto_retiro.length > 200 || /[<>\r\n]/.test(supplied.concepto_retiro)) {
      this.error.set('Indique el concepto del retiro: hasta 200 caracteres, sin HTML ni saltos de línea.');
      this.errorFields.set({});
      this.generationData.set(null);
      this.confirmed = null;
      return;
    }
    if (!/^\d{1,10}(\.\d{1,2})?$/.test(supplied.monto_retiro) || Number(supplied.monto_retiro) <= 0) {
      this.error.set('Indique un monto válido mayor que cero, con hasta dos decimales.');
      this.errorFields.set({});
      this.generationData.set(null);
      this.confirmed = null;
      return;
    }
    const context = { key: certificate.clave_formato!, variant: 'CESANTIAS', contractId: 0, supplied };
    this.selectedFormat.set({ ...certificate });
    this.confirmed = null;
    this.generating.set(true);
    this.error.set('');
    this.errorFields.set({});
    this.generationData.set(null);
    this.service
      .getCesantiasGenerationData(this.employeeId, supplied)
      .pipe(finalize(() => {
        if (revision === this.contextRevision) this.generating.set(false);
      }))
      .subscribe({
        next: (data) => { if (revision === this.contextRevision) { this.confirmed = context; this.generationData.set(data); } },
        error: (error) => {
          if (revision === this.contextRevision) this.handleError(error, 'No fue posible generar los datos de la carta de cesantías.');
        },
      });
  }

  updateAcceptanceDate(value: string): void {
    this.contextRevision++;
    this.acceptancePresentationDate.set(value);
    this.confirmed = null;
    this.generationData.set(null);
  }

  generateAcceptance(certificate: CertificateFormat): void {
    const revision = ++this.contextRevision;
    const retirement = this.selectedRetirement();
    if (!retirement || !this.isAcceptanceCertificate(certificate)) return;
    const retirementId = retirement.id_retiro;
    if (!retirementId) {
      this.error.set('No fue posible identificar el retiro seleccionado.');
      return;
    }
    const date = this.acceptancePresentationDate().trim();
    if (!date) {
      this.error.set('Indique la fecha de presentación de la renuncia.');
      this.errorFields.set({});
      this.generationData.set(null);
      this.confirmed = null;
      return;
    }
    const supplied = { fecha_presentacion_renuncia: date };
    const context = { key: certificate.clave_formato!, variant: 'ACCEPTANCE', contractId: 0, retirementId, supplied };
    this.selectedFormat.set({ ...certificate });
    this.confirmed = null;
    this.generating.set(true);
    this.error.set('');
    this.errorFields.set({});
    this.generationData.set(null);
    this.service
      .getAcceptanceGenerationData(this.employeeId, retirementId, supplied)
      .pipe(finalize(() => {
        if (revision === this.contextRevision) this.generating.set(false);
      }))
      .subscribe({
        next: (data) => { if (revision === this.contextRevision) { this.confirmed = context; this.generationData.set(data); } },
        error: (error) => {
          if (revision === this.contextRevision) this.handleError(error, 'No fue posible generar los datos de la carta de aceptación.');
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
    const isRetirement = context.variant === 'RETIRO' && !!context.retirementId;
    const isChecklist = context.variant === 'CHECKLIST' && !!context.retirementId;
    const isAcceptance = context.variant === 'ACCEPTANCE' && !!context.retirementId;
    const isCesantias = context.variant === 'CESANTIAS';
    const isCesantiasEnd = context.variant === 'CESANTIAS_END';
    const isNonRenewal = context.variant === 'NON_RENEWAL';
    const request$ = isRetirement
      ? this.service.downloadRetirementCertificate(this.employeeId, context.retirementId!, context.supplied as { fondo_solidaridad: string; retencion_fuente: string; auxilio_transporte: string })
      : isChecklist
        ? this.service.downloadChecklist(this.employeeId, context.retirementId!)
        : isAcceptance
          ? this.service.downloadAcceptance(this.employeeId, context.retirementId!, context.supplied as { fecha_presentacion_renuncia: string })
          : isCesantias
            ? this.service.downloadCesantias(this.employeeId, context.supplied as { modalidad: string; concepto_retiro: string; monto_retiro: string })
            : isCesantiasEnd
              ? this.service.downloadCesantiasTermination(this.employeeId, context.supplied as { fecha_desde: string; fecha_hasta: string; nit_empresa: string; correo_contacto: string; telefono_contacto: string })
              : isNonRenewal
                ? this.service.downloadNonRenewal(this.employeeId, context.contractId, context.supplied as { nit_empresa: string })
                : this.service.downloadCertificate(this.employeeId, context.key, context.contractId, context.variant, context.supplied);
    request$.subscribe({
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
        anchor.download = isRetirement ? 'BBTH-F-003-CERTIFICADO-LABORAL-RETIRO.pdf' : isChecklist ? 'BBTH-F-004-PAZ-Y-SALVO-ENTREGA-RETIRO.pdf' : isAcceptance ? 'BBTH-F-005-CARTA-ACEPTACION-RENUNCIA.pdf' : isCesantias ? 'BBTH-F-011-CARTA-RETIRO-CESANTIAS-VIVIENDA.pdf' : isCesantiasEnd ? 'BBTH-F-012-CARTA-RETIRO-CESANTIAS-FIN-CONTRATO.pdf' : isNonRenewal ? 'BBTH-F-015-NO-RENOVACION-CONTRATO.pdf' : 'BBTH-F-002-CERTIFICADO-LABORAL.pdf';
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

  contractLabel(contract: EmployeeContract): string {
    const parts = [contract.tipo_contrato, contract.fecha_fin].filter((part) => !!part);
    return parts.length ? parts.join(' — ') : 'Sin detalle';
  }

  isFirstCertificate(certificate: CertificateFormat): boolean {
    return certificate.clave_formato === FIRST_CERTIFICATE_KEY
      && ['GENERAL', 'SALARIO_AFILIACIONES', 'HISTORIAL_CONTRACTUAL'].includes(certificate.variante || 'GENERAL');
  }

  isRetirementCertificate(certificate: CertificateFormat): boolean {
    return certificate.clave_formato === RETIREMENT_CERTIFICATE_KEY;
  }

  selectedRetirement(): { id_retiro: number; motivo_retiro: string; fecha_retiro: string } | null {
    return this.retirements()[0] ?? null;
  }

  updateSupplied(field: 'solidarity' | 'withholding', value: string): void {
    this.contextRevision++;
    if (field === 'solidarity') this.solidarity.set(value);
    else this.withholding.set(value);
    this.confirmed = null;
    this.generationData.set(null);
  }

  updateWorkStartDate(value: string): void {
    this.contextRevision++;
    this.workStartDate.set(value);
    this.confirmed = null;
    this.generationData.set(null);
  }

  updateRetirementSupplied(field: 'solidarity' | 'withholding' | 'transport', value: string): void {
    this.contextRevision++;
    if (field === 'solidarity') this.retirementSolidarity.set(value);
    else if (field === 'withholding') this.retirementWithholding.set(value);
    else this.retirementTransport.set(value);
    this.confirmed = null;
    this.generationData.set(null);
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
}
