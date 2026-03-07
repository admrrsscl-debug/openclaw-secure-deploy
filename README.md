# 🦞 OpenClaw Seguro para Skillnest

**Instalación segura de OpenClaw en tu propia computadora**  
Para clientes que quieren un asistente de IA privado, sin riesgos de seguridad.

---

## 📦 ¿Qué incluye este paquete?

- ✅ **Configuración segura por defecto**: el asistente no expone puertos, requiere aprobación para nuevos contactos, y limita herramientas peligrosas.
- ✅ **Instaladores automáticos** para Windows, macOS y Ubuntu.
- ✅ **Guías paso a paso** tan simples que las entendería un niño de 12 años.
- ✅ **Soporte remoto seguro** mediante Tailscale (VPN simple).
- ✅ **Monitoreo automático** con auditorías de seguridad periódicas.
- ✅ **Separación de datos**: cada cliente tiene su propia máquina, sus propios datos.

---

## 🖥️ ¿Para quién es esto?

- **Empresas** que quieren un asistente de IA interno sin depender de la nube.
- **Consultores** que necesitan automatizar comunicaciones con clientes.
- **Personas** que desean un asistente personal 100% privado.
- **Cualquiera** que tenga una computadora (Windows, Mac o Linux) y quiera probar OpenClaw de forma segura.

---

## 🚀 Instalación rápida (elige tu sistema)

### 1. **Windows 10/11** (con PowerShell)
   - Descarga el script de instalación desde [aquí](scripts/install-windows.ps1).
   - Haz clic derecho en el archivo y selecciona **"Ejecutar con PowerShell"**.
   - Sigue las instrucciones en pantalla.  
   [Ver guía completa](docs/windows-install.md)

### 2. **Ubuntu/Linux** (terminal)
   ```bash
   curl -fsSL https://raw.githubusercontent.com/skillnest/openclaw-secure/main/scripts/install-ubuntu.sh | bash
   ```
   [Ver guía completa](docs/ubuntu-install.md)

### 3. **macOS** (terminal)
   ```bash
   curl -fsSL https://raw.githubusercontent.com/skillnest/openclaw-secure/main/scripts/install-mac.sh | bash
   ```
   [Ver guía completa](docs/mac-install.md)

---

## 🔒 ¿Por qué es seguro?

| Característica | Explicación simple |
|----------------|-------------------|
| **Gateway solo local** | OpenClaw solo escucha dentro de tu computadora, no en internet. |
| **Pairing de contactos** | Cada nuevo contacto debe ser aprobado por ti con un código de un solo uso. |
| **Grupos con lista blanca** | Solo personas que tú autorices pueden escribir en grupos. |
| **Herramientas limitadas** | El asistente no puede ejecutar comandos peligrosos sin tu permiso explícito. |
| **Sandbox Docker** | El asistente corre en un contenedor aislado (como una caja de juguetes). |
| **Firewall automático** | El instalador configura el firewall para bloquear conexiones no deseadas. |
| **Auditorías periódicas** | OpenClaw se revisa a sí mismo cada semana en busca de problemas. |

---

## 🛠️ Soporte remoto seguro (con Tailscale)

Si necesitas ayuda de nuestro equipo, usamos **Tailscale**: una VPN simple que conecta tu computadora con la nuestra de forma segura.

### Pasos para soporte:
1. **Instala Tailscale** (el instalador lo hace por ti, o puedes [descargarlo manualmente](https://tailscale.com/download)).
2. **Inicia sesión** con tu cuenta de Google, GitHub, etc.
3. **Comparte tu máquina** con `support@skillnest.com` (solo lectura).
4. **Nos conectamos** sin que tengas que abrir puertos.

[Guía completa de soporte con Tailscale](docs/tailscale-support.md)

---

## 📝 Después de instalar

1. **Configura WhatsApp/Telegram**  
   Ejecuta en terminal:  
   ```bash
   openclaw onboard
   ```
   Escanea el código QR con tu teléfono.

2. **Añade contactos autorizados**  
   Edita el archivo `~/.openclaw/openclaw.json` (en Linux/Mac) o `C:\Users\tuusuario\.openclaw\openclaw.json` (Windows) y añade números/IDs en las secciones `allowFrom` y `groupAllowFrom`.

3. **Inicia el servicio**  
   ```bash
   openclaw gateway start
   ```

4. **Verifica que todo funciona**  
   ```bash
   openclaw gateway status
   ```

5. **Programa auditorías automáticas** (opcional pero recomendado)  
   ```bash
   openclaw cron add --name "security-audit" --command "openclaw security audit --deep" --daily --at "02:00"
   ```

---

## ❓ Preguntas frecuentes

### ¿Puedo usar esta instalación en una computadora que ya uso para otras cosas?
**Sí.** OpenClaw solo usa los recursos cuando está activo y no interfiere con otros programas.

### ¿Necesito saber programación?
**No.** Los instaladores son automáticos. Solo necesitas seguir los pasos.

### ¿Puedo desinstalarlo?
**Sí.** Cada instalador incluye un script de desinstalación.

### ¿Qué pasa si me olvido de aprobar un contacto?
El contacto no podrá escribir hasta que apruebes el código de pairing. Los códigos expiran en 1 hora.

### ¿Puedo cambiar el modelo de IA?
**Sí.** En el archivo de configuración puedes cambiar la API Key y el proveedor (DeepSeek, OpenAI, etc.).

---

## 📞 Contacto y soporte

- **Soporte técnico**: support@skillnest.com  
- **Documentación oficial**: [docs.openclaw.ai](https://docs.openclaw.ai)  
- **Comunidad Discord**: [invite.clawd](https://discord.com/invite/clawd)  

---

## ⚖️ Licencia

Este repositorio es de código abierto bajo licencia MIT.  
OpenClaw es un proyecto comunitario; Skillnest ofrece empaquetado seguro y soporte profesional.

**¿Listo para empezar?** → Elige tu sistema operativo arriba. 🚀

---

*Última actualización: marzo 2026*  
*Mantenido por Skillnest y la comunidad OpenClaw.*
