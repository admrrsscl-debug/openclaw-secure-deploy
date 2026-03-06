# Instalación en Windows 10/11

Guía paso a paso para instalar OpenClaw de forma segura en Windows.  
**Tiempo estimado:** 15‑20 minutos.

---

## 📋 Requisitos

- Windows 10 o 11 (64 bits)
- Conexión a internet
- **Administrador** (necesitarás permisos para instalar programas)
- 2 GB de espacio libre en disco

---

## 🚀 Instalación rápida (automática)

### Método 1: Ejecutar el script de instalación (recomendado)

1. **Descarga el script**  
   Haz clic derecho en este enlace y elige **"Guardar enlace como…"**:  
   [install-windows.ps1](https://raw.githubusercontent.com/skillnest/openclaw-secure/main/scripts/install-windows.ps1)

2. **Guárdalo** en tu Escritorio o en una carpeta que recuerdes.

3. **Ejecuta el script**  
   - Haz clic derecho en el archivo `install-windows.ps1`
   - Selecciona **"Ejecutar con PowerShell"**
   - Si aparece una advertencia de seguridad, haz clic en **"Más información"** y luego en **"Ejecutar de todas formas"**.

4. **Sigue las instrucciones**  
   El script te guiará paso a paso. Acepta los permisos de administrador cuando te los pida.

5. **¡Listo!** Al final verás un resumen con los pasos siguientes.

### Método 2: Instalación manual (si prefieres control)

Si no quieres usar el script automático, sigue estos pasos:

---

## 🔧 Instalación manual paso a paso

### 1. Instalar Node.js

1. Ve a [nodejs.org](https://nodejs.org) y descarga la versión **LTS** (la que dice "Recomendada para la mayoría").
2. Ejecuta el instalador y sigue las opciones por defecto.
3. Abre **PowerShell** (búscalo en el menú Inicio) y escribe:
   ```powershell
   node --version
   ```
   Deberías ver algo como `v22.22.0`. Si no, reinicia tu computadora.

### 2. Instalar OpenClaw

En la misma ventana de PowerShell, escribe:

```powershell
npm install -g openclaw
```

Esto descargará e instalará OpenClaw. Puede tardar unos minutos.

### 3. Crear configuración segura

1. Abre el **Bloc de notas**.
2. Copia el siguiente texto:

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

3. Reemplaza `TU_TOKEN_AQUI` por una clave larga y aleatoria (puedes usar [esta página](https://randomkeygen.com) para generar una).
4. Guarda el archivo como `openclaw.json` en la carpeta `C:\Users\tuusuario\.openclaw` (crea la carpeta si no existe).

### 4. Configurar firewall (opcional pero recomendado)

1. Abre **Windows Security** (escribe "Seguridad de Windows" en el menú Inicio).
2. Haz clic en **"Firewall y protección de red"**.
3. Haz clic en **"Configuración avanzada"**.
4. En el panel izquierdo, haz clic en **"Reglas de entrada"**.
5. En el panel derecho, haz clic en **"Nueva regla…"**.
6. Selecciona **"Puerto"** → **"TCP"** → **"Puertos específicos: 18789"** → **"Bloquear la conexión"** → Dale un nombre como "OpenClaw bloqueado" → **"Finalizar"**.

Esto asegura que nadie pueda conectarse al puerto de OpenClaw desde internet.

### 5. Instalar Docker (opcional pero recomendado)

1. Ve a [docker.com](https://www.docker.com/products/docker-desktop/) y descarga Docker Desktop para Windows.
2. Ejecuta el instalador y sigue las instrucciones.
3. Reinicia tu computadora cuando termine.

Docker permite que OpenClaw funcione en un "contenedor" aislado, como una caja de juguetes separada.

---

## 🔍 Verificar la instalación

Abre PowerShell y ejecuta:

```powershell
openclaw --version
```

Deberías ver algo como `2026.3.1`.  
Si ves un error, reinicia PowerShell y prueba de nuevo.

---

## ⚙️ Configurar WhatsApp/Telegram

1. En PowerShell, escribe:
   ```powershell
   openclaw onboard
   ```
2. Sigue las instrucciones en pantalla. Escanearás un código QR con tu teléfono.
3. ¡Listo! Ahora tu asistente de OpenClaw está conectado a tu WhatsApp/Telegram.

---

## 🚦 Iniciar el servicio

Para que OpenClaw esté siempre disponible:

```powershell
openclaw gateway start
```

Para verificar que está funcionando:

```powershell
openclaw gateway status
```

Deberías ver `Gateway: running`.

---

## 📝 Pasos después de instalar

### Añadir contactos autorizados

1. Abre el archivo `C:\Users\tuusuario\.openclaw\openclaw.json` con el Bloc de notas.
2. Busca `"allowFrom"` y añade los números de teléfono o IDs de Telegram entre comillas, separados por comas. Ejemplo:
   ```json
   "allowFrom": ["+56912345678", "tg:123456789"]
   ```
3. Guarda el archivo.
4. Reinicia el gateway: `openclaw gateway restart`

### Programar auditorías automáticas

Para que OpenClaw se revise a sí mismo cada semana, ejecuta:

```powershell
openclaw cron add --name "security-audit" --command "openclaw security audit --deep" --weekly --at "sunday 02:00"
```

---

## ❓ Solución de problemas

### "No se reconoce openclaw como un comando"
- Reinicia PowerShell.
- Asegúrate de que Node.js está instalado correctamente (`node --version`).
- Intenta instalar OpenClaw de nuevo: `npm install -g openclaw`.

### "Error de permisos"
- Ejecuta PowerShell como **administrador** (clic derecho → "Ejecutar como administrador").

### "No puedo escanear el código QR"
- Asegúrate de que tu teléfono tenga conexión a internet.
- Si usas WhatsApp, verifica que tu teléfono tenga la última versión.

### "El gateway no inicia"
- Revisa los logs en `%TEMP%\openclaw\openclaw-*.log`.
- Verifica que el puerto 18789 no esté usado por otro programa.

---

## 🆘 Soporte

Si tienes problemas:

1. **Revisa los logs**: `%TEMP%\openclaw\openclaw-*.log`
2. **Consulta la documentación**: [docs.openclaw.ai](https://docs.openclaw.ai)
3. **Únete a la comunidad**: [Discord](https://discord.com/invite/clawd)
4. **Soporte remoto seguro**: Instala Tailscale (el script te lo ofreció) y comparte tu máquina con `support@skillnest.com`.

---

## 🧹 Desinstalación

1. Detén el gateway: `openclaw gateway stop`
2. Desinstala OpenClaw: `npm uninstall -g openclaw`
3. Elimina la carpeta `C:\Users\tuusuario\.openclaw`
4. (Opcional) Desinstala Node.js desde "Agregar o quitar programas".

---

**¡Listo!** Ya tienes un asistente de IA privado y seguro en tu Windows. 🦞

*Última actualización: marzo 2026*