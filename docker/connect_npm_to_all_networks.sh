#!/bin/bash

# 1. Nombre del contenedor de NPM
NPM_CONTAINER="ix-nginx-proxy-manager-custom-nginx-proxy-manager-custom-1"

echo "--- Verificando estado de $NPM_CONTAINER ---"

# 2. Comprobar si el contenedor existe y está corriendo
STATUS=$(docker inspect -f '{{.State.Running}}' "$NPM_CONTAINER" 2>/dev/null)

if [ "$STATUS" != "true" ]; then
    echo "❌ ERROR: El contenedor $NPM_CONTAINER no existe o no está en ejecución."
    echo "Asegúrate de que la App esté iniciada en el panel de TrueNAS."
    exit 1
fi

echo "✅ Contenedor activo. Buscando redes..."

# 3. Obtener redes (excluyendo sistema)
NETWORKS=$(docker network ls --format "{{.Name}}" | grep -vE "^bridge$|^host$|^none$")

for NET in $NETWORKS; do
    # Verificar si ya está conectado a esa red
    IS_CONNECTED=$(docker inspect "$NPM_CONTAINER" -f '{{range $net, $conf := .NetworkSettings.Networks}}{{$net}} {{end}}' | grep -w "$NET")

    if [ -z "$IS_CONNECTED" ]; then
        echo "🔗 Conectando a red: $NET..."
        if ! docker network connect "$NET" "$NPM_CONTAINER" 2>/dev/null; then
            echo "❌  Fallo al conectar: $NET"
            STATUS=false
        fi
    #else
    #    echo "✅ Ya conectado a: $NET"
    fi
done

if [ "$STATUS" != "true" ]; then
    echo "❌ ERROR: No se pudo conectar el contenedor a todas las redes, revisa el log"
    exit 1
fi