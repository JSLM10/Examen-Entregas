-- Duracion promedio de las entregas exitosas del 2026-10-02 (todas las ciudades y transportadoras).
-- Solo estado = 'entregado': los intentos fallidos tienen duracion 0 y no deben entrar al promedio.
SELECT
    fecha,
    CAST(ROUND(AVG(CAST(duracion_minutos AS DOUBLE)), 2) AS DECIMAL(5, 2)) AS duracion_promedio_minutos
FROM entregas_db.entregas
WHERE fecha = '2026-10-02'
  AND estado = 'entregado'
GROUP BY fecha;
