<?php
namespace App\Http\Requests;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Validation\Rule;
class StoreNoveltyEvidenceRequest extends ApiRequest {
 protected function prepareForValidation(): void { if(is_string($this->input('evidence_type'))) $this->merge(['evidence_type'=>strtoupper(trim($this->input('evidence_type')))]); }
 public function rules(): array { return ['evidence_type'=>['required',Rule::in(['SOPORTE','TRANSCRIPCION','PRORROGA','OTRO'])],'file_name'=>['required','string','max:255'],'file_url'=>['nullable','url','max:500'],'file'=>['nullable','file','max:5120','mimes:pdf,jpg,jpeg,png,webp,doc,docx'],'observations'=>['nullable','string','max:500']]; }
 public function withValidator(Validator $v): void { $v->after(function($v){ $url=trim((string)$this->input('file_url')); if(($url!=='')===$this->hasFile('file')) $v->errors()->add('file_origin','Debe enviar una URL o un archivo físico, pero no ambos.'); }); }
}
