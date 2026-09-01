import { HttpClient,HttpParams } from '@angular/common/http';
import { Injectable,inject } from '@angular/core';
import { map } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../models/api.models';
import { DisabilityPayload,DisabilityTracking,DisabilityTrackingFilters,DisabilityTrackingPayload,Novelty,NoveltyDetail,NoveltyFilters,NoveltyPayload,NoveltyType } from '../models/novelty.models';
@Injectable({providedIn:'root'}) export class NoveltyService {
 private http=inject(HttpClient); private url=`${environment.apiUrl}/novelties`;
 types(includeInactive=false){return this.http.get<ApiResponse<NoveltyType[]>>(`${this.url}/types`,{params:{include_inactive:String(includeInactive)}}).pipe(map(r=>r.data));}
 list(f:NoveltyFilters={}){let p=new HttpParams();Object.entries(f).forEach(([k,v])=>{if(v!==null&&v!==undefined&&v!=='')p=p.set(k,String(v));});return this.http.get<ApiResponse<Novelty[]>>(this.url,{params:p}).pipe(map(r=>r.data));}
 get(id:number){return this.http.get<ApiResponse<NoveltyDetail>>(`${this.url}/${id}`).pipe(map(r=>r.data));}
 create(p:NoveltyPayload){return this.http.post<ApiResponse<{id_novedad:number}>>(this.url,p).pipe(map(r=>r.data));}
 createDisability(p:DisabilityPayload){return this.http.post<ApiResponse<{id_novedad:number}>>(`${this.url}/disabilities`,p).pipe(map(r=>r.data));}
 update(id:number,p:NoveltyPayload){return this.http.put<ApiResponse<unknown>>(`${this.url}/${id}`,p).pipe(map(r=>r.data));}
 updateDisability(id:number,p:DisabilityPayload){return this.http.put<ApiResponse<unknown>>(`${this.url}/${id}/disability`,p).pipe(map(r=>r.data));}
 status(id:number,status:string,observation?:string){return this.http.patch<ApiResponse<unknown>>(`${this.url}/${id}/status`,{status,observation}).pipe(map(r=>r.data));}
 addEvidence(id:number,p:{evidence_type:string;file_name:string;file_url?:string;file?:File;observations?:string}){const f=new FormData();f.append('evidence_type',p.evidence_type);f.append('file_name',p.file_name);if(p.file_url)f.append('file_url',p.file_url);if(p.file)f.append('file',p.file);if(p.observations)f.append('observations',p.observations);return this.http.post<ApiResponse<unknown>>(`${this.url}/${id}/evidence`,f).pipe(map(r=>r.data));}
 disabilityTracking(id:number){return this.http.get<ApiResponse<DisabilityTracking>>(`${this.url}/${id}/disability-tracking`).pipe(map(r=>r.data));}
 saveDisabilityTracking(id:number,p:DisabilityTrackingPayload){return this.http.put<ApiResponse<DisabilityTracking>>(`${this.url}/${id}/disability-tracking`,p).pipe(map(r=>r.data));}
 exportDisabilityTracking(f:DisabilityTrackingFilters={}){let p=new HttpParams();Object.entries(f).forEach(([k,v])=>{if(v!==null&&v!==undefined&&v!=='')p=p.set(k,String(v));});return this.http.get(`${this.url}/disabilities/tracking/export`,{params:p,responseType:'blob'});}
}
