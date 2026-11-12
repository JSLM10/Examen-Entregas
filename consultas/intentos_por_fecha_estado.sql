-- Cantidad de intentos por fecha y estado (todos los intentos).
-- Sin filtro de fechas: la proyeccion ya cubre 2026-10-01 a 2026-10-03 y las fechas sin archivo no devuelven filas.
SELECT
    fecha,
    estado,
    COUNT(*) AS total_intentos
FROM entregas_db.entregas
GROUP BY fecha, estado
ORDER BY fecha ASC, estado ASC;
