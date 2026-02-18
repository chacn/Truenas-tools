#!/bin/bash

# Configuración
NPM_CONTAINER="ix-nginx-proxy-manager-nginx-proxy-manager-1"
SCRIPT_CONEXION="./connect_npm_to_all_networks.sh"

echo "Escuchando eventos de Docker para conectar redes a $NPM_CONTAINER..."

# docker events filtra por el evento 'start'
docker events --filter 'event=start' --format '{{.Actor.Attributes.name}}' | while read CONTAINER_NAME
do
    echo "🔔 Se detectó inicio de contenedor: $CONTAINER_NAME"
    
    # Si el que se levantó es el propio NPM, esperamos unos segundos a que esté listo
    if [ "$CONTAINER_NAME" == "$NPM_CONTAINER" ]; then
        sleep 5
    fi

    # Ejecutamos el script de conexión que ya tenemos
    bash "$SCRIPT_CONEXION"
done