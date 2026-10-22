<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;
use PDO;

class KpiRepository
{
    /**
     * Ejecuta el SP que calcula rotacion y demografia.
     * El SP retorna:
     * - Resultset 1: metricas (tasa_rotacion, salidas, promedio_activos, ventana_inicio, ventana_fin, metodo_calculo)
     * - Resultset 2: desglose por genero (genero, total_activos)
     */
    public function getRotationAndDemographics(): ?array
    {
        $statement = DB::connection()->getPdo()->prepare('CALL SP_BBF_KPI_ROTACION_Y_DEMOGRAFIA()');
        $statement->execute();

        $sets = [];
        try {
            do {
                if ($statement->columnCount() > 0) {
                    $sets[] = array_map(
                        static fn (array $row): array => array_change_key_case($row, CASE_LOWER),
                        $statement->fetchAll(PDO::FETCH_ASSOC)
                    );
                }
            } while ($statement->nextRowset());
        } finally {
            $statement->closeCursor();
        }

        if (empty($sets)) {
            return null;
        }

        // Set 0: metricas principales (1 fila)
        $metrics = $sets[0][0] ?? [];
        // Set 1: desglose genero (N filas)
        $desglose = $sets[1] ?? [];

        return [
            'tasa_rotacion' => (float) ($metrics['tasa_rotacion'] ?? 0),
            'salidas' => (int) ($metrics['salidas'] ?? 0),
            'promedio_activos' => (float) ($metrics['promedio_activos'] ?? 0),
            'ventana_inicio' => $metrics['ventana_inicio'] ?? null,
            'ventana_fin' => $metrics['ventana_fin'] ?? null,
            'metodo_calculo' => $metrics['metodo_calculo'] ?? 'promedio_puntas_mes',
            'desglose_genero' => $desglose,
        ];
    }
}