#!/bin/bash
set -e

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_msg() {
    echo -e "${BLUE}[OpenClaw]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Verificar que estamos en macOS
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "Este script está diseñado para macOS."
    exit 1
fi

clear
echo "=================================================="
echo "        🦞 INSTALACIÓN SEGURA DE OPENCLAW"
echo "             Para macOS"
echo "=================================================="
echo ""
echo "Este script hará:"
echo "1. Instalar Homebrew (si no está)"
echo "2. Instalar Node.js 22"
echo "3. Instalar OpenClaw globalmente"
echo "4. Crear configuración segura"
echo "5. Configurar firewall (opcional)"
echo "6. Instalar Docker (para sandbox) opcional"
echo "7. Ejecutar auditoría de seguridad"
echo ""
echo "Necesitarás:"
echo "- Conexión a internet"
echo -e "- Permisos de administrador ${YELLOW}(se te pedirá contraseña)${NC}"
echo ""
read -p "¿Listo para comenzar? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    print_msg "Instalación cancelada."
    exit 0
fi

print_msg "Comenzando instalación..."

# ====================
# 1. INSTALAR HOMEBREW
# ====================
if ! command -v brew &> /dev/null; then
    print_msg "Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"  # Para Apple Silicon
    print_success "Homebrew instalado."
else
    print_success "Homebrew ya está instalado."
fi

# ====================
# 2. INSTALAR NODE.JS 22
# ====================
if ! command -v node &> /dev/null; then
    print_msg "Instalando Node.js 22..."
    brew install node@22
    echo 'export PATH="/opt/homebrew/opt/node@22/bin:$PATH"' >> ~/.zshrc
    echo 'export PATH="/opt/homebrew/opt/node@22/bin:$PATH"' >> ~/.bash_profile
    export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
    print_success "Node.js $(node --version) instalado."
else
    print_success "Node.js ya está instalado: $(node --version)"
fi

# ====================
# 3. INSTALAR OPENCLAW
# ====================
print_msg "Instalando OpenClaw..."
sudo npm install -g openclaw
print_success "OpenClaw instalado."

# ====================
# 4. CREAR DIRECTORIO DE CONFIGURACIÓN
# ====================
print_msg "Creando directorio de configuración..."
mkdir -p ~/.openclaw

# ====================
# 5. GENERAR TOKEN SEGURO
# ====================
GATEWAY_TOKEN=$(openssl rand -hex 24)
print_success "Token generado automáticamente."

# ====================
# 6. PEDIR API KEY DE DEEPSEEK
# ====================
echo ""
print_msg "¿Qué modelo de IA quieres usar?"
echo "1. DeepSeek (recomendado, económico y potente)"
echo "2. OpenAI GPT"
echo "3. Otro (configuraré después)"
read -p "Elige una opción (1/2/3): " -n 1 -r
echo

DEEPSEEK_API_KEY=""
if [[ $REPLY == "1" ]]; then
    echo ""
    print_warn "Necesitas una API Key de DeepSeek."
    echo "1. Ve a https://platform.deepseek.com/api-keys"
    echo "2. Crea una cuenta (es gratis)"
    echo "3. Genera una API Key"
    echo ""
    read -p "Pega tu API Key aquí (o presiona Enter para omitir): " DEEPSEEK_API_KEY
    if [[ -z "$DEEPSEEK_API_KEY" ]]; then
        print_warn "No se proporcionó API Key. Podrás configurarla después en ~/.openclaw/openclaw.json"
    else
        print_success "API Key guardada (se ocultará en el archivo)."
    fi
elif [[ $REPLY == "2" ]]; then
    print_warn "Deberás editar manualmente ~/.openclaw/openclaw.json para configurar OpenAI."
    echo "Consulta la guía en: https://docs.openclaw.ai/gateway/configuration#models"
fi

# ====================
# 7. COPIAR PLANTILLA SEGURA
# ====================
print_msg "Creando configuración segura..."
USER_HOME="$HOME"
CONFIG_TEMPLATE="$(dirname "$0")/../configs/openclaw.json.hardened"

if [[ -f "$CONFIG_TEMPLATE" ]]; then
    sed "s/{{RANDOM_TOKEN}}/$GATEWAY_TOKEN/g" "$CONFIG_TEMPLATE" \
        | sed "s/{{DEEPSEEK_API_KEY}}/$DEEPSEEK_API_KEY/g" \
        | sed "s|{{USER_HOME}}|$USER_HOME|g" \
        > ~/.openclaw/openclaw.json
    print_success "Configuración guardada en ~/.openclaw/openclaw.json"
else
    print_error "No se encontró la plantilla de configuración. Creando configuración básica..."
    cat > ~/.openclaw/openclaw.json << EOF
{
  "gateway": {
    "mode": "local",
    "bind": "loopback",
    "port": 18789,
    "auth": { "mode": "token", "token": "$GATEWAY_TOKEN" }
  },
  "channels": {
    "whatsapp": { "dmPolicy": "pairing", "groupPolicy": "allowlist" },
    "telegram": { "dmPolicy": "pairing", "groupPolicy": "allowlist" }
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
EOF
    print_success "Configuración básica creada."
fi

# ====================
# 8. AJUSTAR PERMISOS
# ====================
chmod 700 ~/.openclaw
chmod 600 ~/.openclaw/openclaw.json
print_success "Permisos ajustados."

# ====================
# 9. INSTALAR DOCKER (OPCIONAL)
# ====================
echo ""
read -p "¿Instalar Docker para sandbox de agentes? (recomendado) (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_msg "Verificando Docker..."
    if ! command -v docker &> /dev/null; then
        print_msg "Instalando Docker Desktop..."
        brew install --cask docker
        print_success "Docker instalado."
        print_warn "Abre Docker Desktop desde Aplicaciones para completar la instalación."
        print_warn "Luego reinicia la terminal."
    else
        print_success "Docker ya está instalado: $(docker --version)"
    fi
else
    print_msg "Omitiendo Docker. Los agentes se ejecutarán directamente (menos seguro)."
fi

# ====================
# 10. CONFIGURAR FIREWALL (OPCIONAL)
# ====================
echo ""
read -p "¿Configurar firewall (pf) para bloquear conexiones no deseadas? (recomendado) (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_msg "Configurando firewall..."
    # Habilitar firewall de aplicación
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
    # Bloquear todo por defecto
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setblockall on
    # Permitir servicios esenciales
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/sbin/sshd
    print_success "Firewall activado (solo SSH permitido)."
else
    print_msg "Omitiendo configuración de firewall."
fi

# ====================
# 11. EJECUTAR AUDITORÍA DE SEGURIDAD
# ====================
print_msg "Ejecutando auditoría de seguridad OpenClaw..."
openclaw security audit --fix
print_success "Auditoría completada."

# ====================
# 12. CONFIGURAR TAILSCALE (OPCIONAL)
# ====================
echo ""
read -p "¿Instalar Tailscale para soporte remoto seguro? (recomendado) (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_msg "Instalando Tailscale..."
    if ! command -v tailscale &> /dev/null; then
        brew install tailscale
        print_success "Tailscale instalado."
        print_warn "Para activarlo, ejecuta: ${YELLOW}sudo tailscale up${NC}"
        print_warn "Luego comparte tu máquina con: ${YELLOW}support@skillnest.com${NC}"
    else
        print_success "Tailscale ya está instalado."
    fi
fi

# ====================
# 🎉 FINALIZACIÓN
# ====================
clear
echo ""
echo "=================================================="
echo "          🎉 INSTALACIÓN COMPLETADA"
echo "=================================================="
echo ""
echo "✅ OpenClaw está instalado y configurado de forma segura."
echo ""
echo "📂 Configuración guardada en: ${YELLOW}~/.openclaw/openclaw.json${NC}"
echo "🔐 Token del Gateway: ${YELLOW}$GATEWAY_TOKEN${NC} (guárdalo en un lugar seguro)"
echo ""
echo "📝 Pasos siguientes:"
echo "1. Configurar WhatsApp/Telegram:"
echo "   ${YELLOW}openclaw onboard${NC}"
echo "2. Iniciar el servicio:"
echo "   ${YELLOW}openclaw gateway start${NC}"
echo "3. Verificar estado:"
echo "   ${YELLOW}openclaw gateway status${NC}"
echo "4. Añadir contactos autorizados editando el archivo de configuración."
echo ""
echo "🔧 Soporte:"
echo "- Documentación: ${YELLOW}https://docs.openclaw.ai${NC}"
echo "- Soporte remoto: ${YELLOW}Tailscale${NC} (ya instalado)"
echo "- Comunidad: ${YELLOW}https://discord.com/invite/clawd${NC}"
echo ""
echo "⚠️  Recuerda:"
echo "- El Gateway solo escucha localmente (127.0.0.1)."
echo "- Cada nuevo contacto requiere aprobación (pairing)."
echo "- Revisa los logs en ${YELLOW}/tmp/openclaw/openclaw-*.log${NC}"
echo ""
echo "Gracias por usar OpenClaw Seguro de SkillNest. 🦞"
echo "=================================================="