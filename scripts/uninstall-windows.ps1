# Script de desinstalación de OpenClaw para Windows 10/11
# Elimina OpenClaw y limpia la configuración segura

# Configuración
$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "Desinstalacion de OpenClaw"

function Write-Color {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-Color -Message "[+] $Message" -Color Green
}

function Write-Warning {
    param([string]$Message)
    Write-Color -Message "[!] $Message" -Color Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Color -Message "[-] $Message" -Color Red
}

function Write-Info {
    param([string]$Message)
    Write-Color -Message "[OpenClaw] $Message" -Color Cyan
}

# Verificar si estamos ejecutando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warning "Este script requiere permisos de administrador para algunas tareas (firewall, desinstalacion)."
    Write-Info "Se solicitara elevacion..."
    Start-Sleep -Seconds 2
    
    # Relanzar como administrador
    $scriptPath = $MyInvocation.MyCommand.Path
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-ExecutionPolicy Bypass -File `"$scriptPath`""
    $psi.Verb = "runas"
    $psi.WorkingDirectory = Get-Location
    [System.Diagnostics.Process]::Start($psi) | Out-Null
    exit
}

Clear-Host
Write-Color @"
==================================================
        DESINSTALACION DE OPENCLAW
             Para Windows 10/11
==================================================
"@ -Color Magenta

Write-Host ""
Write-Host "Este script hara:" -ForegroundColor White
Write-Host "1. Detener el gateway de OpenClaw (si esta corriendo)" -ForegroundColor Gray
Write-Host "2. Desinstalar OpenClaw globalmente" -ForegroundColor Gray
Write-Host "3. Eliminar configuracion y archivos locales" -ForegroundColor Gray
Write-Host "4. Remover reglas de firewall (opcional)" -ForegroundColor Gray
Write-Host "5. Desinstalar Docker Desktop (opcional)" -ForegroundColor Gray
Write-Host "6. Desinstalar Tailscale (opcional)" -ForegroundColor Gray
Write-Host ""
Write-Host "Nota: Este script NO desinstalara Node.js a menos que lo pidas." -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "¿Estas seguro de desinstalar OpenClaw? (s/n)"
if ($confirm -notmatch "^(s|S)$") {
    Write-Info "Desinstalacion cancelada."
    exit 0
}

# ====================
# 1. DETENER GATEWAY
# ====================
Write-Info "Deteniendo gateway de OpenClaw..."
try {
    openclaw gateway stop 2>$null
    Write-Success "Gateway detenido (si estaba corriendo)."
} catch {
    Write-Info "Gateway no estaba corriendo o ya fue detenido."
}

# ====================
# 2. DESINSTALAR OPENCLAW
# ====================
Write-Info "Desinstalando OpenClaw..."
try {
    npm uninstall -g openclaw 2>$null
    Write-Success "OpenClaw desinstalado."
} catch {
    Write-Warning "No se pudo desinstalar OpenClaw (puede que ya no este instalado)."
}

# ====================
# 3. ELIMINAR CONFIGURACION
# ====================
Write-Info "Eliminando archivos de configuracion..."
$openclawDir = "$env:USERPROFILE\.openclaw"
if (Test-Path $openclawDir) {
    Remove-Item -Recurse -Force $openclawDir -ErrorAction SilentlyContinue
    Write-Success "Configuracion eliminada: $openclawDir"
} else {
    Write-Info "Directorio de configuracion no encontrado."
}

# Eliminar logs temporales
$tempLogs = "$env:TEMP\openclaw"
if (Test-Path $tempLogs) {
    Remove-Item -Recurse -Force $tempLogs -ErrorAction SilentlyContinue
    Write-Success "Logs temporales eliminados."
}

# ====================
# 4. REMOVER REGLAS DE FIREWALL (OPCIONAL)
# ====================
Write-Host ""
$firewallChoice = Read-Host "¿Remover reglas de firewall agregadas por OpenClaw? (s/n)"
if ($firewallChoice -match "^(s|S)$") {
    Write-Info "Removiendo reglas de firewall..."
    try {
        Remove-NetFirewallRule -DisplayName "OpenClaw Block Inbound" -ErrorAction SilentlyContinue 2>$null
        Write-Success "Reglas de firewall removidas."
    } catch {
        Write-Info "No se encontraron reglas de firewall o ya fueron removidas."
    }
}

# ====================
# 5. DESINSTALAR DOCKER DESKTOP (OPCIONAL)
# ====================
Write-Host ""
$dockerChoice = Read-Host "¿Desinstalar Docker Desktop? (s/n)"
if ($dockerChoice -match "^(s|S)$") {
    Write-Info "Desinstalando Docker Desktop..."
    try {
        # Intentar desinstalar via winget
        winget uninstall Docker.DockerDesktop 2>$null
        Write-Success "Docker Desktop desinstalado (puede requerir reinicio)."
    } catch {
        Write-Warning "No se pudo desinstalar Docker Desktop automaticamente."
        Write-Host "Puedes desinstalarlo manualmente desde 'Agregar o quitar programas'." -ForegroundColor Gray
    }
}

# ====================
# 6. DESINSTALAR TAILSCALE (OPCIONAL)
# ====================
Write-Host ""
$tailscaleChoice = Read-Host "¿Desinstalar Tailscale? (s/n)"
if ($tailscaleChoice -match "^(s|S)$") {
    Write-Info "Desinstalando Tailscale..."
    try {
        # Intentar desinstalar via winget
        winget uninstall Tailscale.Tailscale 2>$null
        Write-Success "Tailscale desinstalado."
    } catch {
        Write-Warning "No se pudo desinstalar Tailscale automaticamente."
        Write-Host "Puedes desinstalarlo manualmente desde 'Agregar o quitar programas'." -ForegroundColor Gray
    }
}

# ====================
# 7. DESINSTALAR NODE.JS (OPCIONAL)
# ====================
Write-Host ""
$nodeChoice = Read-Host "¿Desinstalar Node.js? (NO lo hagas si usas Node.js para otros proyectos) (s/n)"
if ($nodeChoice -match "^(s|S)$") {
    Write-Info "Desinstalando Node.js..."
    try {
        winget uninstall OpenJS.NodeJS 2>$null
        Write-Success "Node.js desinstalado."
    } catch {
        Write-Warning "No se pudo desinstalar Node.js automaticamente."
        Write-Host "Puedes desinstalarlo manualmente desde 'Agregar o quitar programas'." -ForegroundColor Gray
    }
}

# ====================
# FINALIZACION
# ====================
Clear-Host
Write-Color @"
==================================================
          DESINSTALACION COMPLETADA
==================================================
"@ -Color Magenta

Write-Host ""
Write-Success "OpenClaw ha sido desinstalado de tu sistema."
Write-Host ""
Write-Host "Recuerda:" -ForegroundColor White
Write-Host "- Si vinculaste WhatsApp/Telegram, revoca el acceso desde la app." -ForegroundColor Gray
Write-Host "- Tu API Key de DeepSeek/OpenAI sigue activa en tu cuenta." -ForegroundColor Gray
Write-Host "- Los backups de tu workspace (si los tenias) fueron eliminados." -ForegroundColor Gray
Write-Host ""
Write-Host "Para reinstalar:" -ForegroundColor White
Write-Host "curl -fsSL https://raw.githubusercontent.com/skillnest/openclaw-secure/main/scripts/install-windows.ps1 | powershell -" -ForegroundColor Gray
Write-Host ""
Write-Host "Gracias por usar OpenClaw Seguro de SkillNest." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Magenta

# Pausar para que el usuario pueda leer
Write-Host ""
Write-Host "Presiona Enter para salir..." -ForegroundColor Gray
Read-Host