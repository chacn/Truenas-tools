#!/bin/bash

# --- CONFIGURACIÓN DINÁMICA ---
# Obtiene la ruta de la carpeta donde reside este script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# --- CONFIGURACIÓN ---
NPM_CONTAINER="ix-nginx-proxy-manager-nginx-proxy-manager-1"
SCRIPT_FILE="$SCRIPT_DIR/connect_npm_to_all_networks.sh"
PIDFILE="/tmp/docker_events_monitor.pid"

# --- VERIFICACIÓN DE INSTANCIA ÚNICA ---
if [ -f $PIDFILE ]; then
    PID=$(cat $PIDFILE)
    if ps -p $PID > /dev/null 2>&1; then
        echo "⚠️ El monitor ya está corriendo (PID: $PID). Saliendo."
        exit 0
    else
        # Si el archivo existe pero el proceso no, lo borramos (limpieza tras crash)
        rm $PIDFILE
    fi
fi

# Guardar el PID actual en el archivo
echo $$ > $PIDFILE

# Eliminar el archivo al salir (Ctrl+C o kill)
trap "rm -f $PIDFILE; exit" INT TERM EXIT

echo "🚀 Iniciando monitor de eventos Docker para $NPM_CONTAINER..."

# --- BUCLE DE EVENTOS ---
docker events --filter 'event=start' --format '{{.Actor.Attributes.name}}' | while read CONTAINER_NAME
do
    echo "🔔 Se detectó inicio de contenedor: $CONTAINER_NAME"
    
    # Pausa breve para asegurar que la red del contenedor esté lista
    sleep 2

    # Ejecutar el script de conexión
    if [ -f "$SCRIPT_FILE" ]; then
        bash "$SCRIPT_FILE"
    else
        echo "❌ Error: No se encontró $SCRIPT_FILE"
    fi
done