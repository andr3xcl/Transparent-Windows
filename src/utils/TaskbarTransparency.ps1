# TaskbarTransparency.ps1
# Script para controlar la transparencia de la barra de tareas de Windows.

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class TaskbarManager {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll")]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

    [DllImport("user32.dll")]
    public static extern bool SetLayeredWindowAttributes(IntPtr hWnd, uint crKey, byte bAlpha, uint dwFlags);
    
    public const int GWL_EXSTYLE = -20;
    public const int WS_EX_LAYERED = 0x80000;
    public const int LWA_ALPHA = 0x2;
}
"@

function Set-TaskbarTransparency {
    param(
        [Parameter(Mandatory=$true)]
        [int]$Alpha
    )

    if ($Alpha -lt 0) { $Alpha = 0 }
    if ($Alpha -gt 255) { $Alpha = 255 }

    $taskbarHandle = [TaskbarManager]::FindWindow("Shell_TrayWnd", $null)
    if ($taskbarHandle -eq [IntPtr]::Zero) {
        Write-Warning "No se pudo encontrar el handle de la barra de tareas (Shell_TrayWnd)."
        return
    }

    $currentExStyle = [TaskbarManager]::GetWindowLong($taskbarHandle, [TaskbarManager]::GWL_EXSTYLE)
    [void][TaskbarManager]::SetWindowLong($taskbarHandle, [TaskbarManager]::GWL_EXSTYLE, $currentExStyle -bor [TaskbarManager]::WS_EX_LAYERED)
    [void][TaskbarManager]::SetLayeredWindowAttributes($taskbarHandle, 0, [byte]$Alpha, [TaskbarManager]::LWA_ALPHA)
}

function Restore-TaskbarOpacity {
    $taskbarHandle = [TaskbarManager]::FindWindow("Shell_TrayWnd", $null)
    if ($taskbarHandle -eq [IntPtr]::Zero) {
        return
    }
    
    # Simplemente la devolvemos a completamente opaca.
    [void][TaskbarManager]::SetLayeredWindowAttributes($taskbarHandle, 0, 255, [TaskbarManager]::LWA_ALPHA)
    
    # Y quitamos el estilo "layered" para una restauración completa.
    $currentExStyle = [TaskbarManager]::GetWindowLong($taskbarHandle, [TaskbarManager]::GWL_EXSTYLE)
    $newExStyle = $currentExStyle -bxor [TaskbarManager]::WS_EX_LAYERED
    [void][TaskbarManager]::SetWindowLong($taskbarHandle, [TaskbarManager]::GWL_EXSTYLE, $newExStyle)
} 