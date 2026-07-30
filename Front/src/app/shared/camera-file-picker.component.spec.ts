import { ComponentFixture, TestBed } from '@angular/core/testing';
import { CameraFilePickerComponent } from './camera-file-picker.component';

describe('CameraFilePickerComponent', () => {
  let fixture: ComponentFixture<CameraFilePickerComponent>;
  let component: CameraFilePickerComponent;
  let stop: ReturnType<typeof vi.fn>;
  let getUserMedia: ReturnType<typeof vi.fn>;

  beforeEach(async () => {
    stop = vi.fn();
    getUserMedia = vi.fn().mockResolvedValue({ getTracks: () => [{ stop }] });
    Object.defineProperty(window, 'isSecureContext', { configurable: true, value: true });
    Object.defineProperty(navigator, 'mediaDevices', { configurable: true, value: { getUserMedia } });
    vi.spyOn(URL, 'createObjectURL').mockReturnValue('blob:capture');
    vi.spyOn(URL, 'revokeObjectURL').mockImplementation(() => undefined);
    await TestBed.configureTestingModule({ imports: [CameraFilePickerComponent] }).compileComponents();
    fixture = TestBed.createComponent(CameraFilePickerComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('requests the rear camera only after the explicit action', async () => {
    expect(getUserMedia).not.toHaveBeenCalled();
    await component.openCamera();
    expect(getUserMedia).toHaveBeenCalledWith({ video: { facingMode: { ideal: 'environment' } }, audio: false });
  });

  it('captures a resized JPEG as a File and can use it', async () => {
    const emitted = vi.fn();
    component.filesSelected.subscribe(emitted);
    await component.openCamera();
    fixture.detectChanges();
    const video = fixture.nativeElement.querySelector('video') as HTMLVideoElement;
    Object.defineProperties(video, { videoWidth: { value: 2000 }, videoHeight: { value: 1000 } });
    vi.spyOn(HTMLCanvasElement.prototype, 'getContext').mockReturnValue({ drawImage: vi.fn() } as unknown as CanvasRenderingContext2D);
    vi.spyOn(HTMLCanvasElement.prototype, 'toBlob').mockImplementation((callback) => callback(new Blob(['jpeg'], { type: 'image/jpeg' })));
    await component.capture();
    expect(component.capturedFile()).toBeInstanceOf(File);
    expect(component.capturedFile()?.type).toBe('image/jpeg');
    component.usePhoto();
    expect(emitted).toHaveBeenCalledWith([expect.any(File)]);
    expect(stop).toHaveBeenCalled();
    expect(URL.revokeObjectURL).toHaveBeenCalledWith('blob:capture');
  });

  it('supports repeat, cancel and destruction while always stopping tracks', async () => {
    await component.openCamera();
    fixture.detectChanges();
    component.cancel();
    expect(stop).toHaveBeenCalledTimes(1);
    component.capturedFile.set(new File(['x'], 'capture.jpg', { type: 'image/jpeg' }));
    component.capturedUrl.set('blob:capture');
    await component.retake();
    expect(URL.revokeObjectURL).toHaveBeenCalledWith('blob:capture');
    expect(getUserMedia).toHaveBeenCalledTimes(2);
    component.cancel();
    await component.openCamera();
    component.ngOnDestroy();
    expect(stop).toHaveBeenCalledTimes(3);
  });

  it('keeps gallery fallback for multiple files', () => {
    const emitted = vi.fn();
    fixture.componentRef.setInput('multiple', true);
    component.filesSelected.subscribe(emitted);
    const files = [new File(['a'], 'a.jpg'), new File(['b'], 'b.jpg')];
    component.selectFromGallery({ target: { files, value: 'x' } } as unknown as Event);
    expect(emitted).toHaveBeenCalledWith(files);
  });

  it('reports denied permission, unsupported browsers and insecure contexts', async () => {
    getUserMedia.mockRejectedValueOnce(new DOMException('denied', 'NotAllowedError'));
    await component.openCamera();
    expect(component.cameraError()).toContain('permiso');
    Object.defineProperty(navigator, 'mediaDevices', { configurable: true, value: undefined });
    await component.openCamera();
    expect(component.cameraError()).toContain('no permite');
    Object.defineProperty(window, 'isSecureContext', { configurable: true, value: false });
    await component.openCamera();
    expect(component.cameraError()).toContain('HTTPS');
  });
});
