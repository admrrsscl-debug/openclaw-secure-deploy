# Instalación en macOS

Guía paso a paso para instalar OpenClaw de forma segura en macOS (Apple Silicon e Intel).  
**Tiempo estimado:** 15‑20 minutos.

---

## 📋 Requisitos

- macOS 12 (Monterey) o superior
- Conexión a internet
- **Acceso de administrador** (necesitarás tu contraseña)
- 2 GB de espacio libre en disco

---

## 🚀 Instalación rápida (automática)

### Método 1: Usar el script de instalación (recomendado)

Abre **Terminal** (búscala en Aplicaciones → Utilidades) y ejecuta:

```bash
curl -fsSL https://raw.githubusercontent.com/skylabs/openclaw-secure/main/scripts/install-mac.sh | bash
```

El script te pedirá confirmación y luego hará todo automáticamente.

**Nota:** Si prefieres revisar el script antes de ejecutarlo, puedes descargarlo primero:

```bash
curl -O https://raw.githubusercontent.com/skylabs/openclaw-secure/main/scripts/install-mac.sh
chmod +x install-mac.sh
./install-mac.sh
```

### Método 2: Instalación manual (si prefieres control)

Si no quieres usar el script automático, sigue estos pasos:

---

## 🔧 Instalación manual paso a paso

### 1. Abrir Terminal

Ve a **Aplicaciones → Utilidades → Terminal** o búscala con Spotlight (Cmd+Espacio).

### 2. Instalar Homebrew (si no lo tienes)

Homebrew es un gestor de paquetes para macOS. Ejecuta:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Sigue las instrucciones en pantalla. Al final, te pedirá que ejecutes unos comandos; cópialos y pégalos en la terminal.

### 3. Instalar Node.js 22

```bash
brew install node@22
```

Luego, añade Node.js a tu PATH:

```bash
echo 'export PATH="/opt/homebrew/opt/node@22/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

(Nota: si usas bash, cambia `.zshrc` por `.bash_profile`).

Verifica la instalación:

```bash
node --version
```

Deberías ver algo como `v22.22.0`.

### 4. Instalar OpenClaw

```bash
sudo npm install -g openclaw
```

### 5. Crear configuración segura

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

4. Copia el siguiente contenido (pégala en la terminal con Cmd+V):

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

### 6. Ajustar permisos

```bash
chmod 700 ~/.openclaw
chmod 600 ~/.openclaw/openclaw.json
```

### 7. Instalar Docker (opcional pero recomendado)

Docker permite que OpenClaw funcione en un contenedor aislado, más seguro.

```bash
brew install --cask docker
```

Luego abre **Docker Desktop** desde Aplicaciones y sigue el asistente de configuración.  
**Reinicia la terminal** después de instalar Docker.

### 8. Configurar firewall (opcional pero recomendado)

El firewall de macOS se llama "pf". Para activarlo:

```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setblockall on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/sbin/sshd
```

Esto activa el firewall y bloquea todo excepto SSH.

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

Para verificar que está funcionando:

```bash
openclaw gateway status
```

Deberías ver `Gateway: running`.

Para que OpenClaw se inicie automáticamente al encender tu Mac, puedes usar `launchd` o simplemente agregar el comando a tus elementos de inicio.

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

Para que OpenClaw se revise a sí mismo cada semana, ejecuta:

```bash
openclaw cron add --name "security-audit" --command "openclaw security audit --deep" --weekly --at "sunday 02:00"
```

Los resultados se guardarán en los logs.

---

## ❓ Solución de problemas

### "No se reconoce openclaw como un comando"
- Asegúrate de que Node.js está instalado: `node --version`
- Intenta instalar OpenClaw de nuevo: `sudo npm install -g openclaw`
- Verifica que el directorio `~/.npm-global/bin` esté en tu PATH:
  ```bash
  echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
  source ~/.zshrc
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
  lsof -i :18789
  ```
  Solo debería aparecer OpenClaw.

### "Docker no funciona"
- Asegúrate de que Docker Desktop esté **ejecutándose** (verifica el ícono en la barra de menú).
- Reinicia la terminal después de instalar Docker.

---

## 🆘 Soporte

Si tienes problemas:

1. **Revisa los logs**: `tail -f /tmp/openclaw/openclaw-*.log`
2. **Consulta la documentación**: [docs.openclaw.ai](https://docs.openclaw.ai)
3. **Únete a la comunidad**: [Discord](https://discord.com/invite/clawd)
4. **Soporte remoto seguro**: Instala Tailscale (el script te lo ofreció) y comparte tu máquina con `adm.rrss.cl@gmail.com`.

---

## 🧹 Desinstalación

1. Detén el gateway: `openclaw gateway stop`
2. Desinstala OpenClaw: `sudo npm uninstall -g openclaw`
3. Elimina la configuración: `rm -rf ~/.openclaw`
4. (Opcional) Desinstala Docker: `brew uninstall --cask docker`
5. (Opcional) Desinstala Node.js: `brew uninstall node@22`

---

**¡Listo!** Ya tienes un asistente de IA privado y seguro en tu macOS. 🦞

*Última actualización: marzo 2026*