<?php
namespace App\Http\Requests;
class SaveNoveltyRequest extends ApiRequest {
 protected function prepareForValidation(): void { if(is_string($this->input('type'))) $this->merge(['type'=>strtoupper(trim($this->input('type')))]); }
 public function rules(): array { return ['employee_id'=>[$this->isMethod('post')?'required':'sometimes','integer','min:1'],'type'=>[$this->isMethod('post')?'required':'sometimes','string','max:50','not_in:INCAPACIDAD'],'start_date'=>['required','date'],'end_date'=>['nullable','date','after_or_equal:start_date'],'reason'=>['nullable','string','max:500'],'observations'=>['nullable','string','max:5000']]; }
}
