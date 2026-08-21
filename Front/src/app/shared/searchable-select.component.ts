import { Component, ElementRef, forwardRef, HostListener, Input, signal } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';

export interface SearchableSelectOption { value: number; label: string; }

@Component({
  selector:'app-searchable-select', standalone:true,
  providers:[{provide:NG_VALUE_ACCESSOR,useExisting:forwardRef(()=>SearchableSelectComponent),multi:true}],
  styles:[`:host{display:block;position:relative}.select-box{position:relative}.select-box input{width:100%;padding-right:2.5rem}.arrow{position:absolute;right:.85rem;top:50%;transform:translateY(-50%);pointer-events:none;color:#53655d}.options{position:absolute;z-index:80;top:calc(100% + 4px);left:0;right:0;max-height:260px;overflow:auto;background:#fff;border:1px solid #b9cbc2;border-radius:9px;box-shadow:0 12px 28px rgba(18,55,43,.16);padding:.3rem}.option{display:block;width:100%;border:0;background:transparent;text-align:left;padding:.65rem .75rem;border-radius:7px;cursor:pointer;color:#10251e}.option:hover,.option.selected{background:#e7f2ed}.empty{padding:.8rem;color:#6c7c75;text-align:center;font-size:.88rem}`],
  template:`<div class="select-box"><input [value]="query()" [placeholder]="placeholder" [disabled]="disabled" autocomplete="off" role="combobox" [attr.aria-expanded]="open()" (focus)="open.set(true)" (input)="type($event)"/><span class="arrow">⌄</span></div>@if(open()&&!disabled){<div class="options">@for(option of filtered();track option.value){<button type="button" class="option" [class.selected]="option.value===value" (mousedown)="$event.preventDefault()" (click)="choose(option)">{{option.label}}</button>}@empty{<div class="empty">No se encontraron resultados</div>}</div>}`
})
export class SearchableSelectComponent implements ControlValueAccessor {
 private _options:SearchableSelectOption[]=[]; @Input() set options(value:SearchableSelectOption[]){this._options=value??[];const selected=this._options.find(o=>o.value===this.value);if(selected)this.query.set(selected.label);} get options(){return this._options;} @Input() placeholder='Seleccione o escriba para buscar'; disabled=false; value:number|null=null; readonly query=signal(''); readonly open=signal(false); private change:(v:number|null)=>void=()=>{}; private touched=()=>{};
 constructor(private readonly host:ElementRef<HTMLElement>){}
 filtered(){const q=this.query().trim().toLocaleLowerCase('es'); if(!q||this.options.find(o=>o.value===this.value)?.label===this.query())return this.options;return this.options.filter(o=>o.label.toLocaleLowerCase('es').includes(q));}
 writeValue(v:number|null){this.value=v??null;this.query.set(this.options.find(o=>o.value===this.value)?.label??'');} registerOnChange(fn:(v:number|null)=>void){this.change=fn;} registerOnTouched(fn:()=>void){this.touched=fn;} setDisabledState(v:boolean){this.disabled=v;}
 type(event:Event){this.query.set((event.target as HTMLInputElement).value);this.value=null;this.change(null);this.open.set(true);} choose(option:SearchableSelectOption){this.value=option.value;this.query.set(option.label);this.change(option.value);this.touched();this.open.set(false);}
 @HostListener('document:mousedown',['$event']) outside(e:MouseEvent){if(!this.host.nativeElement.contains(e.target as Node)){this.open.set(false);this.touched();const selected=this.options.find(o=>o.value===this.value);this.query.set(selected?.label??'');}}
}
