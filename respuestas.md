# Respuestas

## 1. ¿Por qué se pudo consultar el tercer día sin registrar una partición nueva?

Porque la tabla no guarda una lista de particiones, guarda la regla para calcularlas. En Terraform dejé la proyección de fechas (formato `yyyy-MM-dd`, del 2026-10-01 al 2026-10-03, de a un día) y la plantilla de ubicación `s3://<bucket>/entregas/fecha=${fecha}/`. Con eso Athena calcula las fechas del rango al momento de la consulta y busca los archivos en esa ruta, sin preguntarle al catálogo qué particiones existen.

El día 3 ya estaba dentro del rango desde el primer `apply`, solo que todavía no tenía archivo, por eso no devolvía filas y la tabla tenía 12 registros. Cuando subí el CSV a la ruta que describe la plantilla, la misma regla lo encontró y la tabla pasó a 18, sin crawler, sin `MSCK REPAIR TABLE`, sin `ALTER TABLE ADD PARTITION` y sin tocar Terraform. Las ejecuciones antes y después están en `evidencias/ejecuciones_athena.csv`.

## 2. Si se subiera un archivo del 4 de octubre, ¿qué pasaría y qué habría que cambiar?

El archivo se subiría a S3 sin problema, pero las consultas no lo mostrarían: el rango termina el 3 de octubre, entonces Athena nunca busca la fecha 4. No da error, simplemente seguirían saliendo los mismos 18 registros, y eso es lo delicado, porque el dato existe pero queda por fuera de los reportes.

Para incluirlo hay que ampliar el rango de la proyección (`fecha_final = 2026-10-04`) y correr `terraform apply`, que solo cambia esa propiedad de la tabla. El archivo tendría que estar en `entregas/fecha=2026-10-04/entregas.csv`, con el mismo encabezado y las mismas cinco columnas. Tampoco haría falta registrar la partición ni correr un crawler.