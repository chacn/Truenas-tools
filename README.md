# Truenas Tools
Este repositorio contiene herramientas y scripts para facilitar la administracion de TrueNAS SCALE, especialmente en la gestión de contenedores Docker y aplicaciones relacionadas.

## 🚀 Habilitar DNS de docker para Nginx Proxy Manager

Este script automatiza la conexión de **Nginx Proxy Manager** a las redes internas de todas las aplicaciones de Docker en TrueNAS 25.04.2 (Electric Eel), permitiendo la resolución DNS interna entre contenedores usando el nombre del contenedor como hostname.
### 🧩 Archivos necesarios
* <code>monitor_container_start.sh</code> - Monitorea eventos de inicio de contenedores y ejecuta el script de conexión.
* <code>connect_npm_to_all_networks.sh</code> - Conecta el contenedor de NPM a todas las redes internas de Docker.

### 📋 Configuración en TrueNAS
1. **Repo**: Clona el repositorio dentro de algun dataset i.e. <code>/mnt/tank/</code>
   ```bash
   git clone https://github.com/chacn/Truenas-tools.git /mnt/tank/Truenas-tools
   ```
3. **Permisos**: Otorga permisos de ejecución a los scripts en tu terminal
   ```bash
   chmod +x /mnt/tank/Truenas-tools/docker/*.sh
   ```
4. **Automatización**:

    * Ve a **System Settings > Advanced > Init/Shutdown Scripts**.

    * Haz clic en **Add**.

    * **Type**: <code>Script</code>

    * **Script**: <code>/mnt/tank/Truenas-tools/docker/monitor_container_start.sh</code>

    * **When**: <code>Post Init</code>

    * **Timeout**: <code>0</code>

### 📊 Monitoreo y Mantenimiento
#### 🔍 Ver salida del proceso
Para verificar la actividad del monitor y ver en tiempo real qué contenedores está procesando:

```bash
journalctl -t monitor_container_start.sh -f
```
(También puedes verificar la existencia del archivo de proceso: <code>cat /tmp/monitor_container_start.pid</code>)

#### ▶️ Correr manualmente el monitor
Si el monitor no está en ejecución, inícialo en segundo plano con:

```bash
bash /mnt/tank/Truenas-tools/docker/monitor_container_start.sh &
```
#### ⏹️ Detener el monitor
Para finalizar el proceso de forma limpia:

```bash
kill $(cat /tmp/monitor_container_start.pid)
```

### ⚙️ Funcionamiento Técnico
1. **Monitor**: Escucha eventos <code>start</code> de la API de Docker mediante <code>docker events</code>.

2. **Conector**: Al detectar un inicio, identifica todas las redes de Docker y vincula el contenedor de NPM a ellas mediante <code>docker network connect</code>.

3. **Persistencia**: Utiliza un archivo PID en <code>/tmp</code> para evitar ejecuciones duplicadas.

4. **Ubicación**: Ambos scripts (<code>monitor_container_start.sh</code> y <code>connect_npm_networks.sh</code>) deben residir en el mismo directorio.