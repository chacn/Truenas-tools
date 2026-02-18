# --- CONFIGURACIÓN DINÁMICA ---
# Obtiene la ruta de la carpeta donde reside este script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# --- CONFIGURACIÓN ---
# Cambia estas rutas a las de tu sistema
SCRIPT_A_EJECUTAR="monitor_container_start.sh"  # Nombre del archivo a ejecutar
NOMBRE_SERVICIO="npm_network_monitor"  # Nombre del servicio systemd
RUTA_SERVICIO="/etc/systemd/system/${NOMBRE_SERVICIO}.service"

# 1. Crear el archivo de unidad de systemd
cat <<EOF > $RUTA_SERVICIO
[Unit]
Description=Servicio de Fondo Persistente para TrueNAS
After=network.target storage.target

[Service]
# Ejecuta el script con bash
ExecStart=/usr/bin/bash ${SCRIPT_DIR}/${SCRIPT_A_EJECUTAR}
# Reinicia automáticamente si el proceso falla o se detiene
Restart=always
# Espera 10 segundos antes de reiniciar tras un fallo
RestartSec=10
# Usuario que ejecuta el script (root por defecto)
User=root
# Directorio de trabajo
WorkingDirectory=$(dirname ${SCRIPT_DIR}/${SCRIPT_A_EJECUTAR})

[Install]
WantedBy=multi-user.target
EOF

# 2. Recargar systemd para que reconozca el nuevo servicio
systemctl daemon-reload

# 3. Habilitar e iniciar el servicio
systemctl enable ${NOMBRE_SERVICIO}