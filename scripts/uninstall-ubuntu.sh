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

clear
echo "=================================================="
echo "        DESINSTALACIÓN DE OPENCLAW"
echo "             Para Ubuntu/Debian"
echo "=================================================="
echo ""
echo "Este script hará:"
echo "1. Detener el gateway de OpenClaw (si está corriendo)"
echo "2. Desinstalar OpenClaw globalmente"
echo "3. Eliminar configuración y archivos locales"
echo "4. Remover reglas de firewall (opcional)"
echo "5. Desinstalar Docker (opcional)"
echo "6. Desinstalar Tailscale (opcional)"
echo ""
echo -e "${YELLOW}Nota: Este script NO desinstalará Node.js a menos que lo pidas.${NC}"
echo ""
read -p "¿Estás seguro de desinstalar OpenClaw? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    print_msg "Desinstalación cancelada."
    exit 0
fi

# ====================
# 1. DETENER GATEWAY
# ====================
print_msg "Deteniendo gateway de OpenClaw..."
openclaw gateway stop 2>/dev/null || true
print_success "Gateway detenido (si estaba corriendo)."

# ====================
# 2. DESINSTALAR OPENCLAW
# ====================
print_msg "Desinstalando OpenClaw..."
sudo npm uninstall -g openclaw 2>/dev/null || true
print_success "OpenClaw desinstalado."

# ====================
# 3. ELIMINAR CONFIGURACIÓN
# ====================
print_msg "Eliminando archivos de configuración..."
if [[ -d ~/.openclaw ]]; then
    rm -rf ~/.openclaw
    print_success "Configuración eliminada: ~/.openclaw"
else
    print_msg "Directorio de configuración no encontrado."
fi

# Eliminar logs temporales
if [[ -d /tmp/openclaw ]]; then
    rm -rf /tmp/openclaw
    print_success "Logs temporales eliminados."
fi

# ====================
# 4. REMOVER REGLAS DE FIREWALL (OPCIONAL)
# ====================
echo ""
read -p "¿Remover reglas de firewall agregadas por OpenClaw? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_msg "Removiendo reglas de firewall..."
    sudo ufw delete allow from 100.64.0.0/10 to any port 18789 2>/dev/null || true
    print_success "Reglas de firewall removidas."
fi

# ====================
# 5. DESINSTALAR DOCKER (OPCIONAL)
# ====================
echo ""
read -p "¿Desinstalar Docker? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_msg "Desinstalando Docker..."
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io 2>/dev/null || true
    print_success "Docker desinstalado."
fi

# ====================
# 6. DESINSTALAR TAILSCALE (OPCIONAL)
# ====================
echo ""
read -p "¿Desinstalar Tailscale? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_msg "Desinstalando Tailscale..."
    sudo apt-get remove -y tailscale 2>/dev/null || true
    print_success "Tailscale desinstalado."
fi

# ====================
# 7. DESINSTALAR NODE.JS (OPCIONAL)
# ====================
echo ""
read -p "¿Desinstalar Node.js? (NO lo hagas si usas Node.js para otros proyectos) (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_msg "Desinstalando Node.js..."
    sudo apt-get remove -y nodejs 2>/dev/null || true
    print_success "Node.js desinstalado."
fi

# ====================
# FINALIZACIÓN
# ====================
clear
echo ""
echo "=================================================="
echo "          DESINSTALACIÓN COMPLETADA"
echo "=================================================="
echo ""
print_success "OpenClaw ha sido desinstalado de tu sistema."
echo ""
echo "Recuerda:"
echo "- Si vinculaste WhatsApp/Telegram, revoca el acceso desde la app."
echo "- Tu API Key de DeepSeek/OpenAI sigue activa en tu cuenta."
echo "- Los backups de tu workspace (si los tenías) fueron eliminados."
echo ""
echo "Para reinstalar:"
echo "curl -fsSL https://raw.githubusercontent.com/skillnest/openclaw-secure/main/scripts/install-ubuntu.sh | bash"
echo ""
echo "Gracias por usar OpenClaw Seguro de SkillNest."
echo "=================================================="