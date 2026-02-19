#!/bin/bash

# Nombre de la red destino
TARGET_NETWORK="truenas_common_net"

echo "Verificando Docker y la red destino: $TARGET_NETWORK"

# 1. Crear la red si no existe
if ! docker network inspect "$TARGET_NETWORK" >/dev/null 2>&1; then
    if ! docker network create "$TARGET_NETWORK" >/dev/null 2>&1; then
        echo "❌ ERROR: No se pudo crear la red '$TARGET_NETWORK'."
        exit 1
    fi
    echo "✅ Red '$TARGET_NETWORK' creada."
fi

echo "Obteniendo lista de contenedores..."

# 2. Obtener todos los contenedores (incluye detenidos)
CONTAINERS=$(docker ps -q)

if [ -z "$CONTAINERS" ]; then
    echo "ℹ️  No se encontraron contenedores en este host. Nada que conectar."
    exit 0
fi

FAILED=false
CONNECTED_COUNT=0
SKIPPED_COUNT=0

for CID in $CONTAINERS; do
    # Obtener nombres de redes a las que está conectado
    IS_CONNECTED=$(docker inspect "$CID" -f '{{range $net, $conf := .NetworkSettings.Networks}}{{$net}} {{end}}' | grep -w "$TARGET_NETWORK")

    # Obtener un nombre legible para mensajes
    CONTAINER_NAME=$(docker inspect --format='{{.Name}}' "$CID" 2>/dev/null | sed 's/^\///')
    [ -z "$CONTAINER_NAME" ] && CONTAINER_NAME=$CID

    if [ -z "$IS_CONNECTED" ]; then
        if docker network connect "$TARGET_NETWORK" "$CID" 2>/dev/null; then
            echo "✅ Conectado: $CONTAINER_NAME"
            CONNECTED_COUNT=$((CONNECTED_COUNT+1))
        else
            echo "❌ Fallo al conectar: $CONTAINER_NAME (ID: $CID)"
            FAILED=true
        fi
    else
        SKIPPED_COUNT=$((SKIPPED_COUNT+1))
    fi
done

echo
echo "Resumen:"
echo "  Conectados: $CONNECTED_COUNT"
echo "  Saltados (ya conectados): $SKIPPED_COUNT"

if [ "$FAILED" = true ]; then
    echo "❌ ERROR: Alguna(s) conexión(es) fallaron."
    exit 1
else
    echo "✅ Contenedores conectados: $CONNECTED_COUNT, $SKIPPED_COUNT ya estaban conectados." 
    exit 0
fi
