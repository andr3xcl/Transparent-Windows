# ShellEffects.ps1
# Script para controlar los efectos de transparencia globales del Shell de Windows (Menú Inicio, Panel de Notificaciones, etc.).

function Set-GlobalShellTransparency {
    <#
    .SYNOPSIS
    Habilita o deshabilita la configuración de transparencia global en Windows.

    .PARAMETER Enable
    $true para habilitar la transparencia, $false para deshabilitarla.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [bool]$Enable
    )

    $registryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $valueName = "EnableTransparency"
    $value = if ($Enable) { 1 } else { 0 }

    # Asegurarse de que la ruta del registro exista.
    if (-not (Test-Path $registryPath)) {
        try {
            New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
        } catch {
            Write-Warning "No se pudo crear la clave del registro: $registryPath. Error: $_"
            return
        }
    }

    # Establecer el valor del registro (DWORD).
    try {
        Set-ItemProperty -Path $registryPath -Name $valueName -Value $value -Type DWord -Force -ErrorAction Stop
        Write-Host "Transparencia global del Shell establecida a: $Enable"
    } catch {
        Write-Warning "No se pudo establecer el valor del registro. Ejecuta el script como administrador si el problema persiste. Error: $_"
    }
}

function Get-GlobalShellTransparency {
    <#
    .SYNOPSIS
    Comprueba si la configuración de transparencia global de Windows está habilitada.

    .RETURNS
    $true si está habilitada, $false si no.
    #>
    $registryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $valueName = "EnableTransparency"

    try {
        # Si la clave o el valor no existen, se considera deshabilitada.
        if (Test-Path $registryPath) {
            $property = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue
            if ($null -ne $property) {
                return [bool]$property.$valueName
            }
        }
    } catch {
        # Cualquier error se interpreta como que está deshabilitado.
    }

    return $false # Valor predeterminado si no se encuentra la clave/valor.
} 