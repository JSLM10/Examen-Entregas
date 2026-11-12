output "region" {
  description = "Region de AWS del despliegue."
  value       = var.region
}

output "bucket" {
  description = "Nombre del bucket S3."
  value       = aws_s3_bucket.datos.bucket
}

output "prefijo_entregas" {
  description = "Prefijo S3 donde se cargan los CSV."
  value       = "s3://${aws_s3_bucket.datos.bucket}/entregas/"
}

output "prefijo_resultados_athena" {
  description = "Prefijo S3 donde Athena escribe los resultados."
  value       = "s3://${aws_s3_bucket.datos.bucket}/resultados-athena/"
}

output "base_datos" {
  description = "Base de datos de Glue."
  value       = aws_glue_catalog_database.entregas.name
}

output "tabla" {
  description = "Tabla externa de Glue con partition projection."
  value       = aws_glue_catalog_table.entregas.name
}

output "workgroup" {
  description = "Workgroup de Athena para las consultas."
  value       = aws_athena_workgroup.entregas.name
}
