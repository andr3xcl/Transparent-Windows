# WindowTransparency.ps1
# Este script se ejecuta en segundo plano para aplicar la transparencia a las ventanas.

# --- INICIO: Definiciones de la API de Windows ---
# Se necesita una definición más amplia para la nueva funcionalidad
try {
    $code = @"
using System;
    using System.Text;
using System.Runtime.InteropServices;

    public static class WindowUtils {
        // Para obtener la ventana en primer plano (con foco)
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();

        // Para enumerar todas las ventanas
    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);
    
        // Para obtener el ID del proceso de una ventana
        [DllImport("user32.dll", SetLastError = true)]
        public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
    
        // Para verificar si una ventana es visible
    [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool IsWindowVisible(IntPtr hWnd);
    
        // Para obtener el handle del escritorio
    [DllImport("user32.dll")]
    public static extern IntPtr GetShellWindow();
    
        // Para manejar los estilos de ventana (necesario para la transparencia)
    [DllImport("user32.dll")]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
    
    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
    
    [DllImport("user32.dll")]
    public static extern bool SetLayeredWindowAttributes(IntPtr hWnd, uint crKey, byte bAlpha, uint dwFlags);
    
        // Constantes para los estilos de ventana
    public const int GWL_EXSTYLE = -20;
    public const int WS_EX_LAYERED = 0x80000;
    public const int LWA_ALPHA = 0x2;
    
        // Delegado para la función de callback de EnumWindows
        public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    }
"@
    Add-Type -TypeDefinition $code -Language CSharp
} catch {
    Write-Output "Error al cargar las APIs de Windows: $_"
    # Si falla la carga, no podemos continuar.
    exit
}
# --- FIN: Definiciones de la API de Windows ---


# --- INICIO: Funciones de Ayuda ---

# Nueva función para verificar si una ventana está excluida
function Is-WindowExcluded {
    param(
        [IntPtr]$hWnd,
        [array]$exclusions,
        [hashtable]$cachedProcesses
    )
    
    $processId = 0
    [WindowUtils]::GetWindowThreadProcessId($hWnd, [ref]$processId) | Out-Null
    
    if ($processId -eq 0) {
        return $false # Sin ID de proceso, no se puede excluir
    }

    # Usar cache para el nombre del proceso
    if (-not $cachedProcesses.ContainsKey($processId)) {
        try {
            $processName = (Get-Process -Id $processId -ErrorAction SilentlyContinue).ProcessName.ToLower()
            $cachedProcesses[$processId] = $processName
        } catch { 
            $cachedProcesses[$processId] = $null 
        }
    }

    $processName = $cachedProcesses[$processId]

    if ($processName -and ($exclusions -contains $processName)) {
        return $true
    }
    
    return $false
}

# Función para aplicar transparencia a un handle de ventana específico
function Set-WindowTransparent($hWnd, $alpha) {
    try {
        $currentExStyle = [WindowUtils]::GetWindowLong($hWnd, [WindowUtils]::GWL_EXSTYLE)
        # Aplicar el estilo WS_EX_LAYERED si no lo tiene
        if (($currentExStyle -band [WindowUtils]::WS_EX_LAYERED) -eq 0) {
            [WindowUtils]::SetWindowLong($hWnd, [WindowUtils]::GWL_EXSTYLE, $currentExStyle -bor [WindowUtils]::WS_EX_LAYERED) | Out-Null
        }
        # Aplicar el nivel de transparencia
        [WindowUtils]::SetLayeredWindowAttributes($hWnd, 0, [byte]$alpha, [WindowUtils]::LWA_ALPHA) | Out-Null
    } catch {
        # Ignorar errores, pueden ocurrir con ventanas del sistema
    }
}

# Función para restaurar la opacidad completa de un handle de ventana específico
function Restore-WindowOpaque($hWnd) {
    try {
        $currentExStyle = [WindowUtils]::GetWindowLong($hWnd, [WindowUtils]::GWL_EXSTYLE)
        # Si la ventana es transparente (tiene el estilo), se lo quitamos
        if (($currentExStyle -band [WindowUtils]::WS_EX_LAYERED) -ne 0) {
            $newExStyle = $currentExStyle -bxor [WindowUtils]::WS_EX_LAYERED
            [WindowUtils]::SetWindowLong($hWnd, [WindowUtils]::GWL_EXSTYLE, $newExStyle) | Out-Null
            
            # Forzar un redibujado para que el cambio sea visible
            # Esto a veces es necesario para que Windows actualice la apariencia
            # No hay un método directo y seguro en PowerShell, pero quitar el estilo suele ser suficiente.
        }
    } catch {
        # Ignorar errores
    }
}

# --- FIN: Funciones de Ayuda ---


# --- INICIO: Bucle Principal ---

$settingsPath = Join-Path $env:TEMP "WindowTransparencySettings.xml"
$exclusionsPath = Join-Path $env:TEMP "WindowTransparencyExclusions.xml"
$flagFilePath = Join-Path $env:TEMP "WindowTransparencyActive.flag"

# Crear el archivo indicador para que la UI sepa que estamos activos
New-Item -Path $flagFilePath -ItemType File -Force | Out-Null

# Variables para guardar el estado anterior y optimizar
$lastFocusedHwnd = [IntPtr]::Zero
$cachedProcesses = @{} # Cache para no llamar a Get-Process constantemente

Write-Output "Proceso de transparencia iniciado. Monitoreando cambios..."

while (Test-Path $flagFilePath) {
    try {
        # --- Cargar configuración en cada ciclo ---
        $settings = if (Test-Path $settingsPath) { Import-Clixml -Path $settingsPath } else { @{ TransparencyLevel = 220; TransparencyMode = 'Global' } }
        $exclusions = if (Test-Path $exclusionsPath) { Import-Clixml -Path $exclusionsPath } else { @() }
        
        $transparencyLevel = if ($settings.TransparencyLevel) { $settings.TransparencyLevel } else { 220 }
        $transparencyMode = if ($settings.TransparencyMode) { $settings.TransparencyMode } else { 'Global' }

        # --- Lógica principal ---
        if ($transparencyMode -eq 'Intelligent') {
            # --- MODO INTELIGENTE (Original): Ventanas sin foco se hacen transparentes ---
            $focusedHwnd = [WindowUtils]::GetForegroundWindow()

            if ($focusedHwnd -ne $lastFocusedHwnd) {
                # Hacer la última ventana transparente, SI NO ESTÁ EXCLUIDA
                if ($lastFocusedHwnd -ne [IntPtr]::Zero) {
                    if (-not (Is-WindowExcluded -hWnd $lastFocusedHwnd -exclusions $exclusions -cachedProcesses $cachedProcesses)) {
                        Set-WindowTransparent -hWnd $lastFocusedHwnd -alpha $transparencyLevel
                    }
                }

                # La nueva ventana con foco siempre debe ser opaca, esté o no excluida
                Restore-WindowOpaque -hWnd $focusedHwnd
                
                $lastFocusedHwnd = $focusedHwnd
            }
        } elseif ($transparencyMode -eq 'Intelligent-Inverse') {
            # --- MODO INTELIGENTE (Inverso): Ventana con foco se hace transparente ---
            $focusedHwnd = [WindowUtils]::GetForegroundWindow()

            if ($focusedHwnd -ne $lastFocusedHwnd) {
                # La ventana que pierde el foco siempre debe ser opaca
                if ($lastFocusedHwnd -ne [IntPtr]::Zero) {
                    Restore-WindowOpaque -hWnd $lastFocusedHwnd
                }

                # Hacer la nueva ventana con foco transparente, SI NO ESTÁ EXCLUIDA
                if (-not (Is-WindowExcluded -hWnd $focusedHwnd -exclusions $exclusions -cachedProcesses $cachedProcesses)) {
                    Set-WindowTransparent -hWnd $focusedHwnd -alpha $transparencyLevel
                } else {
                    # Si está excluida, asegurarse de que sea opaca
                    Restore-WindowOpaque -hWnd $focusedHwnd
                }
                
                $lastFocusedHwnd = $focusedHwnd
            }
        } else {
            # --- MODO GLOBAL ---
            # Si cambiamos de modo, restauramos la última ventana con foco para limpiar el estado
            if ($lastFocusedHwnd -ne [IntPtr]::Zero) {
                Restore-WindowOpaque -hWnd $lastFocusedHwnd
                $lastFocusedHwnd = [IntPtr]::Zero
            }
            
            $callback = [WindowUtils+EnumWindowsProc] {
                param($hWnd, $lParam)
                
                if (([WindowUtils]::IsWindowVisible($hWnd)) -and ($hWnd -ne [WindowUtils]::GetShellWindow())) {
                    # Aplicar transparencia solo a las ventanas no excluidas
                    if (-not (Is-WindowExcluded -hWnd $hWnd -exclusions $exclusions -cachedProcesses $cachedProcesses)) {
                        Set-WindowTransparent -hWnd $hWnd -alpha $transparencyLevel
                    } else {
                        # Si una ventana está en la lista de exclusión, asegurarse de que sea opaca
                        Restore-WindowOpaque -hWnd $hWnd
                    }
                }
                return $true
            }
            [WindowUtils]::EnumWindows($callback, [IntPtr]::Zero)
        }

    } catch {
        Write-Output "Error en el bucle principal: $_"
    }

    # Limpiar el cache de procesos cada 10 segundos para detectar procesos cerrados/nuevos
    if ((Get-Date).Second % 10 -eq 0) {
        $cachedProcesses.Clear()
    }
    
    # Pausa corta para no consumir 100% de CPU
    Start-Sleep -Milliseconds 200
}

Write-Output "Archivo indicador no encontrado. Deteniendo proceso de transparencia."
# Cuando el bucle termina (porque se borró el archivo flag), el script finaliza. 