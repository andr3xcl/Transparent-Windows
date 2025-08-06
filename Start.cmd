@echo off
title Littlegods Utility Transparent Desktop

:: Obtener la ruta del script de PowerShell
set "ps_script=%~dp0src\ui\TransparencyControl.ps1"

:: Comando para iniciar el script de PowerShell en segundo plano
set "start_ps_command=Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File ""%ps_script%""' -Verb RunAs -WindowStyle Hidden"

:: Comprobar si se está ejecutando para autoarranque (silencioso)
if "%1"=="autostart" (
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "%start_ps_command%"
    goto :eof
)

:: Ejecución normal: iniciar script y mostrar logo
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "%start_ps_command%"

:: Mostrar el logo (splash screen) - versión simplificada
set "logo_path=%~dp0assets\LogoApp.ico"
powershell -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command "& { try { Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $logo = [System.Drawing.Image]::FromFile('%logo_path%'); $form = New-Object System.Windows.Forms.Form; $form.StartPosition = 'CenterScreen'; $form.FormBorderStyle = 'None'; $form.ShowInTaskbar = $false; $form.TopMost = $true; $form.Width = $logo.Width; $form.Height = $logo.Height; $form.BackgroundImage = $logo; $form.Show(); Start-Sleep -Seconds 2; $form.Close(); $form.Dispose(); $logo.Dispose(); } catch { Write-Host 'Error mostrando logo: $_' } }"

:eof 