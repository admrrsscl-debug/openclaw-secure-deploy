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

# Verificar que estamos en Ubuntu/Debian
if ! command -v lsb_release &> /dev/null; then
    print_warn "No se pudo detectar la distribución. Este script está optimizado para Ubuntu/Debian."
    read -p "¿Continuar de todas formas? (s/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 1
    fi
else
    DISTRO=$(lsb_release -is)
    if [[ "$DISTRO" != "Ubuntu" && "$DISTRO" != "Debian" ]]; then
        print_warn "Distribución detectada: $DISTRO. Este script está optimizado para Ubuntu/Debian."
        read -p "¿Continuar de todas formas? (s/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            exit 1
        fi
    fi
fi

clear
echo "=================================================="
echo "        🦞 INSTALACIÓN SEGURA DE OPENCLAW"
echo "             Para Ubuntu/Debian"
echo "=================================================="
echo ""
echo "Este script hará:"
echo "1. Instalar Node.js 22 (si no está)"
echo "2. Instalar OpenClaw globalmente"
echo "3. Crear configuración segura"
echo "4. Configurar firewall (ufw) opcional"
echo "5. Instalar Docker (para sandbox) opcional"
echo "6. Ejecutar auditoría de seguridad"
echo ""
echo "Necesitarás:"
echo "- Conexión a internet"
echo -e "- Permisos de superusuario (sudo) ${YELLOW}(se te pedirá contraseña)${NC}"
echo ""
read -p "¿Listo para comenzar? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    print_msg "Instalación cancelada."
    exit 0
fi

print_msg "Comenzando instalación..."

# ====================
# 1. ACTUALIZAR SISTEMA
# ====================
print_msg "Actualizando lista de paquetes..."
sudo apt-get update -qq

# ====================
# 2. INSTALAR NODE.JS 22
# ====================
if ! command -v node &> /dev/null; then
    print_msg "Instalando Node.js 22..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
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
# 7. HERRAMIENTAS WEB (ACCESO A INTERNET)
# ====================
echo ""
print_msg "Herramientas web (acceso a internet):"
echo "El asistente puede usar web_search (buscar en internet) y web_fetch (obtener contenido de URLs)."
echo "Riesgos: el agente podrá acceder a contenido público de internet."
echo "Beneficios: puede buscar información actualizada (noticias, precios, clima, documentación)."
echo ""
read -p "¿Quieres habilitar herramientas web (búsqueda y fetch)? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    ALLOW_WEB_TOOLS='"allow": ["web_search", "web_fetch"],'
    print_success "Herramientas web habilitadas."
else
    ALLOW_WEB_TOOLS=""
    print_msg "Herramientas web deshabilitadas (solo herramientas locales)."
fi

# ====================
# 8. COPIAR PLANTILLA SEGURA
# ====================
print_msg "Creando configuración segura..."
USER_HOME="$HOME"
CONFIG_TEMPLATE="$(dirname "$0")/../configs/openclaw.json.hardened"

if [[ -f "$CONFIG_TEMPLATE" ]]; then
    sed "s/{{RANDOM_TOKEN}}/$GATEWAY_TOKEN/g" "$CONFIG_TEMPLATE" \
        | sed "s/{{DEEPSEEK_API_KEY}}/$DEEPSEEK_API_KEY/g" \
        | sed "s|{{USER_HOME}}|$USER_HOME|g" \
        | sed 's/{{ALLOW_WEB_TOOLS}}/'"$ALLOW_WEB_TOOLS"'/g' \
        > ~/.openclaw/openclaw.json
    print_success "Configuración guardada en ~/.openclaw/openclaw.json"
else
    print_error "No se encontró la plantilla de configuración. Creando configuración básica..."
    # Configuración básica
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
    $ALLOW_WEB_TOOLS
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
# 9. AJUSTAR PERMISOS
# ====================
chmod 700 ~/.openclaw
chmod 600 ~/.openclaw/openclaw.json
print_success "Permisos ajustados."

# ====================
# 10. INSTALAR DOCKER (OPCIONAL)
# ====================
echo ""
read -p "¿Instalar Docker para sandbox de agentes? (recomendado) (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_msg "Instalando Docker..."
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker "$USER"
        print_success "Docker instalado."
        print_warn "⚠️  Debes cerrar sesión y volver a entrar para que los permisos surtan efecto."
    else
        print_success "Docker ya está instalado: $(docker --version)"
    fi
else
    print_msg "Omitiendo Docker. Los agentes se ejecutarán directamente (menos seguro)."
fi

# ====================
# 11. CONFIGURAR FIREWALL (OPCIONAL)
# ====================
echo ""
read -p "¿Configurar firewall (ufw) para bloquear conexiones no deseadas? (recomendado) (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_msg "Configurando firewall..."
    if ! command -v ufw &> /dev/null; then
        sudo apt-get install -y ufw
    fi
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw --force enable
    print_success "Firewall activado (solo SSH permitido)."
else
    print_msg "Omitiendo configuración de firewall."
fi

# ====================
# 12. EJECUTAR AUDITORÍA DE SEGURIDAD
# ====================
print_msg "Ejecutando auditoría de seguridad OpenClaw..."
openclaw security audit --fix
print_success "Auditoría completada."

# ====================
# 13. CONFIGURAR TAILSCALE (OPCIONAL)
# ====================
echo ""
read -p "¿Instalar Tailscale para soporte remoto seguro? (recomendado) (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_msg "Instalando Tailscale..."
    if ! command -v tailscale &> /dev/null; then
        curl -fsSL https://tailscale.com/install.sh | sh
        print_success "Tailscale instalado."
        print_warn "Para activarlo, ejecuta: ${YELLOW}sudo tailscale up${NC}"
        print_warn "Luego comparte tu máquina con: ${YELLOW}support@skylabs.com${NC}"
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
echo "Gracias por usar OpenClaw Seguro de Skylabs. 🦞"
echo "=================================================="

# 🌟 Solicitar estrella al repositorio
bash scripts/star-repo.sh
