# ThemeManager.ps1
# Script principal para gestionar los temas, fuentes e idiomas en la aplicación

# Funciones de colores de tema integradas
function Get-ThemeColors {
    $currentTheme = $script:themeSettings.Theme
    
    # Detectar tema del sistema si está configurado como "System"
    if ($currentTheme -eq "System") {
        try {
            $registryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
            $appsUseLightTheme = Get-ItemProperty -Path $registryPath -Name "AppsUseLightTheme" -ErrorAction SilentlyContinue
            $currentTheme = if ($appsUseLightTheme.AppsUseLightTheme -eq 1) { "Light" } else { "Dark" }
        } catch {
            $currentTheme = "Light"  # Fallback
        }
    }
    
    if ($currentTheme -eq "Dark") {
        return @{
            BackColor = [System.Drawing.Color]::FromArgb(32, 32, 32)
            ForeColor = [System.Drawing.Color]::White
            ButtonBackColor = [System.Drawing.Color]::FromArgb(64, 64, 64)
            ButtonForeColor = [System.Drawing.Color]::White
            GroupBoxBackColor = [System.Drawing.Color]::FromArgb(32, 32, 32)
            GroupBoxForeColor = [System.Drawing.Color]::White
            ListBoxBackColor = [System.Drawing.Color]::FromArgb(48, 48, 48)
            ListBoxForeColor = [System.Drawing.Color]::White
            TextBoxBackColor = [System.Drawing.Color]::FromArgb(48, 48, 48)
            TextBoxForeColor = [System.Drawing.Color]::White
        }
    } else {
        return @{
            BackColor = [System.Drawing.Color]::White
            ForeColor = [System.Drawing.Color]::Black
            ButtonBackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
            ButtonForeColor = [System.Drawing.Color]::Black
            GroupBoxBackColor = [System.Drawing.Color]::White
            GroupBoxForeColor = [System.Drawing.Color]::Black
            ListBoxBackColor = [System.Drawing.Color]::White
            ListBoxForeColor = [System.Drawing.Color]::Black
            TextBoxBackColor = [System.Drawing.Color]::White
            TextBoxForeColor = [System.Drawing.Color]::Black
        }
    }
}

function Apply-ThemeToControls {
    param(
        [System.Windows.Forms.Control]$control,
        [hashtable]$colors
    )
    
    foreach ($childControl in $control.Controls) {
        switch ($childControl.GetType().Name) {
            "Button" {
                $childControl.BackColor = $colors.ButtonBackColor
                $childControl.ForeColor = $colors.ButtonForeColor
                $childControl.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                $childControl.FlatAppearance.BorderColor = $colors.ButtonForeColor
            }
            "GroupBox" {
                $childControl.BackColor = $colors.GroupBoxBackColor
                $childControl.ForeColor = $colors.GroupBoxForeColor
            }
            "ListBox" {
                $childControl.BackColor = $colors.ListBoxBackColor
                $childControl.ForeColor = $colors.ListBoxForeColor
            }
            "TextBox" {
                $childControl.BackColor = $colors.TextBoxBackColor
                $childControl.ForeColor = $colors.TextBoxForeColor
            }
            "ComboBox" {
                $childControl.BackColor = $colors.TextBoxBackColor
                $childControl.ForeColor = $colors.TextBoxForeColor
            }
            "CheckBox" {
                $childControl.BackColor = $colors.BackColor
                $childControl.ForeColor = $colors.ForeColor
            }
            "RadioButton" {
                $childControl.BackColor = $colors.BackColor
                $childControl.ForeColor = $colors.ForeColor
            }
            "Label" {
                $childControl.BackColor = $colors.BackColor
                $childControl.ForeColor = $colors.ForeColor
            }
            "LinkLabel" {
                $childControl.BackColor = $colors.BackColor
                # Mantener el color original del link
            }
        }
        
        # Aplicar tema recursivamente a los controles hijos
        if ($childControl.Controls.Count -gt 0) {
            Apply-ThemeToControls -control $childControl -colors $colors
        }
    }
}

# Ruta del archivo de configuración de temas
$themeSettingsPath = Join-Path $PSScriptRoot "..\..\config\ThemeSettings.xml"

# Valores por defecto
$defaultTheme = "System"  # Opciones: Light, Dark, System
$defaultFontFamily = "Segoe UI"
$defaultFontSize = 9
$defaultLanguage = "es" # Español por defecto

# Estructura para almacenar la configuración actual
$script:themeSettings = @{
    Theme = $defaultTheme
    FontFamily = $defaultFontFamily
    FontSize = $defaultFontSize
    Language = $defaultLanguage
}

# Función para cargar la configuración de temas
function Load-ThemeSettings {
    if (Test-Path $themeSettingsPath) {
        try {
            $settings = Import-Clixml -Path $themeSettingsPath
            if ($settings.Theme) { $script:themeSettings.Theme = $settings.Theme }
            if ($settings.FontFamily) { $script:themeSettings.FontFamily = $settings.FontFamily }
            if ($settings.FontSize) { $script:themeSettings.FontSize = $settings.FontSize }
            if ($settings.Language) { $script:themeSettings.Language = $settings.Language }
            
            Write-Host "Configuración de tema cargada correctamente"
        } catch {
            Write-Host "Error al cargar la configuración de tema: $_"
        }
    } else {
        Write-Host "No se encontró configuración de tema, usando valores predeterminados"
        Save-ThemeSettings
    }
}

# Función para guardar la configuración de temas
function Save-ThemeSettings {
    try {
        Export-Clixml -Path $themeSettingsPath -InputObject $script:themeSettings -Force
        Write-Host "Configuración de tema guardada correctamente"
    } catch {
        Write-Host "Error al guardar la configuración de tema: $_"
    }
}

# Función para aplicar el tema a un formulario y sus controles
function Apply-Theme {
    param([System.Windows.Forms.Form]$form)
    
    # Obtener la configuración de colores según el tema
    $colors = Get-ThemeColors
    
    # Aplicar colores al formulario
    $form.BackColor = $colors.BackColor
    $form.ForeColor = $colors.ForeColor
    
    # Aplicar la fuente al formulario
    $fontFamily = if ([System.Drawing.FontFamily]::Families | Where-Object { $_.Name -eq $script:themeSettings.FontFamily }) {
        $script:themeSettings.FontFamily
    } else {
        $defaultFontFamily  # Usar fuente predeterminada si la configurada no está disponible
    }
    
    $form.Font = New-Object System.Drawing.Font($fontFamily, $script:themeSettings.FontSize)
    
    # Aplicar tema a los controles del formulario
    Apply-ThemeToControls -control $form -colors $colors
}

# Función para cambiar el tema
function Set-Theme {
    param([string]$theme)
    
    if ($theme -in @("Light", "Dark", "System")) {
        $script:themeSettings.Theme = $theme
        Save-ThemeSettings
        return $true
    }
    return $false
}

# Función para cambiar el idioma
function Set-Language {
    param([string]$langCode)
    
    # Aquí puedes añadir una validación de los códigos de idioma si es necesario
    $script:themeSettings.Language = $langCode
    Save-ThemeSettings
}

# Función para cambiar la fuente
function Set-AppFont {
    param(
        [string]$fontFamily,
        [int]$fontSize = $script:themeSettings.FontSize
    )
    
    # Verificar si la fuente está disponible
    $fontExists = [System.Drawing.FontFamily]::Families | Where-Object { $_.Name -eq $fontFamily }
    
    if ($fontExists) {
        $script:themeSettings.FontFamily = $fontFamily
        $script:themeSettings.FontSize = $fontSize
        Save-ThemeSettings
        return $true
    } elseif ($fontFamily -eq "Default") {
        # Restablecer a la fuente predeterminada
        $script:themeSettings.FontFamily = $defaultFontFamily
        $script:themeSettings.FontSize = $defaultFontSize
        Save-ThemeSettings
        return $true
    }
    return $false
}

# Función para cambiar la configuración de codificación
function Set-EncodingMode {
    param([bool]$useSystemEncoding)
    
    $script:themeSettings.UseSystemEncoding = $useSystemEncoding
    Save-ThemeSettings
}

# Inicializar
Load-ThemeSettings