<?php
namespace App\Http\Requests;
use Illuminate\Validation\Rule;
class ListNoveltiesRequest extends ApiRequest {
 protected function prepareForValidation(): void { foreach(['type','status'] as $f) if(is_string($this->input($f))) $this->merge([$f=>strtoupper(trim($this->input($f)))]); }
 public function rules(): array { return ['employee_id'=>['nullable','integer','min:1'],'type'=>['nullable','string','max:50'],'status'=>['nullable',Rule::in(['REGISTRADA','VALIDADA','CERRADA','ANULADA'])],'date_from'=>['nullable','date'],'date_to'=>['nullable','date','after_or_equal:date_from']]; }
}
