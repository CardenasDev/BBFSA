<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;
use PDO;

class ReturnRepository extends StoredProcedureRepository
{
    public function available(string $type, int $employeeId): array
    {
        return $this->call('SP_BBF_DEVOLUCIONES_ENTREGAS_DISPONIBLES_LISTAR', [$type, $employeeId]);
    }

    public function create(array $data, int $registeredBy, array $details, array $evidence): ?array
    {
        return $this->first('SP_BBF_DEVOLUCION_CREAR', [
            $data['type'],
            $data['employee_id'],
            $data['delivery_id'],
            $data['return_date'],
            $data['reason'],
            $data['observations'] ?? null,
            $registeredBy,
            json_encode($details, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR),
            json_encode($evidence, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR),
        ]);
    }

    public function confirm(int $returnId, int $confirmedBy): ?array
    {
        return $this->first('SP_BBF_DEVOLUCION_CONFIRMAR', [$returnId, $confirmedBy]);
    }

    public function list(array $filters): array
    {
        return $this->call('SP_BBF_DEVOLUCIONES_LISTAR', [
            $filters['type'] ?? null,
            $filters['employee_id'] ?? null,
            $filters['status'] ?? null,
            $filters['date_from'] ?? null,
            $filters['date_to'] ?? null,
        ]);
    }

    public function get(int $returnId): array
    {
        $statement = DB::connection()->getPdo()->prepare('CALL SP_BBF_DEVOLUCION_OBTENER(?)');
        $statement->execute([$returnId]);
        $sets = [];

        try {
            do {
                if ($statement->columnCount() > 0) {
                    $sets[] = array_map(
                        fn (array $row): array => array_change_key_case($row, CASE_LOWER),
                        $statement->fetchAll(PDO::FETCH_ASSOC),
                    );
                }
            } while ($statement->nextRowset());
        } finally {
            $statement->closeCursor();
        }

        return [
            'return' => $sets[0][0] ?? null,
            'details' => $sets[1] ?? [],
            'evidence' => $sets[2] ?? [],
        ];
    }

    public function cancel(int $returnId, int $cancelledBy, string $reason): ?array
    {
        return $this->first('SP_BBF_DEVOLUCION_ANULAR', [$returnId, $cancelledBy, $reason]);
    }
}
