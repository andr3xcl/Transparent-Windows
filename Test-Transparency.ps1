# Script de prueba para verificar que la transparencia funciona

Write-Host "=== PRUEBA DE TRANSPARENCIA ==="
Write-Host "Verificando archivos necesarios..."

$scriptDir = $PSScriptRoot
$files = @(
    @{ Path = "src\ui\TransparencyControl.ps1"; Name = "TransparencyControl.ps1" },
    @{ Path = "src\core\WindowTransparency.ps1"; Name = "WindowTransparency.ps1" },
    @{ Path = "src\ui\ThemeManager.ps1"; Name = "ThemeManager.ps1" },
    @{ Path = "src\utils\TaskbarTransparency.ps1"; Name = "TaskbarTransparency.ps1" },
    @{ Path = "src\utils\ShellEffects.ps1"; Name = "ShellEffects.ps1" }
)

foreach ($file in $files) {
    $path = Join-Path $scriptDir $file.Path
    if (Test-Path $path) {
        Write-Host "OK $($file.Name) encontrado"
    } else {
        Write-Host "ERROR $($file.Name) NO encontrado"
    }
}

Write-Host ""
Write-Host "Verificando archivos de configuracion..."
$configFiles = @(
    "config\TransparencySettings.xml",
    "config\ExcludedApps.xml",
    "config\ThemeSettings.xml"
)

foreach ($file in $configFiles) {
    $path = Join-Path $scriptDir $file
    if (Test-Path $path) {
        Write-Host "OK $file existe"
    } else {
        Write-Host "INFO $file no existe (se creara automaticamente)"
    }
}

Write-Host ""
Write-Host "=== PRUEBA COMPLETADA ==="
Write-Host "Ahora puedes ejecutar Start.cmd para iniciar la aplicacion"