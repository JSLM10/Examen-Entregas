variable "region" {
  description = "Region de AWS donde se despliega todo."
  type        = string
  default     = "us-east-2"
}

variable "perfil" {
  description = "Perfil de AWS CLI con permisos sobre S3, Glue y Athena."
  type        = string
  default     = "user_cli"
}

variable "nombre_bucket" {
  description = "Nombre del bucket S3 (unico a nivel global). La politica IAM de user_cli solo permite el prefijo la-bodega-del-pelao-."
  type        = string
  default     = "la-bodega-del-pelao-entregas-jslm10"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.nombre_bucket))
    error_message = "Use 3 a 63 caracteres: minusculas, numeros, puntos o guiones."
  }
}

variable "nombre_base_datos" {
  description = "Nombre de la base de datos en Glue Data Catalog."
  type        = string
  default     = "entregas_db"
}

variable "nombre_tabla" {
  description = "Nombre de la tabla externa en Glue."
  type        = string
  default     = "entregas"
}

variable "nombre_workgroup" {
  description = "Nombre del workgroup de Athena."
  type        = string
  default     = "entregas-wg"
}

variable "fecha_inicial" {
  description = "Primera fecha proyectada (yyyy-MM-dd), incluida."
  type        = string
  default     = "2026-10-01"
}

variable "fecha_final" {
  description = "Ultima fecha proyectada (yyyy-MM-dd), incluida."
  type        = string
  default     = "2026-10-03"
}
