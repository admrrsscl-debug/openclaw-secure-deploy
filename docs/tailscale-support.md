# Soporte remoto seguro con Tailscale

Guía para conectar tu computadora con nuestro equipo de soporte de forma **segura y privada**, sin abrir puertos a internet.

---

## 🤔 ¿Qué es Tailscale?

Tailscale es una **VPN privada** que conecta tus dispositivos como si estuvieran en la misma red local, pero sin configuración complicada. Es como un cable invisible y seguro entre tu computadora y la nuestra.

**Ventajas:**
- ✅ **No expones puertos** a internet.
- ✅ **Cifrado de extremo a extremo** (nadie puede espiar).
- ✅ **Fácil de usar**: solo necesitas una cuenta (Google, GitHub, etc.).
- ✅ **Gratis** para uso personal y hasta 3 dispositivos.

---

## 🚀 Configurar Tailscale para soporte

### Paso 1: Instalar Tailscale

#### En Windows:
1. Descarga Tailscale desde [tailscale.com/download](https://tailscale.com/download).
2. Ejecuta el instalador y sigue los pasos.
3. Abre Tailscale desde el menú Inicio.

#### En macOS:
```bash
brew install tailscale
```
O descarga la aplicación desde el sitio web.

#### En Ubuntu/Linux:
```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

### Paso 2: Iniciar sesión

1. Abre Tailscale (o ejecuta `sudo tailscale up` en Linux/macOS).
2. Te pedirá que inicies sesión con tu cuenta de **Google, GitHub, Microsoft, etc.** Elige la que prefieras.
3. Sigue las instrucciones en pantalla.

### Paso 3: Compartir tu máquina con soporte

Una vez conectado, verás tu máquina en la lista de dispositivos de Tailscale. Para compartirla con nosotros:

1. **Abre el panel de Tailscale** en [login.tailscale.com](https://login.tailscale.com/admin/machines).
2. Encuentra tu máquina en la lista.
3. Haz clic en los **tres puntos** (⋯) y selecciona **"Share…"**.
4. En el campo de correo, escribe: **`support@skylabs.com`**.
5. Selecciona **"Read‑only"** (solo lectura) para mayor seguridad.
6. Haz clic en **"Share"**.

**¡Listo!** Ahora nuestro equipo podrá conectarse a tu computadora de forma segura.

---

## 🔧 Configurar OpenClaw para acceso remoto seguro

Por defecto, OpenClaw solo escucha localmente (`127.0.0.1`). Para permitir que nuestro equipo se conecte a través de Tailscale, debes cambiar la configuración:

### Editar el archivo de configuración

1. Abre `~/.openclaw/openclaw.json` (en Linux/macOS) o `C:\Users\tuusuario\.openclaw\openclaw.json` (Windows).
2. Busca la sección `"gateway"` y cámbiala así:

```json
{
  "gateway": {
    "mode": "local",
    "bind": "0.0.0.0",          // Escuchar en todas las interfaces
    "port": 18789,
    "auth": {
      "mode": "token",
      "token": "TU_TOKEN_AQUI"  // El mismo token que ya tienes
    },
    "trustedProxies": ["100.64.0.0/10"]  // Rango de IPs de Tailscale
  }
}
```

3. Guarda el archivo.
4. Reinicia el gateway:
   ```bash
   openclaw gateway restart
   ```

**Explicación:**
- `"bind": "0.0.0.0"` permite conexiones desde cualquier red (pero solo desde las IPs de Tailscale gracias al firewall del sistema).
- `"trustedProxies"` le dice a OpenClaw que confíe en las IPs de Tailscale.

### Paso opcional: Configurar firewall

Aunque Tailscale es seguro, puedes agregar una regla de firewall para permitir solo conexiones desde la red de Tailscale:

#### En Linux (ufw):
```bash
sudo ufw allow from 100.64.0.0/10 to any port 18789
```

#### En Windows (PowerShell como administrador):
```powershell
New-NetFirewallRule -DisplayName "OpenClaw Tailscale" -Direction Inbound -LocalPort 18789 -Protocol TCP -RemoteAddress 100.64.0.0/10 -Action Allow
```

#### En macOS (pf):
Edita `/etc/pf.conf` o usa la interfaz gráfica de seguridad.

---

## 📞 Cómo contactarnos para soporte

Una vez que hayas compartido tu máquina con `support@skylabs.com`:

1. **Envía un correo** a `support@skylabs.com` con:
   - Tu nombre y empresa (si aplica).
   - Una breve descripción del problema.
   - La **IP de Tailscale** de tu máquina (la ves en el panel de Tailscale, algo como `100.xx.xx.xx`).
   - El **token del Gateway** (el que está en `openclaw.json`).

2. **Nuestro equipo se conectará** a tu máquina usando:
   ```
   http://<tu-ip-tailscale>:18789/
   ```
   y el token que les diste.

3. **Te avisaremos** cuando hayamos terminado, y dejaremos de tener acceso automáticamente si revocas el sharing.

---

## 🔒 Seguridad adicional

### ¿Qué puede hacer nuestro equipo con acceso "read‑only"?
- Ver el estado del gateway.
- Revisar logs.
- Ejecutar auditorías de seguridad.
- **No puede** ejecutar comandos peligrosos, modificar archivos fuera de OpenClaw, ni acceder a tus datos personales.

### ¿Cómo revocar el acceso?
1. Ve a [login.tailscale.com](https://login.tailscale.com/admin/machines).
2. Encuentra tu máquina.
3. Haz clic en los tres puntos (⋯) y selecciona **"Remove sharing…"**.
4. Confirma.

**El acceso se revoca instantáneamente.**

---

## ❓ Preguntas frecuentes

### ¿Tailscale es realmente seguro?
Sí. Tailscale usa **WireGuard**, un protocolo de VPN moderno y auditado. Todo el tráfico está cifrado y solo las personas que tú autorizas pueden conectarse.

### ¿Necesito abrir puertos en mi router?
**No.** Tailscale funciona a través de "agujeros" NAT (hole punching) y relays. No necesitas tocar tu router.

### ¿Puedo usar Tailscale para otras cosas?
¡Claro! Puedes conectar tus propios dispositivos (teléfono, laptop, servidor) y acceder a ellos desde cualquier lugar.

### ¿Qué pasa si me desconecto de Tailscale?
El acceso remoto dejará de funcionar hasta que te reconectes.

### ¿Tailscale es gratis?
Sí, para hasta 3 dispositivos y uso personal. Para más dispositivos o equipos, tienen planes de pago.

---

## 🆘 ¿Problemas con Tailscale?

- **No puedo iniciar sesión**: Asegúrate de que tu proveedor (Google, GitHub) esté permitido por Tailscale.
- **Mi máquina no aparece**: Reinicia el cliente de Tailscale o ejecuta `sudo tailscale up` de nuevo.
- **El sharing no funciona**: Verifica que escribiste correctamente `support@skylabs.com`.
- **Conexión lenta**: Tailscale puede usar relays si no puede establecer conexión directa. Revisa tu firewall/router.

**Soporte de Tailscale:** [support.tailscale.com](https://support.tailscale.com)

---

## 📚 Recursos

- [Documentación de Tailscale](https://tailscale.com/kb/)
- [Cómo funciona Tailscale](https://tailscale.com/how-it-works)
- [Panel de administración](https://login.tailscale.com/admin)

---

**Con Tailscale, ofrecemos soporte remoto sin comprometer tu seguridad.** 🛡️

*Última actualización: marzo 2026*