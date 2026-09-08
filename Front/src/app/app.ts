import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { AlertModalBridgeComponent } from './shared/alert-modal-bridge.component';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, AlertModalBridgeComponent],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
}
