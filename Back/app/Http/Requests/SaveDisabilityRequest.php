<?php
namespace App\Http\Requests;
use Illuminate\Validation\Rule;
class SaveDisabilityRequest extends ApiRequest {
 protected function prepareForValidation(): void { if(is_string($this->input('origin'))) $this->merge(['origin'=>strtoupper(trim($this->input('origin')))]); }
 public function rules(): array { return ['employee_id'=>[$this->isMethod('post')?'required':'sometimes','integer','min:1'],'start_date'=>['required','date'],'end_date'=>['required','date','after_or_equal:start_date'],'diagnosis'=>['nullable','string','max:500'],'cie10_code'=>['nullable','string','max:20'],'eps_id'=>['nullable','integer','min:1'],'origin'=>['required',Rule::in(['ENFERMEDAD_GENERAL','ACCIDENTE_LABORAL','ENFERMEDAD_LABORAL','ACCIDENTE_TRANSITO','LICENCIA_MATERNIDAD','LICENCIA_PATERNIDAD','OTRO'])],'certificate_number'=>['nullable','string','max:100'],'filing_number'=>['nullable','string','max:100'],'issuer'=>['nullable','string','max:200'],'is_extension'=>['nullable','boolean'],'source_disability_id'=>['nullable','integer','min:1','required_if:is_extension,true'],'filing_date'=>['nullable','date'],'observations'=>['nullable','string','max:5000']]; }
}
