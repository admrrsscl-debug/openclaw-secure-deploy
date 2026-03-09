# Instalación en Ubuntu/Linux

Guía paso a paso para instalar OpenClaw de forma segura en Ubuntu (también funciona en Debian y derivados).  
**Tiempo estimado:** 10‑15 minutos.

---

## 📋 Requisitos

- Ubuntu 20.04, 22.04 o 24.04 (también Debian 11/12)
- Conexión a internet
- **Acceso de superusuario (sudo)** (necesitarás la contraseña)
- 1 GB de espacio libre en disco

---

## 🚀 Instalación rápida (automática)

### Método 1: Usar el script de instalación (recomendado)

Abre una terminal (Ctrl+Alt+T) y ejecuta:

```bash
curl -fsSL https://raw.githubusercontent.com/skylabs/openclaw-secure/main/scripts/install-ubuntu.sh | bash
```

El script te pedirá confirmación y luego hará todo automáticamente.

**Nota:** Si prefieres revisar el script antes de ejecutarlo, puedes descargarlo primero:

```bash
wget https://raw.githubusercontent.com/skylabs/openclaw-secure/main/scripts/install-ubuntu.sh
chmod +x install-ubuntu.sh
./install-ubuntu.sh
```

### Método 2: Instalación manual (si prefieres control)

Si no quieres usar el script automático, sigue estos pasos:

---

## 🔧 Instalación manual paso a paso

### 1. Abrir una terminal

Presiona `Ctrl+Alt+T` o busca "Terminal" en el menú de aplicaciones.

### 2. Instalar Node.js 22

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```

Verifica que se instaló correctamente:

```bash
node --version
```

Deberías ver algo como `v22.22.0`.

### 3. Instalar OpenClaw

```bash
sudo npm install -g openclaw
```

### 4. Crear configuración segura

1. Crea el directorio de configuración:
   ```bash
   mkdir -p ~/.openclaw
   ```

2. Genera un token seguro:
   ```bash
   echo "GATEWAY_TOKEN=$(openssl rand -hex 24)" | tee ~/.openclaw/token.txt
   ```

3. Crea el archivo de configuración:
   ```bash
   nano ~/.openclaw/openclaw.json
   ```

4. Copia el siguiente contenido (puedes pegarlo en la terminal con Ctrl+Shift+V):

```json
{
  "gateway": {
    "mode": "local",
    "bind": "loopback",
    "port": 18789,
    "auth": {
      "mode": "token",
      "token": "TU_TOKEN_AQUI"
    }
  },
  "channels": {
    "whatsapp": {
      "dmPolicy": "pairing",
      "groupPolicy": "allowlist"
    },
    "telegram": {
      "dmPolicy": "pairing",
      "groupPolicy": "allowlist"
    }
  },
  "tools": {
    "profile": "messaging",
    "deny": ["group:automation", "group:runtime", "group:fs"],
    "fs": { "workspaceOnly": true },
    "exec": { "security": "deny", "ask": "always" }
  },
  "agents": {
    "defaults": { "sandbox": { "mode": "all" } }
  }
}
```

5. Reemplaza `TU_TOKEN_AQUI` por el token que generaste (está en `~/.openclaw/token.txt`).
6. Guarda el archivo: `Ctrl+O`, luego `Ctrl+X`.

### 5. Ajustar permisos

```bash
chmod 700 ~/.openclaw
chmod 600 ~/.openclaw/openclaw.json
```

### 6. Instalar Docker (opcional pero recomendado)

Docker permite que OpenClaw funcione en un contenedor aislado, más seguro.

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

**Importante:** Cierra sesión y vuelve a entrar para que los permisos surtan efecto.

### 7. Configurar firewall (opcional pero recomendado)

```bash
sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw --force enable
```

Esto bloquea todas las conexiones entrantes excepto SSH.

---

## 🔍 Verificar la instalación

Ejecuta:

```bash
openclaw --version
```

Deberías ver algo como `2026.3.1`.  
Si ves un error, asegúrate de que Node.js esté instalado correctamente.

---

## ⚙️ Configurar WhatsApp/Telegram

1. En la terminal, ejecuta:
   ```bash
   openclaw onboard
   ```
2. Sigue las instrucciones en pantalla. Escanearás un código QR con tu teléfono.
3. ¡Listo! Ahora tu asistente de OpenClaw está conectado a tu WhatsApp/Telegram.

---

## 🚦 Iniciar el servicio

Para que OpenClaw esté siempre disponible:

```bash
openclaw gateway start
```

Para que se inicie automáticamente al encender la computadora:

```bash
systemctl --user enable openclaw-gateway
```

Para verificar que está funcionando:

```bash
openclaw gateway status
```

Deberías ver `Gateway: running`.

---

## 📝 Pasos después de instalar

### Añadir contactos autorizados

1. Abre el archivo de configuración:
   ```bash
   nano ~/.openclaw/openclaw.json
   ```
2. Busca `"allowFrom"` y añade los números de teléfono o IDs de Telegram entre comillas, separados por comas. Ejemplo:
   ```json
   "allowFrom": ["+56912345678", "tg:123456789"]
   ```
3. Guarda el archivo (`Ctrl+O`, `Ctrl+X`).
4. Reinicia el gateway: `openclaw gateway restart`

### Programar auditorías automáticas

Para que OpenClaw se revise a sí mismo cada día, ejecuta:

```bash
openclaw cron add --name "security-audit" --command "openclaw security audit --deep" --daily --at "02:00"
```

Los resultados se guardarán en los logs.

---

## ❓ Solución de problemas

### "No se reconoce openclaw como un comando"
- Asegúrate de que Node.js está instalado: `node --version`
- Intenta instalar OpenClaw de nuevo: `sudo npm install -g openclaw`
- Verifica que el directorio `~/.npm-global/bin` esté en tu PATH:
  ```bash
  echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
  source ~/.bashrc
  ```

### "Error de permisos"
- Ejecuta los comandos con `sudo` cuando sea necesario.
- Verifica los permisos de `~/.openclaw`: deben ser `700`.

### "No puedo escanear el código QR"
- Asegúrate de que tu teléfono tenga conexión a internet.
- Si usas WhatsApp, verifica que tu teléfono tenga la última versión.
- Si el código QR no aparece, revisa los logs: `tail -f /tmp/openclaw/openclaw-*.log`

### "El gateway no inicia"
- Revisa los logs: `cat /tmp/openclaw/openclaw-*.log`
- Verifica que el puerto 18789 no esté usado por otro programa:
  ```bash
  ss -ltn | grep :18789
  ```
  Solo debería aparecer `127.0.0.1:18789`.

---

## 🆘 Soporte

Si tienes problemas:

1. **Revisa los logs**: `tail -f /tmp/openclaw/openclaw-*.log`
2. **Consulta la documentación**: [docs.openclaw.ai](https://docs.openclaw.ai)
3. **Únete a la comunidad**: [Discord](https://discord.com/invite/clawd)
4. **Soporte remoto seguro**: Instala Tailscale (el script te lo ofreció) y comparte tu máquina con `support@skylabs.com`.

---

## 🧹 Desinstalación

1. Detén el gateway: `openclaw gateway stop`
2. Desinstala OpenClaw: `sudo npm uninstall -g openclaw`
3. Elimina la configuración: `rm -rf ~/.openclaw`
4. (Opcional) Desinstala Docker: `sudo apt-get remove docker docker-engine docker.io`
5. (Opcional) Desinstala Node.js: `sudo apt-get remove nodejs`

---

**¡Listo!** Ya tienes un asistente de IA privado y seguro en tu Ubuntu. 🦞

*Última actualización: marzo 2026*