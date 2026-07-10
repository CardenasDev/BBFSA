import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ContractGenerationData, ContractGenerationResponse } from '../models/contract-generation.models';

@Injectable({ providedIn: 'root' })
export class ContractService {
  private readonly http = inject(HttpClient);
  private readonly contractingUrl = `${environment.apiUrl}/contracting`;

  getContractGenerationData(employeeContractId: number): Observable<ContractGenerationData> {
    return this.http
      .get<ContractGenerationResponse>(`${this.contractingUrl}/contracts/${employeeContractId}/generation-data`)
      .pipe(map((response) => response.data));
  }
}
