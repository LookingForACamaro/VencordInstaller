<#
.SYNOPSIS
    Automates Vencord installation and Discord restart.

.DESCRIPTION
    This script performs the following actions sequentially:
    1. Closes the Discord process if active.
    2. Downloads the latest Vencord CLI installer from GitHub to the temporary folder.
    3. Runs the installer and pauses the script until the installer window is closed.
    4. Cleans up the downloaded temporary files.
    5. Restarts the Discord application.

.NOTES
    Author      : Richard Black
    Date        : 07/12/2025
    Version     : 1.0
    Requirements: Internet connection, Discord installed in standard path (%LocalAppData%).

.EXAMPLE
    .\Install-Vencord.ps1
#>

# --- CONFIGURATION ---
param(
    [Parameter(Mandatory = $false, HelpMessage = "URL to download the Vencord CLI installer.")]
    [string]$Url = "https://github.com/Vencord/Installer/releases/latest/download/VencordInstallerCli.exe",

    [Parameter(Mandatory = $false, HelpMessage = "Path where the file is temporarily saved.")]
    [string]$TempInstallerPath = (Join-Path $env:TEMP "VencordInstallerCli.exe"),
    
    [Parameter(Mandatory = $false, HelpMessage = "Path to the Discord update executable.")]
    [string]$DiscordLauncher = "$env:LocalAppData\Discord\Update.exe"
)

# Force console to use UTF-8 encoding (good practice for special chars/icons)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Stop script immediately on errors (Fail Fast)
$ErrorActionPreference = "Stop"

# Disable the noisy blue progress bar banner
$ProgressPreference = "SilentlyContinue"

# --- UTILITY FUNCTIONS ---
function Write-Step {
    param([string]$Message)
    Write-Host "[*] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor Red
}

# --- START SCRIPT ---

Clear-Host
Write-Host "--- Vencord Automation ---" -ForegroundColor Magenta
Write-Host ""
Write-Host "Current Configuration:" -ForegroundColor DarkGray
Write-Host "  Installer URL: $Url" -ForegroundColor DarkGray
Write-Host "  Local Path: $TempInstallerPath" -ForegroundColor DarkGray
Write-Host "  Discord Launcher: $DiscordLauncher" -ForegroundColor DarkGray
Write-Host ""

try {
    # 1. Close Discord
    Write-Step "Checking Discord status..."
    $discordProcess = Get-Process -Name "Discord" -ErrorAction SilentlyContinue

    if ($discordProcess) {
        Stop-Process -Name "Discord" -Force
        Write-Success "Discord closed successfully."
    }
    else {
        Write-Host "Discord is not running. Proceeding..." -ForegroundColor DarkGray
    }

    # 2. Download Vencord
    Write-Step "Downloading Vencord CLI installer..."
    try {
        Invoke-WebRequest -Uri $Url -OutFile $TempInstallerPath -UseBasicParsing
        Write-Success "Download complete."
    }
    catch {
        Write-ErrorMsg "A download failure occurred. Please check your internet connection or the URL."
        throw $_
    }

    # 3. Run Installer
    Write-Step "Launching Vencord installer. Please follow instructions in the new window."
    Write-Host "    (The script will resume once the installer closes)" -ForegroundColor Yellow
    
    # Start-Process with -Wait pauses the script until the user closes the installer window
    Start-Process -FilePath $TempInstallerPath -Wait

    Write-Success "Installation finished (Vencord process closed)."

    # 4. Cleanup
    if (Test-Path $TempInstallerPath) {
        Remove-Item $TempInstallerPath -Force
        Write-Host "Temporary installer file deleted." -ForegroundColor DarkGray
    }

    # 5. Restart Discord
    Write-Step "Restarting Discord..."
    
    if (Test-Path $DiscordLauncher) {
        # Launch via Update.exe to ensure the correct version starts
        Start-Process -FilePath $DiscordLauncher -ArgumentList "--processStart Discord.exe"
        Write-Success "Discord is restarting!"
    }
    else {
        Write-ErrorMsg "Discord executable not found at standard location:"
        Write-ErrorMsg "$DiscordLauncher"
        Write-Host "Please start Discord manually." -ForegroundColor Yellow
    }

}
catch {
    Write-Host ""
    Write-ErrorMsg "A critical error occurred:"
    Write-ErrorMsg $_.Exception.Message
}
finally {
    Write-Host ""
    Write-Host "--- End of script ---" -ForegroundColor Magenta
}