#!/usr/bin/env bash
# Ejecuta UNA sentencia de un archivo .sql en el workgroup de Athena, descarga el resultado
# y registra la ejecucion en evidencias/ejecuciones_athena.csv.
#
# Uso (desde la raiz del repositorio, en Git Bash / WSL / Linux / Mac):
#   bash scripts/ejecutar_consulta.sh <etapa> <archivo_sql> <archivo_resultado> [indice_sentencia]
# Ejemplo:
#   bash scripts/ejecutar_consulta.sh inicial consultas/intentos_por_fecha_estado.sql resultados/inicial/intentos_por_fecha_estado.csv
#
# Bucket y workgroup se leen de los outputs de Terraform. Perfil y region se pueden sobrescribir
# con AWS_PROFILE y AWS_DEFAULT_REGION.
#
# Athena escribe su CSV con todos los valores entre comillas; aqui se quitan para poder compararlo
# con resultados_esperados/. El contenido no cambia.
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "Uso: $0 <etapa> <archivo_sql> <archivo_resultado> [indice_sentencia]" >&2
  exit 2
fi

etapa="$1"; sql="$2"; salida="$3"; indice="${4:-1}"

cd "$(dirname "$0")/.."
export AWS_PROFILE="${AWS_PROFILE:-user_cli}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-2}"

bucket="$(terraform -chdir=infraestructura output -raw bucket)"
workgroup="$(terraform -chdir=infraestructura output -raw workgroup)"

# Quita los comentarios de linea y toma la sentencia numero <indice> (separadas por ';').
consulta="$(sed -E '/^[[:space:]]*--/d' "$sql" | awk -v n="$indice" '
  BEGIN { RS = ";" }
  { t = $0; gsub(/[[:space:]]/, "", t); if (t != "") { c++; if (c == n) print $0 } }')"

if [ -z "$consulta" ]; then
  echo "No existe la sentencia $indice en $sql" >&2
  exit 1
fi

id="$(aws athena start-query-execution \
  --query-string "$consulta" \
  --work-group "$workgroup" \
  --query QueryExecutionId --output text)"
echo "Ejecucion: $id"

while true; do
  estado="$(aws athena get-query-execution --query-execution-id "$id" \
    --query QueryExecution.Status.State --output text)"
  case "$estado" in
    SUCCEEDED) break ;;
    FAILED | CANCELLED)
      aws athena get-query-execution --query-execution-id "$id" \
        --query QueryExecution.Status.StateChangeReason --output text >&2
      exit 1 ;;
  esac
  sleep 2
done

mkdir -p "$(dirname "$salida")"
tmp="$(mktemp)"
aws s3 cp "s3://${bucket}/resultados-athena/${id}.csv" "$tmp" --only-show-errors
tr -d '"\r' < "$tmp" > "$salida"
rm -f "$tmp"

registro="evidencias/ejecuciones_athena.csv"
mkdir -p evidencias
[ -f "$registro" ] || echo "etapa,archivo_sql,id_ejecucion,archivo_resultado" > "$registro"
echo "${etapa},${sql},${id},${salida}" >> "$registro"

echo "Resultado en $salida:"
cat "$salida"
