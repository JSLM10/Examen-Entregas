-- Verificacion del tercer dia. Tres sentencias, se ejecutan por separado (scripts/ejecutar_consulta.sh, indice 1, 2 y 3).

-- 1) Los seis registros de 2026-10-03.
SELECT
    fecha,
    id_envio,
    ciudad,
    transportadora,
    estado,
    duracion_minutos
FROM entregas_db.entregas
WHERE fecha = '2026-10-03'
ORDER BY id_envio ASC;

-- 2) Total de registros de la tabla (debe ser 18).
SELECT COUNT(*) AS total_registros
FROM entregas_db.entregas;

-- 3) Conteo por estado de 2026-10-03.
SELECT
    fecha,
    estado,
    COUNT(*) AS total_intentos
FROM entregas_db.entregas
WHERE fecha = '2026-10-03'
GROUP BY fecha, estado
ORDER BY estado ASC;
