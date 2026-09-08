import { AfterViewInit, Component, OnDestroy, signal } from '@angular/core';
import { FeedbackDialogComponent, FeedbackDialogType } from './feedback-dialog.component';

interface PendingAlert {
  element: HTMLElement;
  message: string;
  type: FeedbackDialogType;
  actionButton: HTMLButtonElement | null;
}

@Component({
  selector: 'app-alert-modal-bridge',
  standalone: true,
  imports: [FeedbackDialogComponent],
  template: `
    @if (current(); as alert) {
      <app-feedback-dialog
        [type]="alert.type"
        [message]="alert.message"
        [actionLabel]="alert.actionButton?.textContent?.trim() || ''"
        (action)="runAction()"
        (closed)="dismiss()"
      />
    }
  `,
})
export class AlertModalBridgeComponent implements AfterViewInit, OnDestroy {
  readonly current = signal<PendingAlert | null>(null);
  private readonly queue: PendingAlert[] = [];
  private observer?: MutationObserver;

  ngAfterViewInit(): void {
    this.observer = new MutationObserver(() => this.collect());
    this.observer.observe(document.body, { childList: true, subtree: true, characterData: true });
    queueMicrotask(() => this.collect());
  }

  ngOnDestroy(): void {
    this.observer?.disconnect();
  }

  dismiss(): void {
    this.current.set(null);
    this.showNext();
  }

  runAction(): void {
    const action = this.current()?.actionButton;
    this.dismiss();
    action?.click();
  }

  private collect(): void {
    const alerts = document.querySelectorAll<HTMLElement>('.alert.error, .alert.success');
    for (const element of alerts) {
      if (element.closest('app-feedback-dialog') || element.hasAttribute('data-feedback-inline')) continue;

      const message = this.cleanMessage(element);
      if (!message || element.dataset['feedbackMessage'] === message) continue;

      element.dataset['feedbackMessage'] = message;
      element.hidden = true;
      this.queue.push({
        element,
        message,
        type: element.classList.contains('error') ? 'error' : 'success',
        actionButton: element.querySelector<HTMLButtonElement>('button'),
      });
    }
    this.showNext();
  }

  private showNext(): void {
    if (this.current()) return;
    while (this.queue.length) {
      const next = this.queue.shift()!;
      if (next.element.isConnected) {
        this.current.set(next);
        return;
      }
    }
  }

  private cleanMessage(element: HTMLElement): string {
    const copy = element.cloneNode(true) as HTMLElement;
    copy.querySelectorAll('button').forEach((button) => button.remove());
    return copy.textContent?.replace(/\s+/g, ' ').trim() ?? '';
  }
}
