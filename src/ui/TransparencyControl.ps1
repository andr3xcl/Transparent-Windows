# TransparencyControl.ps1
# Script con interfaz gráfica para controlar la transparencia de ventanas

# --- Mutex para asegurar una sola instancia ---
# Se crea un "identificador" único en el sistema.
$mutexName = "Global\WindowTransparencyControlApp-LittleGods"
$createdNew = $false
# Se intenta crear el Mutex. Si ya existe, $createdNew será $false.
$script:singleInstanceMutex = New-Object System.Threading.Mutex($true, $mutexName, ([ref]$createdNew))

if (-not $createdNew) {
    # Si el Mutex ya existía, se muestra un mensaje y se sale.
    # Cargar ensamblados necesarios para mostrar el mensaje
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "La aplicación ya se encuentra en ejecución. Búscala en el icono de la bandeja del sistema.", 
        "Proceso ya activo", 
        [System.Windows.Forms.MessageBoxButtons]::OK, 
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
    exit
}

# --- INICIO: Función para actualizar la UI del estado del proceso ---
function Update-ProcessStateUI {
    $lang = $translations[$themeSettings.Language]
    $isRunning = Test-Path $flagFilePath

    $btnStart.Enabled = -not $isRunning
    $btnStop.Enabled = $isRunning

    if ($isRunning) {
        $menuItemToggle.Text = $lang.toggleTransparencyMenu_Stop
    } else {
        $menuItemToggle.Text = $lang.toggleTransparencyMenu_Start
    }
}
# --- FIN: Función para actualizar la UI del estado del proceso ---

# Eliminar la siguiente línea, es la causa de la corrupción de archivos XML
# $OutputEncoding = [System.Text.Encoding]::UTF8

# Cargar ensamblados necesarios para la interfaz gráfica
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# Cargar el gestor de temas
. (Join-Path $PSScriptRoot "ThemeManager.ps1")

# Cargar el gestor de transparencia de la barra de tareas
. (Join-Path $PSScriptRoot "..\utils\TaskbarTransparency.ps1")

# Cargar el gestor de efectos del Shell
. (Join-Path $PSScriptRoot "..\utils\ShellEffects.ps1")

# Cargar el gestor de perfiles
# . (Join-Path $PSScriptRoot "ProfileManager.ps1") # Eliminado

# --- INICIO: Diccionario de Traducciones ---
$translations = @{
    es = @{
        formTitle = "Control de Transparencia de Ventanas";
        transparencyLevelGroup = "Nivel de Transparencia";
        taskbarTransparencyGroup = "Nivel de transparencia (Barra de tareas)";
        applyButton = "Aplicar";
        shellEffectsGroup = "Efectos de Transparencia del Sistema";
        shellEffectsCheckbox = "Habilitar transparencia en Menú Inicio, Notificaciones, etc.";
        excludedAppsGroup = "Aplicaciones excluidas";
        runningProcessesLabel = "Procesos en ejecución:";
        addSelectedButton = "Añadir selección";
        updateButton = "Actualizar";
        processControlGroup = "Control del proceso";
        startButton = "Iniciar transparencia";
        stopButton = "Detener transparencia";
        autoStartCheckbox = "Iniciar automáticamente con Windows";
        themeAndFontGroup = "Configuración de Tema y Fuente";
        themeLabel = "Tema:";
        lightThemeRadio = "Claro";
        darkThemeRadio = "Oscuro";
        systemThemeRadio = "Sistema";
        fontLabel = "Fuente:";
        sizeLabel = "Tamaño:";
        languageLabel = "Idioma:";
        contactGroup = "Contacto";
        discordLink = "Discord: Andresito_20";
        githubLink = "GitHub: andr3xcl";
        authorLabel = "Autor: Andresito_20";
        versionLabel = "Versión: 1.5";
        rightsLabel = "Libre de derechos";
        sourceLabel = "Source code - Community";
        littlegodsUtilityLabel = "Littlegods Utility";
        trayIconText = "Control de Transparencia - LittleGods";
        showSettingsMenu = "Mostrar configuración";
        toggleTransparencyMenu_Stop = "Detener transparencia";
        toggleTransparencyMenu_Start = "Iniciar transparencia";
        exitMenu = "Salir";
        themeMenu = "Configurar tema y fuente";
        alreadyRunningTitle = "Proceso ya activo";
        alreadyRunningText = "La aplicación ya se encuentra en ejecución. Búscala en el icono de la bandeja del sistema.";
        manualProcessPlaceholder = "Nombre del proceso";
        # Nuevas traducciones para el modo inteligente
        transparencyModeGroup = "Modo de Transparencia";
        globalModeRadio = "Global (todas las ventanas)";
        intelligentModeRadio = "Inteligente (ventanas sin foco)";
        intelligentInverseModeRadio = "Inteligente (solo ventana con foco)";
    };
    en = @{
        formTitle = "Window Transparency Control";
        transparencyLevelGroup = "Transparency Level";
        taskbarTransparencyGroup = "Transparency Level (Taskbar)";
        applyButton = "Apply";
        shellEffectsGroup = "System Transparency Effects";
        shellEffectsCheckbox = "Enable transparency in Start Menu, Notifications, etc.";
        excludedAppsGroup = "Excluded Applications";
        runningProcessesLabel = "Running Processes:";
        addSelectedButton = "Add selection";
        updateButton = "Refresh";
        processControlGroup = "Process Control";
        startButton = "Start transparency";
        stopButton = "Stop transparency";
        autoStartCheckbox = "Start automatically with Windows";
        themeAndFontGroup = "Theme and Font Settings";
        themeLabel = "Theme:";
        lightThemeRadio = "Light";
        darkThemeRadio = "Dark";
        systemThemeRadio = "System";
        fontLabel = "Font:";
        sizeLabel = "Size:";
        languageLabel = "Language:";
        contactGroup = "Contact";
        discordLink = "Discord: Andresito_20";
        githubLink = "GitHub: andr3xcl";
        authorLabel = "Author: Andresito_20";
        versionLabel = "Version: 1.5";
        rightsLabel = "Rights-free";
        sourceLabel = "Source code - Community";
        littlegodsUtilityLabel = "Littlegods Utility";
        trayIconText = "Transparency Control - LittleGods";
        showSettingsMenu = "Show settings";
        toggleTransparencyMenu_Stop = "Stop transparency";
        toggleTransparencyMenu_Start = "Start transparency";
        exitMenu = "Exit";
        themeMenu = "Configure theme and font";
        alreadyRunningTitle = "Process already active";
        alreadyRunningText = "The application is already running. Look for it in the system tray icon.";
        manualProcessPlaceholder = "Process name";
        # New translations for intelligent mode
        transparencyModeGroup = "Transparency Mode";
        globalModeRadio = "Global (all windows)";
        intelligentModeRadio = "Intelligent (unfocused windows)";
        intelligentInverseModeRadio = "Intelligent (focused window only)";
    };
    pt = @{
        formTitle = "Controle de Transparência de Janelas";
        transparencyLevelGroup = "Nível de transparência";
        taskbarTransparencyGroup = "Nível de transparência (Barra de tarefas)";
        applyButton = "Aplicar";
        shellEffectsGroup = "Efeitos de Transparência do Sistema";
        shellEffectsCheckbox = "Ativar transparência no Menu Iniciar, Notificações, etc.";
        excludedAppsGroup = "Aplicações excluídas";
        runningProcessesLabel = "Processos em execução:";
        addSelectedButton = "Adicionar seleção";
        updateButton = "Atualizar";
        processControlGroup = "Controle do processo";
        startButton = "Iniciar transparência";
        stopButton = "Parar transparência";
        autoStartCheckbox = "Iniciar automaticamente com o Windows";
        themeAndFontGroup = "Configurações de Tema e Fonte";
        themeLabel = "Tema:";
        lightThemeRadio = "Claro";
        darkThemeRadio = "Escuro";
        systemThemeRadio = "Sistema";
        fontLabel = "Fonte:";
        sizeLabel = "Tamanho:";
        languageLabel = "Idioma:";
        contactGroup = "Contato";
        discordLink = "Discord: Andresito_20";
        githubLink = "GitHub: andr3xcl";
        authorLabel = "Autor: Andresito_20";
        versionLabel = "Versão: 1.5";
        rightsLabel = "Livre de direitos";
        sourceLabel = "Código fonte - Comunidade";
        littlegodsUtilityLabel = "Littlegods Utility";
        trayIconText = "Controle de Transparência - LittleGods";
        showSettingsMenu = "Mostrar configurações";
        toggleTransparencyMenu_Stop = "Parar transparência";
        toggleTransparencyMenu_Start = "Iniciar transparência";
        exitMenu = "Sair";
        themeMenu = "Configurar tema e fonte";
        alreadyRunningTitle = "Processo já ativo";
        alreadyRunningText = "A aplicação já está em execução. Procure-a no ícone da bandeja do sistema.";
        manualProcessPlaceholder = "Nome do processo";
        # Novas traduções para o modo inteligente
        transparencyModeGroup = "Modo de Transparência";
        globalModeRadio = "Global (todas as janelas)";
        intelligentModeRadio = "Inteligente (janelas sem foco)";
        intelligentInverseModeRadio = "Inteligente (apenas janela com foco)";
    };
    zh = @{
        formTitle = "窗口透明度控制";
        transparencyLevelGroup = "透明度级别";
        taskbarTransparencyGroup = "透明度级别（任务栏）";
        applyButton = "应用";
        shellEffectsGroup = "系统透明度效果";
        shellEffectsCheckbox = "在开始菜单、通知等中启用透明度";
        excludedAppsGroup = "排除的应用程序";
        runningProcessesLabel = "正在运行的进程：";
        addSelectedButton = "添加选择";
        updateButton = "刷新";
        processControlGroup = "进程控制";
        startButton = "启动透明度";
        stopButton = "停止透明度";
        autoStartCheckbox = "随Windows自动启动";
        themeAndFontGroup = "主题和字体设置";
        themeLabel = "主题：";
        lightThemeRadio = "浅色";
        darkThemeRadio = "深色";
        systemThemeRadio = "系统";
        fontLabel = "字体：";
        sizeLabel = "大小：";
        languageLabel = "语言：";
        contactGroup = "联系方式";
        discordLink = "Discord: Andresito_20";
        githubLink = "GitHub: andr3xcl";
        authorLabel = "作者：Andresito_20";
        versionLabel = "版本：1.5";
        rightsLabel = "免费使用";
        sourceLabel = "源代码 - 社区";
        littlegodsUtilityLabel = "Littlegods 实用工具";
        trayIconText = "透明度控制 - LittleGods";
        showSettingsMenu = "显示设置";
        toggleTransparencyMenu_Stop = "停止透明度";
        toggleTransparencyMenu_Start = "启动透明度";
        exitMenu = "退出";
        themeMenu = "配置主题和字体";
        alreadyRunningTitle = "进程已激活";
        alreadyRunningText = "应用程序已在运行。请在系统托盘图标中查找。";
        manualProcessPlaceholder = "进程名称";
        transparencyModeGroup = "透明度模式";
        globalModeRadio = "全局（所有窗口）";
        intelligentModeRadio = "智能（未聚焦窗口）";
        intelligentInverseModeRadio = "智能（仅聚焦窗口）";
    };
    ja = @{
        formTitle = "ウィンドウ透明度制御";
        transparencyLevelGroup = "透明度レベル";
        taskbarTransparencyGroup = "透明度レベル（タスクバー）";
        applyButton = "適用";
        shellEffectsGroup = "システム透明度効果";
        shellEffectsCheckbox = "スタートメニュー、通知などで透明度を有効にする";
        excludedAppsGroup = "除外されたアプリケーション";
        runningProcessesLabel = "実行中のプロセス：";
        addSelectedButton = "選択を追加";
        updateButton = "更新";
        processControlGroup = "プロセス制御";
        startButton = "透明度を開始";
        stopButton = "透明度を停止";
        autoStartCheckbox = "Windowsと一緒に自動起動";
        themeAndFontGroup = "テーマとフォント設定";
        themeLabel = "テーマ：";
        lightThemeRadio = "ライト";
        darkThemeRadio = "ダーク";
        systemThemeRadio = "システム";
        fontLabel = "フォント：";
        sizeLabel = "サイズ：";
        languageLabel = "言語：";
        contactGroup = "連絡先";
        discordLink = "Discord: Andresito_20";
        githubLink = "GitHub: andr3xcl";
        authorLabel = "作者：Andresito_20";
        versionLabel = "バージョン：1.5";
        rightsLabel = "権利フリー";
        sourceLabel = "ソースコード - コミュニティ";
        littlegodsUtilityLabel = "Littlegods ユーティリティ";
        trayIconText = "透明度制御 - LittleGods";
        showSettingsMenu = "設定を表示";
        toggleTransparencyMenu_Stop = "透明度を停止";
        toggleTransparencyMenu_Start = "透明度を開始";
        exitMenu = "終了";
        themeMenu = "テーマとフォントを設定";
        alreadyRunningTitle = "プロセスが既にアクティブ";
        alreadyRunningText = "アプリケーションは既に実行中です。システムトレイアイコンで確認してください。";
        manualProcessPlaceholder = "プロセス名";
        transparencyModeGroup = "透明度モード";
        globalModeRadio = "グローバル（すべてのウィンドウ）";
        intelligentModeRadio = "インテリジェント（フォーカスされていないウィンドウ）";
        intelligentInverseModeRadio = "インテリジェント（フォーカスされたウィンドウのみ）";
    };

}
# --- FIN: Diccionario de Traducciones ---

# Cargar las API de Windows necesarias para restaurar las ventanas
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class WindowOpacity {
    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);
    
    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern int GetClassName(IntPtr hWnd, System.Text.StringBuilder lpClassName, int nMaxCount);
    
    [DllImport("user32.dll")]
    public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);
    
    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);
    
    [DllImport("user32.dll")]
    public static extern IntPtr GetShellWindow();
    
    [DllImport("user32.dll")]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
    
    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
    
    [DllImport("user32.dll")]
    public static extern bool SetLayeredWindowAttributes(IntPtr hWnd, uint crKey, byte bAlpha, uint dwFlags);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
    
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    
    public const int GWL_EXSTYLE = -20;
    public const int WS_EX_LAYERED = 0x80000;
    public const int LWA_ALPHA = 0x2;
}
"@

# Ruta para el proceso en segundo plano
$scriptPath = Join-Path $PSScriptRoot "..\core\WindowTransparency.ps1"
$scriptPath = [System.IO.Path]::GetFullPath($scriptPath)

# Ruta del logo de la aplicación
$logoPath = Join-Path $PSScriptRoot "..\..\assets\LogoApp.ico"

# Archivo indicador para saber si el proceso está activo
$flagFilePath = Join-Path $env:TEMP "WindowTransparencyActive.flag"

# Archivo de configuración
$configFilePath = Join-Path $PSScriptRoot "..\..\config\TransparencySettings.xml"

# Archivo de exclusiones
$exclusionsFilePath = Join-Path $PSScriptRoot "..\..\config\ExcludedApps.xml"

# Nuevo: Archivo único para guardar el estado completo de la sesión
$stateFilePath = Join-Path $PSScriptRoot "..\..\config\LastState.xml"

# Valor predeterminado de transparencia (0-255, donde 0 es completamente transparente y 255 es opaco)
$script:transparencyLevel = 220
$script:taskbarTransparencyLevel = 255 # Nuevo: 255 por defecto (opaco)
$script:transparencyMode = 'Global' # Modo por defecto

# Lista de exclusiones
$excludedApps = @()

# Variable para el proceso en segundo plano
$backgroundProcess = $null

# Variables para el icono del system tray
$notifyIcon = $null
$contextMenu = $null
$form = $null

# Función para mejorar la visualización de los controles
function Enhance-ControlsVisibility {
    # Volver al modo de dibujo estándar para las listas
    $lbExclusions.DrawMode = [System.Windows.Forms.DrawMode]::Normal
    $lbRunningProcesses.DrawMode = [System.Windows.Forms.DrawMode]::Normal
    
    # Establecer colores de manera directa
    $colors = Get-ThemeColors
    $lbExclusions.BackColor = $colors.ListBoxBackColor
    $lbExclusions.ForeColor = $colors.ListBoxForeColor
    $lbRunningProcesses.BackColor = $colors.ListBoxBackColor
    $lbRunningProcesses.ForeColor = $colors.ListBoxForeColor
}

# Función para forzar la actualización de datos en las listas
function Force-ListsRefresh {
    # Para aplicaciones excluidas
    $lbExclusions.BeginUpdate()
    $lbExclusions.Items.Clear()
    foreach ($app in $script:excludedApps) {
        [void]$lbExclusions.Items.Add($app)
    }
    $lbExclusions.EndUpdate()
    $lbExclusions.Refresh()
    
    # Para procesos en ejecución
    $lbRunningProcesses.BeginUpdate()
    $lbRunningProcesses.Items.Clear()
    $processes = Get-RunningProcesses
    foreach ($process in $processes) {
        [void]$lbRunningProcesses.Items.Add($process)
    }
    $lbRunningProcesses.EndUpdate()
    $lbRunningProcesses.Refresh()
    
    Write-Host "Listas actualizadas: $($lbExclusions.Items.Count) exclusiones, $($lbRunningProcesses.Items.Count) procesos"
}

# Función para cargar la configuración
function Load-Settings {
    if (Test-Path $configFilePath) {
        try {
            $config = Import-Clixml -Path $configFilePath
            $script:transparencyLevel = $config.TransparencyLevel
            # Cargar nuevo valor, con valor por defecto si no existe
            $script:taskbarTransparencyLevel = if ($config.TaskbarTransparencyLevel) { $config.TaskbarTransparencyLevel } else { 255 }
            # Cargar modo de transparencia
            $script:transparencyMode = if ($config.TransparencyMode) { $config.TransparencyMode } else { 'Global' }
            
            Write-Host "Configuración cargada: Nivel=$($script:transparencyLevel), Modo=$($script:transparencyMode)"
            
            # Aplicar transparencia de la barra de tareas al cargar
            Set-TaskbarTransparency -Alpha $script:taskbarTransparencyLevel

        } catch {
            Write-Warning "Error al cargar la configuración: $_"
        }
    } else {
        # Valores por defecto si no existe configuración
        $script:transparencyMode = 'Global'
        Write-Host "Usando configuración por defecto: Nivel=$($script:transparencyLevel), Modo=$($script:transparencyMode)"
    }
    
    # Cargar la lista de exclusiones (VERSIÓN ROBUSTA)
    if (Test-Path $exclusionsFilePath) {
        try {
            $loadedExclusions = Import-Clixml -Path $exclusionsFilePath
            # La clave está aquí: nos aseguramos de que $script:excludedApps sea SIEMPRE un array.
            # Si $loadedExclusions es un solo objeto (string), @() lo convierte en un array con ese objeto.
            # Si ya es un array, no le hace nada.
            $script:excludedApps = @($loadedExclusions)
        } catch {
            Write-Warning "Error al cargar la lista de exclusiones: $_. Se creará una nueva."
            $script:excludedApps = @() # Empezar con un array vacío si hay error
        }
    } else {
        $script:excludedApps = @() # Empezar con un array vacío si no existe el archivo
    }
}

# Función para refrescar las dos listas (exclusiones y procesos en ejecución)
function Refresh-Lists {
    # 1. Actualizar lista de aplicaciones excluidas
    $lbExclusions.BeginUpdate()
            $lbExclusions.Items.Clear()
    if ($null -ne $script:excludedApps) {
        foreach ($app in $script:excludedApps | Sort-Object) {
            [void]$lbExclusions.Items.Add($app)
        }
    }
    $lbExclusions.EndUpdate()
    
    # 2. Actualizar lista de procesos en ejecución (de forma inteligente)
    $allProcesses = Get-RunningProcesses
    # Filtrar los procesos que ya están en la lista de exclusiones
    $processesToShow = $allProcesses | Where-Object { $script:excludedApps -notcontains $_ }

    $lbRunningProcesses.BeginUpdate()
    $lbRunningProcesses.Items.Clear()
    foreach ($process in $processesToShow) {
        [void]$lbRunningProcesses.Items.Add($process)
    }
    $lbRunningProcesses.EndUpdate()
    
    $excludedCount = if ($null -eq $script:excludedApps) { 0 } else { $script:excludedApps.Count }
    Write-Host "Listas actualizadas: $excludedCount exclusiones, $($processesToShow.Count) procesos mostrados"
}

# Función para guardar la configuración
function Save-Settings {
    try {
        $config = @{
            TransparencyLevel = $script:transparencyLevel
            TaskbarTransparencyLevel = $script:taskbarTransparencyLevel
            TransparencyMode = $script:transparencyMode
        }
        Export-Clixml -Path $configFilePath -InputObject $config -Force
        Write-Host "Configuración guardada correctamente"
    } catch {
        Write-Warning "Error al guardar la configuración: $_"
    }
}

# Función para guardar el estado completo de la aplicación
function Save-State {
    try {
        # Guardar configuración principal
        $config = @{
            TransparencyLevel = $script:transparencyLevel
            TaskbarTransparencyLevel = $script:taskbarTransparencyLevel
            TransparencyMode = $script:transparencyMode
        }
        Export-Clixml -Path $configFilePath -InputObject $config -Force
        
        # Guardar exclusiones
        $exclusionsToSave = @($script:excludedApps)
        Export-Clixml -Path $exclusionsFilePath -InputObject $exclusionsToSave -Force
        
        # Actualizar configuración del script de transparencia
        Update-TransparencySettings
        Update-ExclusionSettings
        
        Write-Host "Estado completo guardado correctamente"
    } catch {
        Write-Warning "Error al guardar el estado: $_"
    }
}

# Función para guardar la lista de exclusiones (VERSIÓN ROBUSTA)
function Save-Exclusions {
    try {
        # Nos aseguramos de que lo que guardamos es SIEMPRE un array, incluso si está vacío o tiene un solo elemento.
        # Creamos un nuevo array explícitamente desde los elementos de la lista en memoria.
        $exclusionsToSave = @($script:excludedApps)
        Export-Clixml -Path $exclusionsFilePath -InputObject $exclusionsToSave -Force
        
        # Actualizar la configuración del script de transparencia en segundo plano
        Update-ExclusionSettings
        
        # Guardar el estado completo de la aplicación
        Save-State
    } catch {
        Write-Warning "Error al guardar la lista de exclusiones: $_"
    }
}

# Función para actualizar el nivel de transparencia en el script en ejecución
function Update-TransparencySettings {
    # Crear o actualizar el archivo de configuración que lee el script principal
    $settingsPath = Join-Path $env:TEMP "WindowTransparencySettings.xml"
    $settings = @{
        TransparencyLevel = $script:transparencyLevel
        TransparencyMode = $script:transparencyMode
    }
    Export-Clixml -Path $settingsPath -InputObject $settings -Force
    Write-Host "Configuración de transparencia actualizada: Nivel=$($script:transparencyLevel), Modo=$($script:transparencyMode)"
    
    # Si hay ventanas ya transparentes, actualizar su nivel de transparencia
    Update-ExistingWindowsTransparency
}

# Función para actualizar la lista de exclusiones en el script en ejecución
function Update-ExclusionSettings {
    # Crear o actualizar el archivo de exclusiones que lee el script principal
    $exclusionsPath = Join-Path $env:TEMP "WindowTransparencyExclusions.xml"
    Export-Clixml -Path $exclusionsPath -InputObject $script:excludedApps -Force
    
    # Restaurar inmediatamente la opacidad de las ventanas recién excluidas
    Restore-ExcludedWindowsOpacity
}

# Función para restaurar la opacidad de las ventanas excluidas
function Restore-ExcludedWindowsOpacity {
    if ($script:excludedApps.Count -eq 0) {
        return
    }

    Write-Host "Restaurando opacidad de ventanas excluidas..."
    
    $callback = [WindowOpacity+EnumWindowsProc] {
        param([IntPtr]$hwnd, [IntPtr]$lParam)
        
        # Ignorar ventanas invisibles y el escritorio
        if ([WindowOpacity]::IsWindowVisible($hwnd) -and $hwnd -ne [WindowOpacity]::GetShellWindow()) {
            # Verificar si la ventana pertenece a una aplicación excluida
            $processId = 0
            [WindowOpacity]::GetWindowThreadProcessId($hwnd, [ref]$processId) | Out-Null
            
            try {
                $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
                if ($process) {
                    $processName = $process.ProcessName.ToLower()
                    
                    # Si el proceso está en la lista de exclusiones
                    if ($script:excludedApps.Contains($processName)) {
                        # Obtener el estilo actual de la ventana
                        $style = [WindowOpacity]::GetWindowLong($hwnd, [WindowOpacity]::GWL_EXSTYLE)
                        
                        # Si la ventana tiene el estilo WS_EX_LAYERED, restaurar a opaco
                        if (($style -band [WindowOpacity]::WS_EX_LAYERED) -ne 0) {
                            # Obtener título de la ventana para mostrar en log
                            $title = New-Object System.Text.StringBuilder 256
                            [WindowOpacity]::GetWindowText($hwnd, $title, 256) | Out-Null
                            
                            if ($title.Length -gt 0) {
                                Write-Host "Restaurando opacidad (excluida): $($title.ToString())"
                                
                                # Quitar el estilo WS_EX_LAYERED
                                $newStyle = $style -bxor [WindowOpacity]::WS_EX_LAYERED
                                [WindowOpacity]::SetWindowLong($hwnd, [WindowOpacity]::GWL_EXSTYLE, $newStyle) | Out-Null
                            }
                        }
                    }
                }
            }
            catch {
                # Ignorar errores al acceder a procesos inaccesibles
            }
        }
        return $true
    }
    
    # Enumerar todas las ventanas
    [WindowOpacity]::EnumWindows($callback, [IntPtr]::Zero)
}

# Función para actualizar la transparencia de las ventanas existentes
function Update-ExistingWindowsTransparency {
    # Solo actualizar si el proceso está activo
    if (-not (Test-Path $flagFilePath)) {
        return
    }

    $callback = [WindowOpacity+EnumWindowsProc] {
        param([IntPtr]$hwnd, [IntPtr]$lParam)
        
        # Ignorar ventanas invisibles y el escritorio
        if ([WindowOpacity]::IsWindowVisible($hwnd) -and $hwnd -ne [WindowOpacity]::GetShellWindow()) {
            # Obtener el estilo actual de la ventana
            $style = [WindowOpacity]::GetWindowLong($hwnd, [WindowOpacity]::GWL_EXSTYLE)
            
            # Si la ventana tiene el estilo WS_EX_LAYERED, actualizar la transparencia
            if (($style -band [WindowOpacity]::WS_EX_LAYERED) -ne 0) {
                # Verificar si la ventana pertenece a una aplicación excluida
                $processId = 0
                [WindowOpacity]::GetWindowThreadProcessId($hwnd, [ref]$processId) | Out-Null
                
                try {
                    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
                    if ($process) {
                        $processName = $process.ProcessName.ToLower()
                        
                        # No aplicar transparencia a procesos excluidos
                        if (-not $script:excludedApps.Contains($processName)) {
                            # Establecer el nuevo nivel de transparencia
                            [WindowOpacity]::SetLayeredWindowAttributes($hwnd, 0, [byte]$script:transparencyLevel, [WindowOpacity]::LWA_ALPHA) | Out-Null
                        }
                    }
                }
                catch {
                    # Ignorar errores al acceder a procesos inaccesibles
                }
            }
        }
        return $true
    }
    
    # Enumerar todas las ventanas
    [WindowOpacity]::EnumWindows($callback, [IntPtr]::Zero)
}

# Función para iniciar el proceso de transparencia en segundo plano
function Start-TransparencyProcess {
    # Comprobar si ya hay un proceso activo
    if (Test-Path $flagFilePath) {
        # Eliminar el archivo indicador si existe para asegurar un inicio limpio
        try {
            Remove-Item $flagFilePath -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Host "Error al eliminar archivo indicador existente: $_"
        }
    }
    
    # Asegurar que la configuración esté actualizada antes de iniciar
    Update-TransparencySettings
    Update-ExclusionSettings
    
    # Iniciar el proceso en segundo plano
    try {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = "powershell"
        $startInfo.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""
        $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
        $startInfo.CreateNoWindow = $true
        $backgroundProcess = [System.Diagnostics.Process]::Start($startInfo)
        
        Write-Host "Proceso de transparencia iniciado con configuración: Nivel=$($script:transparencyLevel), Modo=$($script:transparencyMode)"
        
        # Esperar un momento para que se cree el archivo indicador
        Start-Sleep -Milliseconds 500
        
        Update-ProcessStateUI
    }
    catch {
        Write-Host "Error al iniciar el proceso: $_"
    }
}

# Función para detener el proceso de transparencia
function Stop-TransparencyProcess {
    if (Test-Path $flagFilePath) {
        try {
            # Restaurar todas las ventanas a su opacidad normal
            Restore-AllWindowsOpacity
            
            # Eliminar el archivo indicador - esto hará que el script de transparencia se detenga
            Remove-Item $flagFilePath -Force
            Write-Host "Proceso de transparencia detenido"
            
            Update-ProcessStateUI
        }
        catch {
            Write-Host "Error al detener el proceso: $_"
        }
    }
}

# Función para restaurar la opacidad de todas las ventanas
function Restore-AllWindowsOpacity {
    Write-Host "Restaurando opacidad de todas las ventanas (excepto barra de tareas)..."
    
    $callback = [WindowOpacity+EnumWindowsProc] {
        param([IntPtr]$hwnd, [IntPtr]$lParam)
        
        # Ignorar ventanas invisibles y el escritorio
        if (-not ([WindowOpacity]::IsWindowVisible($hwnd)) -or $hwnd -eq [WindowOpacity]::GetShellWindow()) {
            return $true
        }

        # Comprobar que no sea la barra de tareas
        $classNameBuilder = New-Object System.Text.StringBuilder 256
        [WindowOpacity]::GetClassName($hwnd, $classNameBuilder, 256) | Out-Null
        if ($classNameBuilder.ToString() -eq "Shell_TrayWnd") {
            return $true
        }

            # Obtener el estilo actual de la ventana
            $style = [WindowOpacity]::GetWindowLong($hwnd, [WindowOpacity]::GWL_EXSTYLE)
            
            # Si la ventana tiene el estilo WS_EX_LAYERED, restaurar a opaco
            if (($style -band [WindowOpacity]::WS_EX_LAYERED) -ne 0) {
            # Obtener título de la ventana para mostrar en log
                $title = New-Object System.Text.StringBuilder 256
                [WindowOpacity]::GetWindowText($hwnd, $title, 256) | Out-Null
                
                if ($title.Length -gt 0) {
                    Write-Host "Restaurando opacidad: $($title.ToString())"
                    
                # Quitar el estilo WS_EX_LAYERED
                    $newStyle = $style -bxor [WindowOpacity]::WS_EX_LAYERED
                    [WindowOpacity]::SetWindowLong($hwnd, [WindowOpacity]::GWL_EXSTYLE, $newStyle) | Out-Null
            }
        }
        return $true
    }
    
    # Enumerar todas las ventanas
    [WindowOpacity]::EnumWindows($callback, [IntPtr]::Zero)
}

# Función para obtener la lista de procesos en ejecución
function Get-RunningProcesses {
    $processes = @()
    try {
        # Obtener solo procesos que tengan una ventana principal con título, que suelen ser las aplicaciones de usuario
        $processes = Get-Process | Where-Object { $_.MainWindowTitle -ne "" } | Select-Object -ExpandProperty ProcessName
    } catch {
        Write-Host "Error al obtener la lista de procesos: $_"
    }
    
    # Devolver una lista única (sin duplicados), en minúsculas y ordenada
    return $processes | ForEach-Object { $_.ToLower() } | Sort-Object -Unique
}

# Función para verificar si está configurado para inicio automático
function Check-AutoStartEnabled {
    $startupFolder = [System.IO.Path]::Combine([Environment]::GetFolderPath("Startup"))
    # Usar el nuevo nombre del acceso directo
    $shortcutPath = Join-Path $startupFolder "Littlegods Utility Transparent Desktop.lnk"
    return Test-Path $shortcutPath
}

# Función para configurar inicio automático (Reescrita para ser más robusta)
function Set-AutoStart {
    param([bool]$enable)
    
    $startupFolder = [System.IO.Path]::Combine([Environment]::GetFolderPath("Startup"))
    $shortcutName = "Littlegods Utility Transparent Desktop.lnk"
    $shortcutPath = Join-Path $startupFolder $shortcutName
    
    if ($enable) {
        # Usar el script dedicado para crear el acceso directo
        $configScriptPath = Join-Path $PSScriptRoot "ConfigurarAutoarranque.ps1"
        if (-not (Test-Path $configScriptPath)) {
            [System.Windows.Forms.MessageBox]::Show("No se encontró el script 'ConfigurarAutoarranque.ps1'.", "Error", "OK", "Error")
            return
        }
        
        try {
            # Ejecutar el script en un nuevo proceso para evitar problemas de permisos
            Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$configScriptPath`"" -WindowStyle Hidden -Wait
            
            # Verificar si el script tuvo éxito
            if (-not (Test-Path $shortcutPath)) {
                throw "El script de configuración se ejecutó, pero no se pudo crear el acceso directo."
            }
            Write-Host "Inicio automático habilitado a través de ConfigurarAutoarranque.ps1"
        } catch {
            Write-Warning "Error al ejecutar ConfigurarAutoarranque.ps1: $_"
            [System.Windows.Forms.MessageBox]::Show("Error al configurar el inicio automático. Asegúrate de que el script tiene permisos para crear archivos en la carpeta de inicio.", "Error de configuración", "OK", "Error")
        }
        
    } else {
        # Eliminar el acceso directo si existe
        if (Test-Path $shortcutPath) {
            try {
                Remove-Item $shortcutPath -Force -ErrorAction Stop
                Write-Host "Inicio automático deshabilitado (acceso directo eliminado)."
            } catch {
                Write-Warning "Error al eliminar el acceso directo: $_"
                [System.Windows.Forms.MessageBox]::Show("No se pudo eliminar el acceso directo de la carpeta de inicio.", "Error", "OK", "Error")
            }
        }
    }
}

# Función para refrescar el tema de manera más agresiva
function Refresh-Theme {
    # Obtener colores actuales
    $colors = Get-ThemeColors
    
    # Forzar actualización de todos los controles principales
    $form.SuspendLayout()
    
    # Actualizar el fondo de todos los grupos
    $grpTransparency.BackColor = $colors.BackColor
    $grpExclusions.BackColor = $colors.BackColor
    $grpProcess.BackColor = $colors.BackColor
    
    # Actualizar controles dentro de los grupos
    $trackTransparency.BackColor = $colors.BackColor
    $lbExclusions.BackColor = $colors.ListBoxBackColor
    $lbExclusions.ForeColor = $colors.ListBoxForeColor
    $lbRunningProcesses.BackColor = $colors.ListBoxBackColor
    $lbRunningProcesses.ForeColor = $colors.ListBoxForeColor
    $txtManualProcess.BackColor = $colors.TextBoxBackColor
    $txtManualProcess.ForeColor = $colors.TextBoxForeColor
    
    # Forzar redibujo de las listas
    $lbExclusions.Refresh()
    $lbRunningProcesses.Refresh()
    
    # Aplicar tema completo
    Apply-Theme -form $form
    
    $form.ResumeLayout()
    
    # Forzar la actualización de los datos de las listas
    Force-ListsRefresh
}

# Función para mejorar la visualización de los controles
function Enhance-ControlsVisibility {
    # Establecer propiedades adicionales para mejorar la visualización
    $drawItemHandler = {
        param($sender, $e)
        
        if ($e.Index -lt 0) { return }
        
        $colors = Get-ThemeColors
        # Mejorar la calidad del renderizado de texto
        $e.Graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
        
        $backBrush = $null
        $textBrush = $null
        
        # Determinar colores según si el elemento está seleccionado
        if (($e.State -band [System.Windows.Forms.DrawState]::Selected) -eq [System.Windows.Forms.DrawState]::Selected) {
            # Elemento seleccionado
            $backBrush = New-Object System.Drawing.SolidBrush($colors.HighlightBackColor)
            $textBrush = New-Object System.Drawing.SolidBrush($colors.HighlightForeColor)
        } else {
            # Elemento no seleccionado
            $backBrush = New-Object System.Drawing.SolidBrush($colors.ListBoxBackColor)
            $textBrush = New-Object System.Drawing.SolidBrush($colors.ListBoxForeColor)
        }
        
        # Dibujar el fondo
        $e.Graphics.FillRectangle($backBrush, $e.Bounds)
        
        # Dibujar el texto del elemento
        $text = $sender.Items[$e.Index].ToString()
        $e.Graphics.DrawString($text, $e.Font, $textBrush, $e.Bounds.Left + 2, $e.Bounds.Top + 2)
        
        # Dibujar el rectángulo de foco si es necesario
        $e.DrawFocusRectangle()
        
        # Liberar recursos
        $backBrush.Dispose()
        $textBrush.Dispose()
    }

    # Aplicar el manejador de dibujo a ambas listas
    $lbExclusions.DrawMode = [System.Windows.Forms.DrawMode]::OwnerDrawFixed
    $lbExclusions.Add_DrawItem($drawItemHandler)
    
    $lbRunningProcesses.DrawMode = [System.Windows.Forms.DrawMode]::OwnerDrawFixed
    $lbRunningProcesses.Add_DrawItem($drawItemHandler)
}

# --- INICIO: Función para Refrescar la UI ---
# Esta función centraliza la actualización de la apariencia de la UI.
function Refresh-UI {
    $form.SuspendLayout()

    # 1. Aplicar el tema (colores y fuentes) PRIMERO
    Apply-Theme -form $form

    # 2. Aplicar el idioma a todos los textos DESPUÉS
    Apply-Language -langCode $themeSettings.Language
    
    # 3. Forzar la actualización de datos en las listas si es necesario
    if ($lbExclusions.Items.Count -ne $script:excludedApps.Count) {
        Force-ListsRefresh
    }
    
    $form.ResumeLayout()
}
# --- FIN: Función para Refrescar la UI ---

# --- INICIO: Función para aplicar el idioma (Versión corregida y completa) ---
function Apply-Language {
    param([string]$langCode)

    if (-not $translations.ContainsKey($langCode)) {
        $langCode = "es" # Volver a español si el idioma no existe
    }
    $lang = $translations[$langCode]

    # Aplicar textos a todos los controles
    $form.Text = $lang.formTitle
    $grpTransparency.Text = $lang.transparencyLevelGroup
    $btnApply.Text = $lang.applyButton
    $grpTaskbarTransparency.Text = $lang.taskbarTransparencyGroup
    $btnApplyTaskbar.Text = $lang.applyButton
    $grpShellEffects.Text = $lang.shellEffectsGroup
    $chkShellTransparency.Text = $lang.shellEffectsCheckbox
    $grpExclusions.Text = $lang.excludedAppsGroup
    $lblRunningProcesses.Text = $lang.runningProcessesLabel
    $btnAddSelected.Text = $lang.addSelectedButton
    $btnRefreshProcesses.Text = $lang.updateButton
    if ($txtManualProcess.Text -eq "Nombre del proceso" -or $txtManualProcess.Text -eq $lang.manualProcessPlaceholder) {
        $txtManualProcess.Text = $lang.manualProcessPlaceholder
        $txtManualProcess.ForeColor = [System.Drawing.Color]::Gray
    }
    $grpProcess.Text = $lang.processControlGroup
    $btnStart.Text = $lang.startButton
    $btnStop.Text = $lang.stopButton
    $chkAutoStart.Text = $lang.autoStartCheckbox
    $grpTheme.Text = $lang.themeAndFontGroup
    $lblTheme.Text = $lang.themeLabel
    $rbLight.Text = $lang.lightThemeRadio
    $rbDark.Text = $lang.darkThemeRadio
    $rbSystem.Text = $lang.systemThemeRadio
    $lblFont.Text = $lang.fontLabel
    $lblFontSize.Text = $lang.sizeLabel
    $lblLanguage.Text = $lang.languageLabel
    $grpContact.Text = $lang.contactGroup
    $lnkDiscord.Text = $lang.discordLink
    $lnkGitHub.Text = $lang.githubLink
    $authorLabel.Text = $lang.authorLabel
    $versionLabel.Text = $lang.versionLabel
    $rightsLabel.Text = $lang.rightsLabel
    $sourceLabel.Text = $lang.sourceLabel
    $titleLabel.Text = $lang.littlegodsUtilityLabel
    
    # Nuevos textos para el modo de transparencia
    $grpTransparencyMode.Text = $lang.transparencyModeGroup
    $rbGlobalMode.Text = $lang.globalModeRadio
    $rbIntelligentMode.Text = $lang.intelligentModeRadio
    $rbIntelligentInverseMode.Text = $lang.intelligentInverseModeRadio
    
    # Textos del menú contextual
    $notifyIcon.Text = $lang.trayIconText
    $menuItemShow.Text = $lang.showSettingsMenu
    $menuItemExit.Text = $lang.exitMenu
    
    # El texto del botón de alternancia depende de su estado
    if (Test-Path $flagFilePath) {
        $menuItemToggle.Text = $lang.toggleTransparencyMenu_Stop
    } else {
        $menuItemToggle.Text = $lang.toggleTransparencyMenu_Start
    }
}
# --- FIN: Función para aplicar el idioma ---

# Crear la interfaz gráfica
$form = New-Object System.Windows.Forms.Form
$form.Text = "Control de Transparencia de Ventanas"
$form.Size = New-Object System.Drawing.Size(970, 650) # Ancho aumentado, alto reducido y ajustado
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $true
$form.ShowInTaskbar = $false

# Manejar el evento de cierre para minimizar en lugar de cerrar
$form.Add_FormClosing({
    if ($_.CloseReason -eq [System.Windows.Forms.CloseReason]::UserClosing) {
        $_.Cancel = $true
        $form.Hide()
    }
})

# --- INICIO: Logo y Título ---
$script:isLogoFlipped = $false

if (Test-Path $logoPath) {
    # Función para crear imagen circular
    function Create-CircularImage {
        param([System.Drawing.Image]$originalImage, [int]$size)
        
        $bitmap = New-Object System.Drawing.Bitmap($size, $size)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        
        # Crear un path circular
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $path.AddEllipse(0, 0, $size, $size)
        
        # Establecer la región de recorte
        $graphics.SetClip($path)
        
        # Dibujar la imagen original escalada dentro del círculo
        $graphics.DrawImage($originalImage, 0, 0, $size, $size)
        
        $graphics.Dispose()
        $path.Dispose()
        
        return $bitmap
    }
    
    # PictureBox para el logo
    $logoPictureBox = New-Object System.Windows.Forms.PictureBox
    $logoPictureBox.Location = New-Object System.Drawing.Point(453, 15) # Centrado para el nuevo ancho
    $logoPictureBox.Size = New-Object System.Drawing.Size(64, 64)
    $logoPictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
    
    # Cargar imagen original y crear versión circular
    $script:originalImage = [System.Drawing.Image]::FromFile($logoPath)
    $circularImage = Create-CircularImage -originalImage $script:originalImage -size 64
    $logoPictureBox.Image = $circularImage
    
    $logoPictureBox.Cursor = [System.Windows.Forms.Cursors]::Hand
    $form.Controls.Add($logoPictureBox)

    # Labels para el texto del autor (inicialmente ocultos)
    $authorLabel = New-Object System.Windows.Forms.Label
    $authorLabel.Location = New-Object System.Drawing.Point(10, 15)
    $authorLabel.Size = New-Object System.Drawing.Size(950, 15) # Ancho completo
    $authorLabel.Text = "Author: Andresito_20"
    $authorLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
    $authorLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $authorLabel.Visible = $false
    $authorLabel.Cursor = [System.Windows.Forms.Cursors]::Hand
    $form.Controls.Add($authorLabel)
    
    $versionLabel = New-Object System.Windows.Forms.Label
    $versionLabel.Location = New-Object System.Drawing.Point(10, 30)
    $versionLabel.Size = New-Object System.Drawing.Size(950, 15) # Ancho completo
    $versionLabel.Text = "Version: 1.5"
    $versionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $versionLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $versionLabel.Visible = $false
    $versionLabel.Cursor = [System.Windows.Forms.Cursors]::Hand
    $form.Controls.Add($versionLabel)

    $rightsLabel = New-Object System.Windows.Forms.Label
    $rightsLabel.Location = New-Object System.Drawing.Point(10, 45)
    $rightsLabel.Size = New-Object System.Drawing.Size(950, 15) # Ancho completo
    $rightsLabel.Text = "Libre de derechos"
    $rightsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $rightsLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $rightsLabel.Visible = $false
    $rightsLabel.Cursor = [System.Windows.Forms.Cursors]::Hand
    $form.Controls.Add($rightsLabel)

    $sourceLabel = New-Object System.Windows.Forms.Label
    $sourceLabel.Location = New-Object System.Drawing.Point(10, 60)
    $sourceLabel.Size = New-Object System.Drawing.Size(950, 15) # Ancho completo
    $sourceLabel.Text = "Source code - Community"
    $sourceLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $sourceLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $sourceLabel.Visible = $false
    $sourceLabel.Cursor = [System.Windows.Forms.Cursors]::Hand
    $form.Controls.Add($sourceLabel)

    # Evento de clic para "voltear"
    $flipHandler = {
        $script:isLogoFlipped = -not $script:isLogoFlipped
        $logoPictureBox.Visible = -not $script:isLogoFlipped
        $authorLabel.Visible = $script:isLogoFlipped
        $versionLabel.Visible = $script:isLogoFlipped
        $rightsLabel.Visible = $script:isLogoFlipped
        $sourceLabel.Visible = $script:isLogoFlipped
    }

    $logoPictureBox.Add_Click($flipHandler)
    $authorLabel.Add_Click($flipHandler)
    $versionLabel.Add_Click($flipHandler)
    $rightsLabel.Add_Click($flipHandler)
    $sourceLabel.Add_Click($flipHandler)

    # Label para el título principal
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Location = New-Object System.Drawing.Point(10, 85)
    $titleLabel.Size = New-Object System.Drawing.Size(950, 25) # Ancho completo
    $titleLabel.Text = "Littlegods Utility"
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $titleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $form.Controls.Add($titleLabel)
}
# --- FIN: Logo y Título ---

# Crear el NotifyIcon para el system tray
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Text = "Control de Transparencia de Ventanas"
$notifyIcon.Visible = $true

# Cargar el icono desde el archivo ICO
if (Test-Path $logoPath) {
    try {
        # Cargar directamente el archivo ICO
        $notifyIcon.Icon = New-Object System.Drawing.Icon($logoPath)
        $notifyIcon.Text = "Control de Transparencia - LittleGods"
        Write-Host "Icono personalizado cargado correctamente desde: $logoPath"
    } catch {
        Write-Host "Error al cargar el icono: $_"
        # Usar icono de respaldo
        $notifyIcon.Icon = [System.Drawing.SystemIcons]::Application
    }
} else {
    Write-Host "No se encontró el archivo de icono: $logoPath"
    # Usar icono de respaldo
    $notifyIcon.Icon = [System.Drawing.SystemIcons]::Application
}

# Crear el menú contextual para el NotifyIcon
$contextMenu = New-Object -TypeName System.Windows.Forms.ContextMenuStrip

# Opción para mostrar la ventana
$menuItemShow = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItemShow.Text = "Mostrar configuración"
$menuItemShow.Add_Click({
    $form.Show()
    $form.WindowState = [System.Windows.Forms.FormWindowState]::Normal
    $form.BringToFront()
})
$contextMenu.Items.Add($menuItemShow)

# Opción para iniciar/detener la transparencia
$menuItemToggle = New-Object -TypeName System.Windows.Forms.ToolStripMenuItem
$menuItemToggle.Text = "Detener transparencia"
$menuItemToggle.Add_Click({
    if (Test-Path $flagFilePath) {
        Stop-TransparencyProcess
    } else {
        Start-TransparencyProcess
    }
})
$contextMenu.Items.Add($menuItemToggle)

# Separador
$contextMenu.Items.Add((New-Object -TypeName System.Windows.Forms.ToolStripSeparator))  

# Opción para salir
$menuItemExit = New-Object -TypeName System.Windows.Forms.ToolStripMenuItem
$menuItemExit.Text = "Salir"
$menuItemExit.Add_Click({
    # --- SECUENCIA DE SALIDA CORREGIDA (v2) ---
    Write-Host "Iniciando secuencia de salida..."
    
    # 0. Liberar recursos de imágenes
    try {
        if ($logoPictureBox -and $logoPictureBox.Image) {
            $logoPictureBox.Image.Dispose()
        }
        if ($script:originalImage) {
            $script:originalImage.Dispose()
        }
        if ($picDiscord -and $picDiscord.Image) {
            $picDiscord.Image.Dispose()
        }
        if ($picGitHub -and $picGitHub.Image) {
            $picGitHub.Image.Dispose()
        }
    } catch {
        Write-Host "Error liberando recursos de imágenes: $_"
    }

    # 1. Detener el proceso en segundo plano primero.
    if (Test-Path $flagFilePath) {
        Write-Host "Deteniendo proceso de fondo..."
        try {
            Remove-Item $flagFilePath -Force
        } catch {
            Write-Warning "No se pudo eliminar el archivo indicador: $_"
        }
        Start-Sleep -Milliseconds 500
    }

    # 2. Restaurar la opacidad de todas las ventanas y la barra de tareas.
    Write-Host "Restaurando opacidad de las ventanas..."
    Restore-AllWindowsOpacity
    
    Write-Host "Restaurando opacidad de la barra de tareas..."
    Restore-TaskbarOpacity

    # 3. Guardar el estado final antes de salir.
    # Esto es crucial para que las exclusiones se mantengan.
    Write-Host "Guardando el estado final de la configuración..."
    Save-State
    
    # 4. Liberar el Mutex.
    if ($script:singleInstanceMutex) {
        Write-Host "Liberando Mutex..."
        try {
            $script:singleInstanceMutex.ReleaseMutex()
            $script:singleInstanceMutex.Close()
            $script:singleInstanceMutex = $null
        } catch {
            # Ignorar errores.
        }
    }

    # 5. Limpiar recursos de la bandeja del sistema.
    Write-Host "Limpiando icono de la bandeja..."
    $notifyIcon.Visible = $false
    $notifyIcon.Dispose()
    
    # 6. Cerrar la aplicación de forma definitiva.
    Write-Host "Cerrando aplicación."
    [System.Windows.Forms.Application]::Exit()
})
$contextMenu.Items.Add($menuItemExit)

# Separador antes de opciones de tema
$separator = New-Object -TypeName System.Windows.Forms.ToolStripSeparator
$contextMenu.Items.Add($separator)

# Opción para configurar tema y fuente - Eliminada porque ahora está en la UI principal

# Asignar el menú contextual al NotifyIcon
$notifyIcon.ContextMenuStrip = $contextMenu

# Evento de doble clic para mostrar la ventana
$notifyIcon.Add_MouseDoubleClick({
    $form.Show()
    $form.WindowState = [System.Windows.Forms.FormWindowState]::Normal
    $form.BringToFront()
})

# Grupo para el nivel de transparencia
$grpTransparency = New-Object System.Windows.Forms.GroupBox
$grpTransparency.Location = New-Object System.Drawing.Point(10, 120)
$grpTransparency.Size = New-Object System.Drawing.Size(470, 100)
$grpTransparency.Text = "Nivel de transparencia (Ventanas)"
$form.Controls.Add($grpTransparency)

# Track bar para ajustar la transparencia
$trackTransparency = New-Object System.Windows.Forms.TrackBar
$trackTransparency.Location = New-Object System.Drawing.Point(10, 20)
$trackTransparency.Size = New-Object System.Drawing.Size(450, 45)
$trackTransparency.Minimum = 10
$trackTransparency.Maximum = 255
$trackTransparency.Value = $transparencyLevel
$trackTransparency.TickFrequency = 5
$trackTransparency.Add_ValueChanged({
    $script:transparencyLevel = $trackTransparency.Value
    $lblTransparencyValue.Text = "$($script:transparencyLevel) / 255"
})
$grpTransparency.Controls.Add($trackTransparency)

# Etiqueta para mostrar el valor actual
$lblTransparencyValue = New-Object System.Windows.Forms.Label
$lblTransparencyValue.Location = New-Object System.Drawing.Point(10, 65)
$lblTransparencyValue.Size = New-Object System.Drawing.Size(100, 20)
$lblTransparencyValue.Text = "$transparencyLevel / 255"
$grpTransparency.Controls.Add($lblTransparencyValue)

# Botón para aplicar cambios
$btnApply = New-Object System.Windows.Forms.Button
$btnApply.Location = New-Object System.Drawing.Point(370, 60)
$btnApply.Size = New-Object System.Drawing.Size(90, 30)
$btnApply.Text = "Aplicar"
$btnApply.Add_Click({
    Update-TransparencySettings
    Save-State # Guardar estado
})
$grpTransparency.Controls.Add($btnApply)

# --- NUEVO: Grupo para la transparencia de la barra de tareas ---
$grpTaskbarTransparency = New-Object System.Windows.Forms.GroupBox
$grpTaskbarTransparency.Location = New-Object System.Drawing.Point(10, 225)
$grpTaskbarTransparency.Size = New-Object System.Drawing.Size(470, 100)
$grpTaskbarTransparency.Text = "Nivel de transparencia (Barra de tareas)"
$form.Controls.Add($grpTaskbarTransparency)

$trackTaskbarTransparency = New-Object System.Windows.Forms.TrackBar
$trackTaskbarTransparency.Location = New-Object System.Drawing.Point(10, 20)
$trackTaskbarTransparency.Size = New-Object System.Drawing.Size(450, 45)
$trackTaskbarTransparency.Minimum = 10
$trackTaskbarTransparency.Maximum = 255
$trackTaskbarTransparency.Value = $taskbarTransparencyLevel
$trackTaskbarTransparency.TickFrequency = 5
$trackTaskbarTransparency.Add_ValueChanged({
    $script:taskbarTransparencyLevel = $trackTaskbarTransparency.Value
    $lblTaskbarTransparencyValue.Text = "$($script:taskbarTransparencyLevel) / 255"
})
$grpTaskbarTransparency.Controls.Add($trackTaskbarTransparency)

$lblTaskbarTransparencyValue = New-Object System.Windows.Forms.Label
$lblTaskbarTransparencyValue.Location = New-Object System.Drawing.Point(10, 65)
$lblTaskbarTransparencyValue.Size = New-Object System.Drawing.Size(100, 20)
$lblTaskbarTransparencyValue.Text = "$taskbarTransparencyLevel / 255"
$grpTaskbarTransparency.Controls.Add($lblTaskbarTransparencyValue)

$btnApplyTaskbar = New-Object System.Windows.Forms.Button
$btnApplyTaskbar.Location = New-Object System.Drawing.Point(370, 60)
$btnApplyTaskbar.Size = New-Object System.Drawing.Size(90, 30)
$btnApplyTaskbar.Text = "Aplicar"
$btnApplyTaskbar.Add_Click({
    Set-TaskbarTransparency -Alpha $script:taskbarTransparencyLevel
    Save-State # Guardar estado
})
$grpTaskbarTransparency.Controls.Add($btnApplyTaskbar)
# --- FIN DEL GRUPO DE BARRA DE TAREAS ---

# --- INICIO: Grupo para el Modo de Transparencia ---
$grpTransparencyMode = New-Object System.Windows.Forms.GroupBox
$grpTransparencyMode.Location = New-Object System.Drawing.Point(10, 330)
$grpTransparencyMode.Size = New-Object System.Drawing.Size(470, 105) # Aumentar altura
$grpTransparencyMode.Text = "Modo de Transparencia"
$form.Controls.Add($grpTransparencyMode)

$script:transparencyMode = 'Global' # Valor por defecto

$rbGlobalMode = New-Object System.Windows.Forms.RadioButton
$rbGlobalMode.Location = New-Object System.Drawing.Point(10, 25)
$rbGlobalMode.Size = New-Object System.Drawing.Size(450, 20)
$rbGlobalMode.Text = "Global (todas las ventanas)"
$rbGlobalMode.Checked = ($script:transparencyMode -eq 'Global')
$rbGlobalMode.Add_CheckedChanged({ 
    if ($rbGlobalMode.Checked) { 
        $script:transparencyMode = 'Global'
        $grpTransparency.Text = $translations[$themeSettings.Language].transparencyLevelGroup # Texto genérico
        Update-TransparencySettings
        Save-State
    } 
})
$grpTransparencyMode.Controls.Add($rbGlobalMode)

$rbIntelligentMode = New-Object System.Windows.Forms.RadioButton
$rbIntelligentMode.Location = New-Object System.Drawing.Point(10, 50)
$rbIntelligentMode.Size = New-Object System.Drawing.Size(450, 20)
$rbIntelligentMode.Text = "Inteligente (ventanas sin foco)"
$rbIntelligentMode.Checked = ($script:transparencyMode -eq 'Intelligent')
$rbIntelligentMode.Add_CheckedChanged({ 
    if ($rbIntelligentMode.Checked) { 
        $script:transparencyMode = 'Intelligent'
        $grpTransparency.Text = $translations[$themeSettings.Language].transparencyLevelGroup + " (" + $translations[$themeSettings.Language].intelligentModeRadio.Split('(')[1]
        Update-TransparencySettings
        Save-State
    } 
})
$grpTransparencyMode.Controls.Add($rbIntelligentMode)

$rbIntelligentInverseMode = New-Object System.Windows.Forms.RadioButton
$rbIntelligentInverseMode.Location = New-Object System.Drawing.Point(10, 75)
$rbIntelligentInverseMode.Size = New-Object System.Drawing.Size(450, 20)
$rbIntelligentInverseMode.Text = "Inteligente (solo ventana con foco)"
$rbIntelligentInverseMode.Checked = ($script:transparencyMode -eq 'Intelligent-Inverse')
$rbIntelligentInverseMode.Add_CheckedChanged({ 
    if ($rbIntelligentInverseMode.Checked) { 
        $script:transparencyMode = 'Intelligent-Inverse'
        $grpTransparency.Text = $translations[$themeSettings.Language].transparencyLevelGroup + " (" + $translations[$themeSettings.Language].intelligentInverseModeRadio.Split('(')[1]
        Update-TransparencySettings
        Save-State
    } 
})
$grpTransparencyMode.Controls.Add($rbIntelligentInverseMode)
# --- FIN: Grupo para el Modo de Transparencia ---

# --- Grupo para efectos del Shell ---
$grpShellEffects = New-Object System.Windows.Forms.GroupBox
$grpShellEffects.Location = New-Object System.Drawing.Point(10, 440) # Ajustar Y
$grpShellEffects.Size = New-Object System.Drawing.Size(470, 60)
$grpShellEffects.Text = "Efectos de Transparencia del Sistema"
$form.Controls.Add($grpShellEffects)

$chkShellTransparency = New-Object System.Windows.Forms.CheckBox
$chkShellTransparency.Location = New-Object System.Drawing.Point(10, 25)
$chkShellTransparency.Size = New-Object System.Drawing.Size(450, 20)
$chkShellTransparency.Text = "Habilitar transparencia en Menú Inicio, Notificaciones, etc."
$chkShellTransparency.Add_CheckedChanged({
    Set-GlobalShellTransparency -Enable $chkShellTransparency.Checked
    Save-State # Guardar estado
})
$grpShellEffects.Controls.Add($chkShellTransparency)

# Grupo para la gestión de exclusiones
$grpExclusions = New-Object System.Windows.Forms.GroupBox
$grpExclusions.Location = New-Object System.Drawing.Point(490, 120) # Columna 2, Fila 1
$grpExclusions.Size = New-Object System.Drawing.Size(470, 180)
$grpExclusions.Text = "Aplicaciones excluidas"
$form.Controls.Add($grpExclusions)

# ListBox para mostrar las aplicaciones excluidas
$lbExclusions = New-Object System.Windows.Forms.ListBox
$lbExclusions.Location = New-Object System.Drawing.Point(10, 20)
$lbExclusions.Size = New-Object System.Drawing.Size(200, 120)
$grpExclusions.Controls.Add($lbExclusions)

# Label para procesos en ejecución
$lblRunningProcesses = New-Object System.Windows.Forms.Label
$lblRunningProcesses.Location = New-Object System.Drawing.Point(220, 20)
$lblRunningProcesses.Size = New-Object System.Drawing.Size(240, 20)
$lblRunningProcesses.Text = "Procesos en ejecución:"
$grpExclusions.Controls.Add($lblRunningProcesses)

# ListBox para mostrar los procesos en ejecución
$lbRunningProcesses = New-Object System.Windows.Forms.ListBox
$lbRunningProcesses.Location = New-Object System.Drawing.Point(220, 40)
$lbRunningProcesses.Size = New-Object System.Drawing.Size(240, 100)
$lbRunningProcesses.SelectionMode = [System.Windows.Forms.SelectionMode]::MultiExtended
$grpExclusions.Controls.Add($lbRunningProcesses)

# Botón para añadir procesos seleccionados
$btnAddSelected = New-Object System.Windows.Forms.Button
$btnAddSelected.Location = New-Object System.Drawing.Point(220, 145)
$btnAddSelected.Size = New-Object System.Drawing.Size(140, 25)
$btnAddSelected.Text = "Añadir seleccionados"
$btnAddSelected.Add_Click({
    $selectedItems = @($lbRunningProcesses.SelectedItems)
    if ($selectedItems.Count -eq 0) { return }

    $newList = @($script:excludedApps) # Crear una copia para modificar
    foreach ($item in $selectedItems) {
        $processName = $item.ToString().ToLower()
        if (-not ($newList -contains $processName)) {
            $newList += $processName
        }
    }
    
    $script:excludedApps = $newList | Sort-Object
            Save-Exclusions
    Refresh-Lists
})
$grpExclusions.Controls.Add($btnAddSelected)

# Campo de texto para añadir procesos manualmente
$txtManualProcess = New-Object System.Windows.Forms.TextBox
$txtManualProcess.Location = New-Object System.Drawing.Point(10, 145)
$txtManualProcess.Size = New-Object System.Drawing.Size(110, 25)
$txtManualProcess.Text = "Nombre del proceso"
$txtManualProcess.ForeColor = [System.Drawing.Color]::Gray
$grpExclusions.Controls.Add($txtManualProcess)

# Botón para añadir proceso manual
$btnAddManual = New-Object System.Windows.Forms.Button
$btnAddManual.Location = New-Object System.Drawing.Point(125, 145)
$btnAddManual.Size = New-Object System.Drawing.Size(40, 25)
$btnAddManual.Text = "+"
$btnAddManual.Add_Click({
    $processName = $txtManualProcess.Text.Trim().ToLower()
    if ($processName -and (-not ($script:excludedApps -contains $processName))) {
        # Creamos una nueva lista para asegurar que es un array
        $newList = @($script:excludedApps) + $processName
        $script:excludedApps = $newList | Sort-Object
        $txtManualProcess.Clear()
        Save-Exclusions
        Refresh-Lists
    }
})
$grpExclusions.Controls.Add($btnAddManual)

# Botón para eliminar aplicación
$btnRemoveExclusion = New-Object System.Windows.Forms.Button
$btnRemoveExclusion.Location = New-Object System.Drawing.Point(170, 145)
$btnRemoveExclusion.Size = New-Object System.Drawing.Size(40, 25)
$btnRemoveExclusion.Text = "-"
$btnRemoveExclusion.Add_Click({
    if ($lbExclusions.SelectedIndex -ge 0) {
        $selected = $lbExclusions.SelectedItem
        # Forzamos la creación de un nuevo array filtrado
        $newList = @($script:excludedApps | Where-Object { $_ -ne $selected })
        $script:excludedApps = $newList
        Save-Exclusions
        Refresh-Lists
    }
})
$grpExclusions.Controls.Add($btnRemoveExclusion)

# Grupo para el control del proceso
$grpProcess = New-Object System.Windows.Forms.GroupBox
$grpProcess.Location = New-Object System.Drawing.Point(10, 505) # Ajustar Y
$grpProcess.Size = New-Object System.Drawing.Size(470, 90) 
$grpProcess.Text = "Control del proceso"
$form.Controls.Add($grpProcess)

# Botón para iniciar el proceso
$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Location = New-Object System.Drawing.Point(10, 20)
$btnStart.Size = New-Object System.Drawing.Size(220, 25)
$btnStart.Text = "Iniciar transparencia"
$btnStart.Add_Click({
    Start-TransparencyProcess
    $menuItemToggle.Text = "Detener transparencia"
})
$grpProcess.Controls.Add($btnStart)

# Botón para detener el proceso
$btnStop = New-Object System.Windows.Forms.Button
$btnStop.Location = New-Object System.Drawing.Point(240, 20)
$btnStop.Size = New-Object System.Drawing.Size(220, 25)
$btnStop.Text = "Detener transparencia"
$btnStop.Add_Click({
    Stop-TransparencyProcess
    $menuItemToggle.Text = "Iniciar transparencia"
})
$grpProcess.Controls.Add($btnStop)

# Checkbox para inicio automático (ajustado para asegurar visibilidad)
$chkAutoStart = New-Object System.Windows.Forms.CheckBox
$chkAutoStart.Location = New-Object System.Drawing.Point(10, 55)
$chkAutoStart.Size = New-Object System.Drawing.Size(450, 20)
$chkAutoStart.Text = "Iniciar automáticamente con Windows"
$chkAutoStart.Checked = Check-AutoStartEnabled
$chkAutoStart.Add_CheckedChanged({
    param($sender, $e)
    
    # Llamar a la función para habilitar/deshabilitar
    Set-AutoStart -enable $sender.Checked
    
    # Volver a comprobar el estado real y sincronizar el checkbox
    # Esto asegura que si la operación falla, el checkbox refleje la realidad
    $estadoReal = Check-AutoStartEnabled
    if ($sender.Checked -ne $estadoReal) {
        $sender.Checked = $estadoReal
    }
})
$grpProcess.Controls.Add($chkAutoStart)

# --- INICIO: Grupo de Configuración de Tema y Fuente ---
$grpTheme = New-Object System.Windows.Forms.GroupBox
$grpTheme.Location = New-Object System.Drawing.Point(490, 305) # Columna 2, Fila 2
$grpTheme.Size = New-Object System.Drawing.Size(470, 190) 
$grpTheme.Text = "Configuración de Tema y Fuente"
$form.Controls.Add($grpTheme)

# Controles para el Tema
$lblTheme = New-Object System.Windows.Forms.Label
$lblTheme.Location = New-Object System.Drawing.Point(10, 25)
$lblTheme.Size = New-Object System.Drawing.Size(100, 20)
$lblTheme.Text = "Tema:"
$grpTheme.Controls.Add($lblTheme)

$rbLight = New-Object System.Windows.Forms.RadioButton
$rbLight.Location = New-Object System.Drawing.Point(120, 25)
$rbLight.Size = New-Object System.Drawing.Size(70, 20)
$rbLight.Text = "Claro"
$rbLight.Checked = ($themeSettings.Theme -eq "Light")
$rbLight.Add_CheckedChanged({ if($rbLight.Checked) { Set-Theme "Light"; Refresh-UI; Save-State; } })
$grpTheme.Controls.Add($rbLight)

$rbDark = New-Object System.Windows.Forms.RadioButton
$rbDark.Location = New-Object System.Drawing.Point(190, 25)
$rbDark.Size = New-Object System.Drawing.Size(70, 20)
$rbDark.Text = "Oscuro"
$rbDark.Checked = ($themeSettings.Theme -eq "Dark")
$rbDark.Add_CheckedChanged({ if($rbDark.Checked) { Set-Theme "Dark"; Refresh-UI; Save-State; } })
$grpTheme.Controls.Add($rbDark)

$rbSystem = New-Object System.Windows.Forms.RadioButton
$rbSystem.Location = New-Object System.Drawing.Point(260, 25)
$rbSystem.Size = New-Object System.Drawing.Size(80, 20)
$rbSystem.Text = "Sistema"
$rbSystem.Checked = ($themeSettings.Theme -eq "System")
$rbSystem.Add_CheckedChanged({ if($rbSystem.Checked) { Set-Theme "System"; Refresh-UI; Save-State; } })
$grpTheme.Controls.Add($rbSystem)

# Controles para la Fuente
$lblFont = New-Object System.Windows.Forms.Label
$lblFont.Location = New-Object System.Drawing.Point(10, 60)
$lblFont.Size = New-Object System.Drawing.Size(100, 20)
$lblFont.Text = "Fuente:"
$grpTheme.Controls.Add($lblFont)

$cmbFonts = New-Object System.Windows.Forms.ComboBox
$cmbFonts.Location = New-Object System.Drawing.Point(120, 60)
$cmbFonts.Size = New-Object System.Drawing.Size(220, 25)
$cmbFonts.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
[System.Drawing.FontFamily]::Families | ForEach-Object { [void]$cmbFonts.Items.Add($_.Name) }
$cmbFonts.SelectedItem = $themeSettings.FontFamily
$cmbFonts.Add_SelectionChangeCommitted({
    Set-AppFont -fontFamily $cmbFonts.SelectedItem -fontSize $themeSettings.FontSize
    Refresh-UI
    Save-State # Guardar estado
})
$grpTheme.Controls.Add($cmbFonts)

$lblFontSize = New-Object System.Windows.Forms.Label
$lblFontSize.Location = New-Object System.Drawing.Point(10, 95)
$lblFontSize.Size = New-Object System.Drawing.Size(100, 20)
$lblFontSize.Text = "Tamaño:"
$grpTheme.Controls.Add($lblFontSize)

$cmbFontSizes = New-Object System.Windows.Forms.ComboBox
$cmbFontSizes.Location = New-Object System.Drawing.Point(120, 95)
$cmbFontSizes.Size = New-Object System.Drawing.Size(70, 25)
$cmbFontSizes.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
@(8, 9, 10, 11, 12, 14, 16) | ForEach-Object { [void]$cmbFontSizes.Items.Add($_) }
$cmbFontSizes.SelectedItem = $themeSettings.FontSize
$cmbFontSizes.Add_SelectionChangeCommitted({
    Set-AppFont -fontFamily $themeSettings.FontFamily -fontSize $cmbFontSizes.SelectedItem
    Refresh-UI
    Save-State # Guardar estado
})
$grpTheme.Controls.Add($cmbFontSizes)

# Controles para el Idioma
$lblLanguage = New-Object System.Windows.Forms.Label
$lblLanguage.Location = New-Object System.Drawing.Point(10, 130)
$lblLanguage.Size = New-Object System.Drawing.Size(100, 20)
$lblLanguage.Text = "Idioma:" # Se traducirá después
$grpTheme.Controls.Add($lblLanguage)

$cmbLanguages = New-Object System.Windows.Forms.ComboBox
$cmbLanguages.Location = New-Object System.Drawing.Point(120, 130)
$cmbLanguages.Size = New-Object System.Drawing.Size(220, 25)
$cmbLanguages.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$languageMap = @{
    es = "Español";
    en = "English";
    pt = "Português";
    zh = "中文 (Chino)";
    ja = "日本語 (Japonés)";
}
$languageMap.GetEnumerator() | ForEach-Object { [void]$cmbLanguages.Items.Add($_.Value) }
$cmbLanguages.SelectedItem = $languageMap[$themeSettings.Language]

$cmbLanguages.Add_SelectionChangeCommitted({
    $selectedLangName = $cmbLanguages.SelectedItem
    $selectedLangCode = ($languageMap.GetEnumerator() | Where-Object { $_.Value -eq $selectedLangName }).Key
    Set-Language -langCode $selectedLangCode
    Refresh-UI
    Save-State # Guardar estado
})
$grpTheme.Controls.Add($cmbLanguages)
# --- FIN: Grupo de Configuración de Tema y Fuente ---

# --- INICIO: Grupo de Contacto ---
$grpContact = New-Object System.Windows.Forms.GroupBox
$grpContact.Location = New-Object System.Drawing.Point(490, 500) # Columna 2, Fila 3
$grpContact.Size = New-Object System.Drawing.Size(470, 100) 
$grpContact.Text = "Contacto"
$form.Controls.Add($grpContact)

# Rutas de los iconos
$discordIconPath = Join-Path $PSScriptRoot "..\..\assets\discord.png"
$githubIconPath = Join-Path $PSScriptRoot "..\..\assets\github.png"

# Controladores de clic
$discordClickHandler = {
    try { Start-Process "https://discordapp.com/users/995937284190916713" }
    catch { Write-Warning "No se pudo abrir el enlace de Discord: $_" }
}
$githubClickHandler = {
    try { Start-Process "https://github.com/andr3xcl/" }
    catch { Write-Warning "No se pudo abrir el enlace de GitHub: $_" }
}

# Fila de Discord
if (Test-Path $discordIconPath) {
    $picDiscord = New-Object System.Windows.Forms.PictureBox
    $picDiscord.Location = New-Object System.Drawing.Point(15, 30)
    $picDiscord.Size = New-Object System.Drawing.Size(24, 24)
    $picDiscord.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
    $picDiscord.Image = [System.Drawing.Image]::FromFile($discordIconPath)
    $picDiscord.Cursor = [System.Windows.Forms.Cursors]::Hand
    $picDiscord.Add_Click($discordClickHandler)
    $grpContact.Controls.Add($picDiscord)
}

$lnkDiscord = New-Object System.Windows.Forms.LinkLabel
$lnkDiscord.Text = "Discord: Andresito_20"
$lnkDiscord.Location = New-Object System.Drawing.Point(46, 35)
$lnkDiscord.AutoSize = $true
$lnkDiscord.LinkColor = [System.Drawing.Color]::FromArgb(88, 101, 242)
$lnkDiscord.Add_LinkClicked($discordClickHandler)
$grpContact.Controls.Add($lnkDiscord)

# Fila de GitHub
if (Test-Path $githubIconPath) {
    $picGitHub = New-Object System.Windows.Forms.PictureBox
    $picGitHub.Location = New-Object System.Drawing.Point(15, 62)
    $picGitHub.Size = New-Object System.Drawing.Size(24, 24)
    $picGitHub.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
    $picGitHub.Image = [System.Drawing.Image]::FromFile($githubIconPath)
    $picGitHub.Cursor = [System.Windows.Forms.Cursors]::Hand
    $picGitHub.Add_Click($githubClickHandler)
    $grpContact.Controls.Add($picGitHub)
}

$lnkGitHub = New-Object System.Windows.Forms.LinkLabel
$lnkGitHub.Text = "GitHub: andr3xcl"
$lnkGitHub.Location = New-Object System.Drawing.Point(46, 67)
$lnkGitHub.AutoSize = $true
$lnkGitHub.LinkColor = [System.Drawing.Color]::Black 
$lnkGitHub.Add_LinkClicked($githubClickHandler)
$grpContact.Controls.Add($lnkGitHub)
# --- FIN: Grupo de Contacto ---

# --- INICIO: Grupo de Perfiles ---
# ELIMINADO
# --- FIN: Grupo de Perfiles ---

# Permitir doble clic en procesos para añadirlos a exclusiones
$lbRunningProcesses.Add_DoubleClick({
    if ($lbRunningProcesses.SelectedItem -ne $null) {
        $processName = $lbRunningProcesses.SelectedItem.ToString().ToLower()
        if (-not ($script:excludedApps -contains $processName)) {
            $script:excludedApps += $processName
            Save-Exclusions
            Refresh-Lists
        }
    }
})

# Evento cuando el formulario está completamente cargado
$form.Add_Shown({
    Write-Host "Formulario mostrado. Cargando listas y estados..."
    Refresh-Lists
    # Update-ProfileList # Eliminado
    # Leer el estado actual de la transparencia del shell y actualizar el checkbox
    $chkShellTransparency.Checked = Get-GlobalShellTransparency
    [System.Windows.Forms.Application]::DoEvents()
})

# Botón para actualizar
$btnRefreshProcesses = New-Object System.Windows.Forms.Button
$btnRefreshProcesses.Location = New-Object System.Drawing.Point(370, 145)
$btnRefreshProcesses.Size = New-Object System.Drawing.Size(90, 25)
$btnRefreshProcesses.Text = "Actualizar"
$btnRefreshProcesses.Add_Click({
    Write-Host "Botón 'Actualizar' presionado. Refrescando listas..."
    Refresh-Lists
})
$grpExclusions.Controls.Add($btnRefreshProcesses)

# Cargar la configuración de temas primero
Load-ThemeSettings

# Refrescar toda la UI al inicio
Refresh-UI

# Cargar configuración de la app
Load-Settings

# Asegurar que la configuración inicial se guarde si no existe
if (-not (Test-Path $configFilePath)) {
    Save-Settings
}

# Configurar los trackbars con los valores cargados
$trackTransparency.Value = $script:transparencyLevel
$lblTransparencyValue.Text = "$($script:transparencyLevel) / 255"
$trackTaskbarTransparency.Value = $script:taskbarTransparencyLevel
$lblTaskbarTransparencyValue.Text = "$($script:taskbarTransparencyLevel) / 255"

# Sincronizar los radio buttons del modo con el estado cargado
$rbGlobalMode.Checked = ($script:transparencyMode -eq 'Global')
$rbIntelligentMode.Checked = ($script:transparencyMode -eq 'Intelligent')
$rbIntelligentInverseMode.Checked = ($script:transparencyMode -eq 'Intelligent-Inverse')

# Establecer el estado inicial de los botones de proceso
Update-ProcessStateUI

# Ocultar la ventana principal al inicio
$form.Hide()

# Mostrar mensaje de inicio en el system tray
$notifyIcon.ShowBalloonTip(
    3000,
    "Control de Transparencia",
    "La aplicación se está ejecutando en segundo plano. Haz doble clic en el icono para configurar.",
    [System.Windows.Forms.ToolTipIcon]::Info
)

# Iniciar el bucle de mensajes
[System.Windows.Forms.Application]::Run($form) 



# Esto es un ejemplo programandooooooooooo

# Esto es otro ejemplo programando :)