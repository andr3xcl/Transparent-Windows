@echo off
title Littlegods Utility Transparent Desktop

echo Iniciando Littlegods Utility Transparent Desktop...

:: Verificar que existe el script principal
if not exist "src\ui\TransparencyControl.ps1" (
    echo ERROR: No se encontro el archivo TransparencyControl.ps1
    pause
    exit /b 1
)

:: Obtener la ruta del script de PowerShell
set "ps_script=%~dp0src\ui\TransparencyControl.ps1"

:: Comprobar si se está ejecutando para autoarranque (silencioso)
if "%1"=="autostart" (
    echo Iniciando en modo autoarranque...
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File \"%ps_script%\"' -Verb RunAs -WindowStyle Hidden"
    goto :eof
)

:: Ejecución normal: mostrar logo primero
echo Mostrando logo de inicio...
set "logo_path=%~dp0assets\LogoApp.ico"
if exist "%logo_path%" (
    start /min powershell -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command "& { try { Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $logo = [System.Drawing.Image]::FromFile('%logo_path%'); $form = New-Object System.Windows.Forms.Form; $form.StartPosition = 'CenterScreen'; $form.FormBorderStyle = 'None'; $form.ShowInTaskbar = $false; $form.TopMost = $true; $form.Width = $logo.Width; $form.Height = $logo.Height; $form.BackgroundImage = $logo; $form.Show(); Start-Sleep -Seconds 2; $form.Close(); $form.Dispose(); $logo.Dispose(); } catch { } }"
) else (
    echo Advertencia: No se encontro el logo en %logo_path%
)

:: Esperar un momento y luego iniciar la aplicación principal
timeout /t 1 /nobreak >nul
echo Iniciando aplicacion principal...
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -NoProfile -File \"%ps_script%\"' -Verb RunAs"

echo Aplicacion iniciada. Busca el icono en la bandeja del sistema.
timeout /t 3 /nobreak >nul

:eof