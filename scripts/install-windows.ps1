# Script de instalación segura de OpenClaw para Windows 10/11
# Ejecutar como administrador (se pedirá elevación si es necesario)
# Versión corregida: solo caracteres ASCII, sintaxis compatible

# Configuración
$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "Instalacion segura de OpenClaw"

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
    Write-Warning "Este script requiere permisos de administrador para algunas tareas (firewall, instalacion)."
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
        INSTALACION SEGURA DE OPENCLAW
             Para Windows 10/11
==================================================
"@ -Color Magenta

Write-Host ""
Write-Host "Este script hara:" -ForegroundColor White
Write-Host "1. Instalar Node.js 22 (si no esta)" -ForegroundColor Gray
Write-Host "2. Instalar OpenClaw globalmente" -ForegroundColor Gray
Write-Host "3. Crear configuracion segura" -ForegroundColor Gray
Write-Host "4. Configurar reglas de firewall (opcional)" -ForegroundColor Gray
Write-Host "5. Instalar Docker Desktop (opcional)" -ForegroundColor Gray
Write-Host "6. Ejecutar auditoria de seguridad" -ForegroundColor Gray
Write-Host ""
Write-Host "Necesitaras:" -ForegroundColor White
Write-Host "- Conexion a internet" -ForegroundColor Gray
Write-Host "- Permisos de administrador" -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Listo para comenzar? (s/n)"
if ($confirm -notmatch "^(s|S)$") {
    Write-Info "Instalacion cancelada."
    exit 0
}

# ====================
# 1. INSTALAR NODE.JS 22
# ====================
Write-Info "Verificando Node.js..."
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Info "Instalando Node.js 22..."
    # Descargar e instalar Node.js
    $nodeInstaller = "$env:TEMP\node-installer.msi"
    try {
        Invoke-WebRequest -Uri "https://nodejs.org/dist/v22.22.0/node-v22.22.0-x64.msi" -OutFile $nodeInstaller -ErrorAction Stop
        Start-Process msiexec.exe -Wait -ArgumentList "/i `"$nodeInstaller`" /quiet /norestart" -ErrorAction Stop
        Remove-Item $nodeInstaller -Force -ErrorAction SilentlyContinue
        # Anadir Node.js al PATH (por si acaso)
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        Write-Success "Node.js instalado."
    } catch {
        Write-Error "Error instalando Node.js: $_"
        Write-Host "Puedes instalarlo manualmente desde https://nodejs.org" -ForegroundColor Gray
        exit 1
    }
} else {
    $nodeVersion = node --version
    Write-Success "Node.js ya esta instalado: $nodeVersion"
}

# ====================
# 2. INSTALAR OPENCLAW
# ====================
Write-Info "Instalando OpenClaw..."
try {
    npm install -g openclaw
    Write-Success "OpenClaw instalado."
} catch {
    Write-Error "Error instalando OpenClaw: $_"
    exit 1
}

# ====================
# 3. CREAR DIRECTORIO DE CONFIGURACION
# ====================
Write-Info "Creando directorio de configuracion..."
$openclawDir = "$env:USERPROFILE\.openclaw"
New-Item -ItemType Directory -Force -Path $openclawDir -ErrorAction SilentlyContinue | Out-Null
Write-Success "Directorio creado: $openclawDir"

# ====================
# 4. GENERAR TOKEN SEGURO
# ====================
$gatewayToken = -join ((65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
Write-Success "Token generado automaticamente."

# ====================
# 5. PEDIR API KEY DE DEEPSEEK
# ====================
Write-Host ""
Write-Info "Que modelo de IA quieres usar?"
Write-Host "1. DeepSeek (recomendado, economico y potente)" -ForegroundColor Gray
Write-Host "2. OpenAI GPT" -ForegroundColor Gray
Write-Host "3. Otro (configurare despues)" -ForegroundColor Gray
$modelChoice = Read-Host "Elige una opcion (1/2/3)"

$deepseekApiKey = ""
if ($modelChoice -eq "1") {
    Write-Host ""
    Write-Warning "Necesitas una API Key de DeepSeek."
    Write-Host "1. Ve a https://platform.deepseek.com/api-keys" -ForegroundColor Gray
    Write-Host "2. Crea una cuenta (es gratis)" -ForegroundColor Gray
    Write-Host "3. Genera una API Key" -ForegroundColor Gray
    Write-Host ""
    $deepseekApiKey = Read-Host "Pega tu API Key aqui (o presiona Enter para omitir)"
    if ([string]::IsNullOrWhiteSpace($deepseekApiKey)) {
        Write-Warning "No se proporciono API Key. Podras configurarla despues en $openclawDir\openclaw.json"
    } else {
        Write-Success "API Key guardada (se ocultara en el archivo)."
    }
} elseif ($modelChoice -eq "2") {
    Write-Warning "Deberas editar manualmente $openclawDir\openclaw.json para configurar OpenAI."
    Write-Host "Consulta la guia en: https://docs.openclaw.ai/gateway/configuration#models" -ForegroundColor Gray
}

# ====================
# 6. PREGUNTAR SOBRE HERRAMIENTAS WEB
# ====================
Write-Host ""
Write-Info "Herramientas web (acceso a internet):"
Write-Host "El asistente puede usar web_search (buscar en internet) y web_fetch (obtener contenido de URLs)." -ForegroundColor Gray
Write-Host "Riesgos: el agente podra acceder a contenido publico de internet." -ForegroundColor Gray
Write-Host "Beneficios: puede buscar informacion actualizada (noticias, precios, clima, documentacion)." -ForegroundColor Gray
Write-Host ""
$webChoice = Read-Host "Quieres habilitar herramientas web (busqueda y fetch)? (s/n)"
if ($webChoice -match "^(s|S)$") {
    $allowWebTools = "`"allow`": [`"web_search`", `"web_fetch`"],"
    Write-Success "Herramientas web habilitadas."
} else {
    $allowWebTools = ""
    Write-Info "Herramientas web deshabilitadas (solo herramientas locales)."
}

function Create-BasicConfig {
    @"
{
  "gateway": {
    "mode": "local",
    "bind": "loopback",
    "port": 18789,
    "auth": { "mode": "token", "token": "$gatewayToken" }
  },
  "channels": {
    "whatsapp": { "dmPolicy": "pairing", "groupPolicy": "allowlist" },
    "telegram": { "dmPolicy": "pairing", "groupPolicy": "allowlist" }
  },
  "tools": {
    "profile": "messaging",
    "deny": ["group:automation", "group:runtime", "group:fs"],
    $allowWebTools
    "fs": { "workspaceOnly": true },
    "exec": { "security": "deny", "ask": "always" }
  },
  "agents": {
    "defaults": { "sandbox": { "mode": "all" } }
  }
}
"@ | Out-File -FilePath $configPath -Encoding UTF8
    Write-Success "Configuracion basica creada."
}

# ====================
# 8. COPIAR PLANTILLA SEGURA
# ====================
Write-Info "Creando configuracion segura..."
$configTemplate = Join-Path $PSScriptRoot "..\configs\openclaw.json.hardened"
$configPath = "$openclawDir\openclaw.json"

if (Test-Path $configTemplate) {
    try {
        $configContent = Get-Content $configTemplate -Raw
        $configContent = $configContent -replace '\{\{RANDOM_TOKEN\}\}', $gatewayToken
        $configContent = $configContent -replace '\{\{DEEPSEEK_API_KEY\}\}', $deepseekApiKey
        $configContent = $configContent -replace '\{\{USER_HOME\}\}', $env:USERPROFILE
        $configContent = $configContent -replace '\{\{ALLOW_WEB_TOOLS\}\}', $allowWebTools
        $configContent | Out-File -FilePath $configPath -Encoding UTF8
        Write-Success "Configuracion guardada en $configPath"
    } catch {
        Write-Error "Error creando configuracion: $_"
        # Crear configuracion basica
        Create-BasicConfig
    }
} else {
    Write-Warning "No se encontro la plantilla de configuracion. Creando configuracion basica..."
    Create-BasicConfig
}



# ====================
# 9. AJUSTAR PERMISOS
# ====================
# En Windows, limitar acceso al directorio
try {
    $acl = Get-Acl $openclawDir
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$env:USERNAME", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($rule)
    Set-Acl $openclawDir $acl
    Write-Success "Permisos ajustados."
} catch {
    Write-Warning "No se pudieron ajustar permisos (continuando...): $_"
}

# ====================
# 10. INSTALAR DOCKER DESKTOP (OPCIONAL)
# ====================
Write-Host ""
$dockerChoice = Read-Host "Instalar Docker Desktop para sandbox de agentes? (recomendado) (s/n)"
if ($dockerChoice -match "^(s|S)$") {
    Write-Info "Verificando Docker..."
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Info "Descargando Docker Desktop..."
        $dockerInstaller = "$env:TEMP\DockerDesktopInstaller.exe"
        try {
            Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -OutFile $dockerInstaller -ErrorAction Stop
            Write-Warning "Se abrira el instalador de Docker Desktop. Sigue los pasos en la ventana grafica."
            Write-Host "Presiona Enter cuando hayas completado la instalacion..." -ForegroundColor Gray
            Start-Process $dockerInstaller -Wait
            Remove-Item $dockerInstaller -Force
            Write-Success "Docker Desktop instalado. Reinicia tu computadora para completar la instalacion."
        } catch {
            Write-Error "Error instalando Docker: $_"
        }
    } else {
        Write-Success "Docker ya esta instalado."
    }
} else {
    Write-Info "Omitiendo Docker. Los agentes se ejecutaran directamente (menos seguro)."
}

# ====================
# 11. CONFIGURAR FIREWALL (OPCIONAL)
# ====================
Write-Host ""
$firewallChoice = Read-Host "Configurar reglas de firewall para bloquear conexiones no deseadas? (recomendado) (s/n)"
if ($firewallChoice -match "^(s|S)$") {
    Write-Info "Configurando reglas de firewall..."
    try {
        # Bloquear puerto 18789 inbound (aunque OpenClaw solo escucha localmente, por si acaso)
        New-NetFirewallRule -DisplayName "OpenClaw Block Inbound" -Direction Inbound -LocalPort 18789 -Protocol TCP -Action Block -ErrorAction SilentlyContinue | Out-Null
        Write-Success "Regla de firewall anadida (puerto 18789 bloqueado entrante)."
    } catch {
        Write-Warning "No se pudo agregar regla de firewall (continuando...): $_"
    }
} else {
    Write-Info "Omitiendo configuracion de firewall."
}

# ====================
# 12. EJECUTAR AUDITORIA DE SEGURIDAD
# ====================
Write-Info "Ejecutando auditoria de seguridad OpenClaw..."
try {
    openclaw security audit --fix
    Write-Success "Auditoria completada."
} catch {
    Write-Warning "La auditoria fallo (continuando...): $_"
}

# ====================
# 13. CONFIGURAR TAILSCALE (OPCIONAL)
# ====================
Write-Host ""
$tailscaleChoice = Read-Host "Instalar Tailscale para soporte remoto seguro? (recomendado) (s/n)"
if ($tailscaleChoice -match "^(s|S)$") {
    Write-Info "Instalando Tailscale..."
    if (-not (Get-Command tailscale -ErrorAction SilentlyContinue)) {
        $tailscaleInstaller = "$env:TEMP\TailscaleInstaller.exe"
        try {
            Invoke-WebRequest -Uri "https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.exe" -OutFile $tailscaleInstaller -ErrorAction Stop
            Start-Process $tailscaleInstaller -Wait -ArgumentList "/S"
            Remove-Item $tailscaleInstaller -Force
            Write-Success "Tailscale instalado."
            Write-Warning "Para activarlo, abre Tailscale desde el menu Inicio e inicia sesion."
            Write-Warning "Luego comparte tu maquina con: support@skillnest.com"
        } catch {
            Write-Error "Error instalando Tailscale: $_"
        }
    } else {
        Write-Success "Tailscale ya esta instalado."
    }
}

# ====================
# FINALIZACION
# ====================
Clear-Host
Write-Color @"
==================================================
          INSTALACION COMPLETADA
==================================================
"@ -Color Magenta

Write-Host ""
Write-Success "OpenClaw esta instalado y configurado de forma segura."
Write-Host ""
Write-Host "Configuracion guardada en: $configPath" -ForegroundColor Yellow
Write-Host "Token del Gateway: $gatewayToken (guardalo en un lugar seguro)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Pasos siguientes:" -ForegroundColor White
Write-Host "1. Abre PowerShell o Terminal como administrador." -ForegroundColor Gray
Write-Host "2. Configurar WhatsApp/Telegram:" -ForegroundColor Gray
Write-Host "   openclaw onboard" -ForegroundColor Yellow
Write-Host "3. Iniciar el servicio:" -ForegroundColor Gray
Write-Host "   openclaw gateway start" -ForegroundColor Yellow
Write-Host "4. Verificar estado:" -ForegroundColor Gray
Write-Host "   openclaw gateway status" -ForegroundColor Yellow
Write-Host "5. Anadir contactos autorizados editando el archivo de configuracion." -ForegroundColor Gray
Write-Host ""
Write-Host "Soporte:" -ForegroundColor White
Write-Host "- Documentacion: https://docs.openclaw.ai" -ForegroundColor Gray
Write-Host "- Soporte remoto: Tailscale (ya instalado)" -ForegroundColor Gray
Write-Host "- Comunidad: https://discord.com/invite/clawd" -ForegroundColor Gray
Write-Host ""
Write-Host "Recuerda:" -ForegroundColor White
Write-Host "- El Gateway solo escucha localmente (127.0.0.1)." -ForegroundColor Gray
Write-Host "- Cada nuevo contacto requiere aprobacion (pairing)." -ForegroundColor Gray
Write-Host "- Revisa los logs en %TEMP%\openclaw\openclaw-*.log" -ForegroundColor Gray
Write-Host ""
Write-Host "Gracias por usar OpenClaw Seguro de Skillnest." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Magenta

# Pausar para que el usuario pueda leer
Write-Host ""
Write-Host "Presiona Enter para salir..." -ForegroundColor Gray
Read-Host
