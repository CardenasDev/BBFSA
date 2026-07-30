import {
  AfterViewInit,
  Component,
  ElementRef,
  HostListener,
  OnDestroy,
  ViewChild,
  input,
  output,
  signal,
} from '@angular/core';

@Component({
  selector: 'app-camera-file-picker',
  standalone: true,
  template: `
    <div class="picker-actions">
      <button class="btn secondary" type="button" (click)="openCamera()">Tomar foto</button>
      <label class="btn ghost gallery-button">
        {{ galleryLabel() }}
        <input
          #galleryInput
          type="file"
          [multiple]="multiple()"
          [accept]="accept()"
          (change)="selectFromGallery($event)"
        />
      </label>
    </div>
    @if (pickerError()) {
      <p class="field-error" role="alert" aria-live="assertive">{{ pickerError() }}</p>
    }

    @if (open()) {
      <div class="camera-backdrop" (click)="backdropClick($event)">
        <section
          #dialog
          class="camera-dialog"
          role="dialog"
          aria-modal="true"
          aria-labelledby="camera-title"
          aria-describedby="camera-help"
          tabindex="-1"
        >
          <h2 id="camera-title">Tomar foto</h2>
          <p id="camera-help" class="muted">Alinea la evidencia dentro del encuadre.</p>
          @if (cameraError()) {
            <div class="alert error" role="alert">{{ cameraError() }}</div>
          }
          @if (capturedUrl()) {
            <img class="camera-preview" [src]="capturedUrl()" alt="Vista previa de la fotografía capturada" />
          } @else {
            <video #video autoplay playsinline muted aria-label="Vista en vivo de la cámara"></video>
          }
          <div class="camera-actions">
            @if (capturedFile()) {
              <button class="btn primary" type="button" (click)="usePhoto()">Usar foto</button>
              <button class="btn secondary" type="button" (click)="retake()">Repetir</button>
            } @else if (!cameraError()) {
              <button class="btn primary" type="button" (click)="capture()">Capturar</button>
            }
            <button class="btn ghost" type="button" (click)="cancel()">Cancelar</button>
          </div>
        </section>
      </div>
    }
  `,
  styles: [`
    .picker-actions{display:flex;flex-wrap:wrap;gap:.5rem;align-items:center}
    .gallery-button{cursor:pointer}.gallery-button input{position:absolute;width:1px;height:1px;opacity:0;overflow:hidden}
    .camera-backdrop{position:fixed;inset:0;z-index:1000;background:rgba(15,23,42,.72);display:grid;place-items:center;padding:1rem}
    .camera-dialog{width:min(680px,100%);max-height:calc(100vh - 2rem);overflow:auto;background:var(--surface,#fff);color:var(--text,#172033);border-radius:16px;padding:1rem;box-shadow:0 24px 80px rgba(0,0,0,.35)}
    .camera-dialog h2{margin-top:0}.camera-dialog video,.camera-preview{display:block;width:100%;max-height:65vh;object-fit:contain;background:#050505;border-radius:12px}
    .camera-actions{display:flex;flex-wrap:wrap;justify-content:flex-end;gap:.5rem;margin-top:1rem}
    .field-error{display:block;color:var(--danger,#b42318);margin:.5rem 0 0}
  `],
})
export class CameraFilePickerComponent implements AfterViewInit, OnDestroy {
  readonly multiple = input(false);
  readonly accept = input('image/jpeg,image/png,image/webp');
  readonly galleryLabel = input('Seleccionar de galería');
  readonly filesSelected = output<File[]>();

  @ViewChild('video') private video?: ElementRef<HTMLVideoElement>;
  @ViewChild('dialog') private dialog?: ElementRef<HTMLElement>;

  readonly open = signal(false);
  readonly pickerError = signal('');
  readonly cameraError = signal('');
  readonly capturedFile = signal<File | null>(null);
  readonly capturedUrl = signal('');
  private stream: MediaStream | null = null;
  private previouslyFocused: HTMLElement | null = null;

  ngAfterViewInit(): void {
    if (this.open()) this.focusDialog();
  }

  async openCamera(): Promise<void> {
    this.pickerError.set('');
    this.cameraError.set('');
    this.previouslyFocused = document.activeElement as HTMLElement | null;
    this.open.set(true);
    queueMicrotask(() => this.focusDialog());

    if (!window.isSecureContext) {
      this.cameraError.set('La cámara requiere una conexión segura (HTTPS). Puedes seleccionar una imagen de la galería.');
      return;
    }
    if (!navigator.mediaDevices?.getUserMedia) {
      this.cameraError.set('Este navegador no permite usar la cámara integrada. Puedes seleccionar una imagen de la galería.');
      return;
    }

    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: { ideal: 'environment' } },
        audio: false,
      });
      queueMicrotask(() => {
        if (!this.open()) {
          this.stopStream();
          return;
        }
        if (this.video?.nativeElement) this.video.nativeElement.srcObject = this.stream;
      });
    } catch (error) {
      this.stopStream();
      const denied = error instanceof DOMException && (error.name === 'NotAllowedError' || error.name === 'SecurityError');
      this.cameraError.set(denied
        ? 'No se concedió permiso para usar la cámara. Puedes seleccionar una imagen de la galería.'
        : 'No fue posible iniciar la cámara. Revisa que no esté ocupada o selecciona una imagen de la galería.');
    }
  }

  selectFromGallery(event: Event): void {
    const inputElement = event.target as HTMLInputElement;
    const files = [...(inputElement.files ?? [])];
    if (files.length) this.filesSelected.emit(this.multiple() ? files : files.slice(0, 1));
    inputElement.value = '';
  }

  async capture(): Promise<void> {
    const element = this.video?.nativeElement;
    if (!element || !element.videoWidth || !element.videoHeight) {
      this.cameraError.set('La cámara aún no está lista. Espera un momento e inténtalo nuevamente.');
      return;
    }
    const scale = Math.min(1, 1600 / Math.max(element.videoWidth, element.videoHeight));
    const canvas = document.createElement('canvas');
    canvas.width = Math.round(element.videoWidth * scale);
    canvas.height = Math.round(element.videoHeight * scale);
    canvas.getContext('2d')?.drawImage(element, 0, 0, canvas.width, canvas.height);
    const blob = await new Promise<Blob | null>((resolve) => canvas.toBlob(resolve, 'image/jpeg', .85));
    if (!blob) {
      this.cameraError.set('No fue posible procesar la fotografía. Inténtalo nuevamente.');
      return;
    }
    const id = globalThis.crypto?.randomUUID?.() ?? `${Date.now()}-${Math.random().toString(16).slice(2)}`;
    const file = new File([blob], `evidencia-${id}.jpg`, { type: 'image/jpeg', lastModified: Date.now() });
    this.releaseCapturedUrl();
    this.capturedFile.set(file);
    this.capturedUrl.set(URL.createObjectURL(file));
    this.stopStream();
  }

  usePhoto(): void {
    const file = this.capturedFile();
    if (!file) return;
    this.filesSelected.emit([file]);
    this.close();
  }

  async retake(): Promise<void> {
    this.releaseCapturedUrl();
    this.capturedFile.set(null);
    this.open.set(false);
    await this.openCamera();
  }

  cancel(): void {
    this.close();
  }

  backdropClick(event: MouseEvent): void {
    if (event.target === event.currentTarget) this.cancel();
  }

  @HostListener('document:keydown.escape')
  escape(): void {
    if (this.open()) this.cancel();
  }

  ngOnDestroy(): void {
    this.stopStream();
    this.releaseCapturedUrl();
  }

  private close(): void {
    this.stopStream();
    this.releaseCapturedUrl();
    this.capturedFile.set(null);
    this.open.set(false);
    queueMicrotask(() => this.previouslyFocused?.focus());
  }

  private focusDialog(): void {
    this.dialog?.nativeElement.focus();
  }

  private stopStream(): void {
    this.stream?.getTracks().forEach((track) => track.stop());
    this.stream = null;
    if (this.video?.nativeElement) this.video.nativeElement.srcObject = null;
  }

  private releaseCapturedUrl(): void {
    const url = this.capturedUrl();
    if (url) URL.revokeObjectURL(url);
    this.capturedUrl.set('');
  }
}
