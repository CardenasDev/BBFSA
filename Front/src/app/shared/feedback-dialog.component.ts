import { Component, EventEmitter, Input, Output } from '@angular/core';

export type FeedbackDialogType = 'success' | 'error' | 'warning' | 'info';

@Component({
  selector: 'app-feedback-dialog',
  standalone: true,
  template: `
    <div class="feedback-backdrop" role="presentation">
      <section class="feedback-dialog" role="alertdialog" aria-modal="true"
        [attr.aria-labelledby]="dialogTitleId" [attr.aria-describedby]="dialogMessageId"
        [class.error]="type === 'error'" [class.warning]="type === 'warning'" [class.info]="type === 'info'">
        <div class="feedback-icon" aria-hidden="true">{{ icon }}</div>
        <h2 [id]="dialogTitleId">{{ resolvedTitle }}</h2>
        <p [id]="dialogMessageId">{{ message }}</p>
        <div class="feedback-actions">
          @if (actionLabel) {
            <button class="btn secondary" type="button" (click)="action.emit()">{{ actionLabel }}</button>
          }
          <button class="btn primary" type="button" (click)="closed.emit()" autofocus>{{ closeLabel }}</button>
        </div>
      </section>
    </div>
  `,
  styles: [`
    .feedback-backdrop{position:fixed;inset:0;z-index:2000;display:grid;place-items:center;padding:1rem;background:rgba(7,35,29,.52);backdrop-filter:blur(2px)}
    .feedback-dialog{width:min(430px,100%);padding:1.5rem;text-align:center;background:#fff;border:1px solid #d9e4df;border-radius:18px;box-shadow:0 24px 70px rgba(7,35,29,.3)}
    .feedback-icon{display:grid;place-items:center;width:3rem;height:3rem;margin:0 auto .8rem;border-radius:50%;font-size:1.5rem;font-weight:800;background:#e6f4ee;color:#176146}
    .feedback-dialog.error .feedback-icon{background:#fff0f0;color:#a12828}.feedback-dialog.warning .feedback-icon{background:#fff7df;color:#8a5b00}.feedback-dialog.info .feedback-icon{background:#edf4ff;color:#245b9e}
    h2{margin:0 0 .55rem;font-size:1.25rem}p{margin:0 0 1.25rem;line-height:1.5;white-space:pre-line}.feedback-actions{display:flex;justify-content:center;gap:.65rem;flex-wrap:wrap}.btn{min-width:8.5rem}
  `],
})
export class FeedbackDialogComponent {
  @Input({ required: true }) message = '';
  @Input() type: FeedbackDialogType = 'info';
  @Input() title = '';
  @Input() actionLabel = '';
  @Input() closeLabel = 'Entendido';
  @Output() readonly closed = new EventEmitter<void>();
  @Output() readonly action = new EventEmitter<void>();

  readonly dialogTitleId = `feedback-title-${Math.random().toString(36).slice(2)}`;
  readonly dialogMessageId = `feedback-message-${Math.random().toString(36).slice(2)}`;

  get resolvedTitle(): string {
    if (this.title) return this.title;
    return { success: 'Operación exitosa', error: 'Revisa la información', warning: 'Atención', info: 'Información' }[this.type];
  }

  get icon(): string {
    return { success: '✓', error: '!', warning: '!', info: 'i' }[this.type];
  }
}
