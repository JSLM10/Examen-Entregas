# Entregas: S3 (entregas/ y resultados-athena/) + Glue Data Catalog con partition projection + Athena.
# Los prefijos entregas/ y resultados-athena/ son parte de la clave de los objetos: no se crean aqui.
# Las particiones NO se registran: Athena las calcula con las propiedades projection.* de la tabla.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.perfil

  default_tags {
    tags = {
      Proyecto = "de-final-entregas"
      Manejado = "terraform"
    }
  }
}

# ---------------------------------------------------------------- S3

resource "aws_s3_bucket" "datos" {
  bucket        = var.nombre_bucket
  force_destroy = true # permite destruir el bucket aunque tenga datos y resultados
}

resource "aws_s3_bucket_public_access_block" "datos" {
  bucket                  = aws_s3_bucket.datos.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "datos" {
  bucket = aws_s3_bucket.datos.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ---------------------------------------------------------------- Glue

resource "aws_glue_catalog_database" "entregas" {
  name        = var.nombre_base_datos
  description = "Intentos de entrega de paquetes (CSV en S3)"
}

resource "aws_glue_catalog_table" "entregas" {
  name          = var.nombre_tabla
  database_name = aws_glue_catalog_database.entregas.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL                 = "TRUE"
    classification           = "csv"
    "skip.header.line.count" = "1"

    # Partition projection: Athena deduce las fechas, no se registran particiones.
    "projection.enabled"             = "true"
    "projection.fecha.type"          = "date"
    "projection.fecha.format"        = "yyyy-MM-dd"
    "projection.fecha.range"         = "${var.fecha_inicial},${var.fecha_final}"
    "projection.fecha.interval"      = "1"
    "projection.fecha.interval.unit" = "DAYS"
    # Prefijo de la particion: termina en "/". El archivo entregas.csv esta dentro.
    "storage.location.template" = "s3://${aws_s3_bucket.datos.bucket}/entregas/fecha=$${fecha}/"
  }

  # fecha no es columna del CSV: sale de la carpeta fecha=yyyy-MM-dd
  partition_keys {
    name = "fecha"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.datos.bucket}/entregas/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim"          = ","
        "serialization.format" = ","
      }
    }

    columns {
      name = "id_envio"
      type = "string"
    }
    columns {
      name = "ciudad"
      type = "string"
    }
    columns {
      name = "transportadora"
      type = "string"
    }
    columns {
      name = "estado"
      type = "string"
    }
    columns {
      name = "duracion_minutos"
      type = "int"
    }
  }
}

# ---------------------------------------------------------------- Athena

resource "aws_athena_workgroup" "entregas" {
  name          = var.nombre_workgroup
  force_destroy = true # permite destruirlo aunque tenga historial de consultas

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.datos.bucket}/resultados-athena/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}
