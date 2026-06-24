<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;

abstract class StoredProcedureRepository
{
    protected function call(string $procedure, array $parameters = []): array
    {
        if (! preg_match('/^SP_BBF_[A-Z0-9_]+$/', $procedure)) {
            throw new \InvalidArgumentException('Nombre de procedimiento no permitido.');
        }

        $placeholders = implode(',', array_fill(0, count($parameters), '?'));
        $rows = DB::select("CALL {$procedure}({$placeholders})", $parameters);

        return array_map(fn (object $row) => $this->normalize((array) $row), $rows);
    }

    protected function first(string $procedure, array $parameters = []): ?array
    {
        return $this->call($procedure, $parameters)[0] ?? null;
    }

    private function normalize(array $row): array
    {
        return array_combine(
            array_map(static fn (string $key) => strtolower($key), array_keys($row)),
            array_values($row),
        );
    }
}
