<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;
use PDO;

class NoveltyRepository extends StoredProcedureRepository
{
    public function types(bool $includeInactive = false): array { return $this->call('SP_BBF_NOVEDADES_TIPOS_LISTAR', [$includeInactive ? 1 : 0]); }
    public function list(array $f): array { return $this->call('SP_BBF_NOVEDADES_LISTAR', [$f['employee_id'] ?? null, $f['type'] ?? null, $f['status'] ?? null, $f['date_from'] ?? null, $f['date_to'] ?? null]); }
    public function create(array $d, int $user): ?array { return $this->first('SP_BBF_NOVEDAD_CREAR', [$d['employee_id'], $d['type'], $d['start_date'], $d['end_date'] ?? null, $d['reason'] ?? null, $d['observations'] ?? null, $user]); }
    public function createDisability(array $d, int $user): ?array { return $this->first('SP_BBF_INCAPACIDAD_CREAR', $this->disabilityParameters($d, $user)); }
    public function update(int $id, array $d, int $user): ?array { return $this->first('SP_BBF_NOVEDAD_ACTUALIZAR', [$id, $d['start_date'], $d['end_date'] ?? null, $d['reason'] ?? null, $d['observations'] ?? null, $user]); }
    public function updateDisability(int $id, array $d, int $user): ?array { return $this->first('SP_BBF_INCAPACIDAD_ACTUALIZAR', [$id, ...$this->disabilityParameters($d, $user, false)]); }
    public function changeStatus(int $id, string $status, ?string $observation, int $user): ?array { return $this->first('SP_BBF_NOVEDAD_CAMBIAR_ESTADO', [$id, $status, $observation, $user]); }
    public function addEvidence(int $id, array $d, int $user): ?array { return $this->first('SP_BBF_NOVEDAD_EVIDENCIA_AGREGAR', [$id, $d['evidence_type'], $d['file_name'], $d['original_name'] ?? null, $d['file_url'] ?? null, $d['file_path'] ?? null, $d['mime_type'] ?? null, $d['size_bytes'] ?? null, $d['observations'] ?? null, $user]); }
    public function disabilityTracking(int $id): ?array { return $this->first('SP_BBF_INCAPACIDAD_SEGUIMIENTO_OBTENER', [$id]); }
    public function saveDisabilityTracking(int $id, array $d, int $user): ?array
    {
        return $this->first('SP_BBF_INCAPACIDAD_SEGUIMIENTO_GUARDAR', [
            $id, $d['responsible_entity_id'] ?? null, $d['days_paid_company'] ?? 0,
            $d['days_payable_entity'] ?? 0, $d['transcription_status'],
            $d['transcription_channel'] ?? null, $d['transcription_date'] ?? null,
            $d['payment_request_status'], $d['payment_request_date'] ?? null,
            $d['disability_value'] ?? 0, $d['entity_received_value'] ?? 0,
            $d['company_paid_worker_value'] ?? 0, $d['worker_paid_value'] ?? 0,
            $d['last_payment_date'] ?? null, $d['tracking_status'],
            $d['tracking_observations'] ?? null, $user,
        ]);
    }
    public function listDisabilityTracking(array $f): array
    {
        return $this->call('SP_BBF_INCAPACIDADES_SEGUIMIENTO_LISTAR', [
            $f['employee_id'] ?? null, $f['responsible_entity_id'] ?? null,
            $f['tracking_status'] ?? null, $f['date_from'] ?? null, $f['date_to'] ?? null,
        ]);
    }

    public function get(int $id): array
    {
        $statement = DB::connection()->getPdo()->prepare('CALL SP_BBF_NOVEDAD_OBTENER(?)');
        $statement->execute([$id]); $sets = [];
        try { do { if ($statement->columnCount() > 0) $sets[] = array_map(fn ($r) => array_change_key_case($r, CASE_LOWER), $statement->fetchAll(PDO::FETCH_ASSOC)); } while ($statement->nextRowset()); }
        finally { $statement->closeCursor(); }
        return ['novelty' => $sets[0][0] ?? null, 'evidence' => $sets[1] ?? [], 'history' => $sets[2] ?? []];
    }

    private function disabilityParameters(array $d, int $user, bool $withEmployee = true): array
    {
        $p = [$d['employee_id'] ?? null, $d['start_date'], $d['end_date'], $d['diagnosis'] ?? null, $d['cie10_code'] ?? null, $d['eps_id'] ?? null, $d['origin'] ?? 'ENFERMEDAD_GENERAL', $d['certificate_number'] ?? null, $d['filing_number'] ?? null, $d['issuer'] ?? null, !empty($d['is_extension']) ? 1 : 0, $d['source_disability_id'] ?? null, $d['filing_date'] ?? null, $d['observations'] ?? null, $user];
        if (!$withEmployee) array_shift($p);
        return $p;
    }
}
