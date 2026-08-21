<?php
namespace App\Http\Requests;
use Illuminate\Validation\Rule;
class ChangeNoveltyStatusRequest extends ApiRequest {
 protected function prepareForValidation(): void { if(is_string($this->input('status'))) $this->merge(['status'=>strtoupper(trim($this->input('status')))]); }
 public function rules(): array { return ['status'=>['required',Rule::in(['REGISTRADA','VALIDADA','CERRADA','ANULADA'])],'observation'=>['nullable','string','max:500','required_if:status,ANULADA']]; }
}
