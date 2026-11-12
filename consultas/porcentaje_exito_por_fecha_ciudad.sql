-- Porcentaje de entregas exitosas por fecha y ciudad: 100 * entregadas / total de intentos del grupo.
-- El denominador cuenta todos los estados. Se usa DOUBLE para evitar la division entera.
SELECT
    fecha,
    ciudad,
    CAST(
        ROUND(100.0 * CAST(SUM(CASE WHEN estado = 'entregado' THEN 1 ELSE 0 END) AS DOUBLE) / COUNT(*), 2)
        AS DECIMAL(5, 2)
    ) AS porcentaje_exito
FROM entregas_db.entregas
GROUP BY fecha, ciudad
ORDER BY fecha ASC, ciudad ASC;
