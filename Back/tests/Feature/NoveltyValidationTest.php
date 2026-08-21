<?php

namespace Tests\Feature;

use App\Http\Middleware\EnsurePermission;
use App\Http\Middleware\JwtAuthenticate;
use Tests\TestCase;

class NoveltyValidationTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        $this->withoutMiddleware([JwtAuthenticate::class, EnsurePermission::class]);
    }

    public function test_disability_rejects_inverted_dates(): void
    {
        $this->postJson('/api/novelties/disabilities',['employee_id'=>1,'start_date'=>'2026-08-22','end_date'=>'2026-08-21','origin'=>'ENFERMEDAD_GENERAL'])->assertStatus(422)->assertJsonValidationErrors(['end_date']);
    }

    public function test_extension_requires_source_disability(): void
    {
        $this->postJson('/api/novelties/disabilities',['employee_id'=>1,'start_date'=>'2026-08-21','end_date'=>'2026-08-22','origin'=>'ENFERMEDAD_GENERAL','is_extension'=>true])->assertStatus(422)->assertJsonValidationErrors(['source_disability_id']);
    }

    public function test_evidence_requires_exactly_one_origin(): void
    {
        $this->postJson('/api/novelties/1/evidence',['evidence_type'=>'SOPORTE','file_name'=>'Incapacidad'])->assertStatus(422)->assertJsonValidationErrors(['file_origin']);
    }
}
