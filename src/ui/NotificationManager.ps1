# NotificationManager.ps1
# Sistema avanzado de notificaciones y alertas

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Configuración de notificaciones
$notificationConfig = @{
    ShowStartup       = $true
    ShowModeChanges   = $true
    ShowErrors        = $true
    ShowHotkeyActions = $true
    Duration          = 3000
    Position          = "BottomRight" # TopLeft, TopRight, BottomLeft, BottomRight
}

function Show-CustomNotification {
    param(
        [string]$Title,
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Type = "Info",
        [int]$Duration = 3000,
        [scriptblock]$OnClick = $null
    )
    
    # Crear formulario de notificación personalizada
    $notificationForm = New-Object System.Windows.Forms.Form
    $notificationForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $notificationForm.ShowInTaskbar = $false
    $notificationForm.TopMost = $true
    $notificationForm.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
    $notificationForm.Size = New-Object System.Drawing.Size(350, 100)
    
    # Colores según el tipo
    $colors = switch ($Type) {
        "Info" { @{ Back = [System.Drawing.Color]::FromArgb(52, 152, 219); Text = [System.Drawing.Color]::White } }
        "Success" { @{ Back = [System.Drawing.Color]::FromArgb(46, 204, 113); Text = [System.Drawing.Color]::White } }
        "Warning" { @{ Back = [System.Drawing.Color]::FromArgb(241, 196, 15); Text = [System.Drawing.Color]::Black } }
        "Error" { @{ Back = [System.Drawing.Color]::FromArgb(231, 76, 60); Text = [System.Drawing.Color]::White } }
    }
    
    $notificationForm.BackColor = $colors.Back
    
    # Título
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = $Title
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $titleLabel.ForeColor = $colors.Text
    $titleLabel.Location = New-Object System.Drawing.Point(15, 10)
    $titleLabel.Size = New-Object System.Drawing.Size(320, 25)
    $notificationForm.Controls.Add($titleLabel)
    
    # Mensaje
    $messageLabel = New-Object System.Windows.Forms.Label
    $messageLabel.Text = $Message
    $messageLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $messageLabel.ForeColor = $colors.Text
    $messageLabel.Location = New-Object System.Drawing.Point(15, 35)
    $messageLabel.Size = New-Object System.Drawing.Size(320, 50)
    $notificationForm.Controls.Add($messageLabel)
    
    # Botón de cerrar
    $closeButton = New-Object System.Windows.Forms.Button
    $closeButton.Text = "×"
    $closeButton.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $closeButton.ForeColor = $colors.Text
    $closeButton.BackColor = [System.Drawing.Color]::Transparent
    $closeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $closeButton.FlatAppearance.BorderSize = 0
    $closeButton.Location = New-Object System.Drawing.Point(315, 5)
    $closeButton.Size = New-Object System.Drawing.Size(30, 30)
    $closeButton.Add_Click({ $notificationForm.Close() })
    $notificationForm.Controls.Add($closeButton)
    
    # Posicionar la notificación
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
    switch ($notificationConfig.Position) {
        "TopRight" { 
            $notificationForm.Location = New-Object System.Drawing.Point(
                ($screen.Width - $notificationForm.Width - 20), 
                20
            )
        }
        "BottomRight" { 
            $notificationForm.Location = New-Object System.Drawing.Point(
                ($screen.Width - $notificationForm.Width - 20), 
                ($screen.Height - $notificationForm.Height - 20)
            )
        }
        "TopLeft" { 
            $notificationForm.Location = New-Object System.Drawing.Point(20, 20)
        }
        "BottomLeft" { 
            $notificationForm.Location = New-Object System.Drawing.Point(
                20, 
                ($screen.Height - $notificationForm.Height - 20)
            )
        }
    }
    
    # Evento de clic si se proporciona
    if ($OnClick) {
        $notificationForm.Add_Click($OnClick)
        $titleLabel.Add_Click($OnClick)
        $messageLabel.Add_Click($OnClick)
        $notificationForm.Cursor = [System.Windows.Forms.Cursors]::Hand
    }
    
    # Timer para auto-cerrar
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = $Duration
    $timer.Add_Tick({
            $notificationForm.Close()
            $timer.Dispose()
        })
    $timer.Start()
    
    # Mostrar con animación
    $notificationForm.Opacity = 0
    $notificationForm.Show()
    
    # Animación de fade-in
    $fadeTimer = New-Object System.Windows.Forms.Timer
    $fadeTimer.Interval = 50
    $fadeTimer.Add_Tick({
            if ($notificationForm.Opacity -lt 0.9) {
                $notificationForm.Opacity += 0.1
            }
            else {
                $fadeTimer.Stop()
                $fadeTimer.Dispose()
            }
        })
    $fadeTimer.Start()
}

function Show-TransparencyStatusNotification {
    param([bool]$IsActive)
    
    if (-not $notificationConfig.ShowModeChanges) { return }
    
    $type = if ($IsActive) { "Success" } else { "Info" }
    $message = if ($IsActive) { "Transparencia activada" } else { "Transparencia desactivada" }
    
    Show-CustomNotification -Title "Littlegods Transparency" -Message $message -Type $type
}

function Show-ErrorNotification {
    param([string]$ErrorMessage)
    
    if (-not $notificationConfig.ShowErrors) { return }
    
    Show-CustomNotification -Title "Error" -Message $ErrorMessage -Type "Error" -Duration 5000
}

function Show-HotkeyNotification {
    param([string]$Action, [string]$Value = "")
    
    if (-not $notificationConfig.ShowHotkeyActions) { return }
    
    $message = if ($Value) { "$Action`: $Value" } else { $Action }
    Show-CustomNotification -Title "Hotkey" -Message $message -Type "Info" -Duration 2000
}

function Set-NotificationConfig {
    param(
        [bool]$ShowStartup = $null,
        [bool]$ShowModeChanges = $null,
        [bool]$ShowErrors = $null,
        [bool]$ShowHotkeyActions = $null,
        [int]$Duration = $null,
        [ValidateSet("TopLeft", "TopRight", "BottomLeft", "BottomRight")]
        [string]$Position = $null
    )
    
    if ($null -ne $ShowStartup) { $notificationConfig.ShowStartup = $ShowStartup }
    if ($null -ne $ShowModeChanges) { $notificationConfig.ShowModeChanges = $ShowModeChanges }
    if ($null -ne $ShowErrors) { $notificationConfig.ShowErrors = $ShowErrors }
    if ($null -ne $ShowHotkeyActions) { $notificationConfig.ShowHotkeyActions = $ShowHotkeyActions }
    if ($null -ne $Duration) { $notificationConfig.Duration = $Duration }
    if ($null -ne $Position) { $notificationConfig.Position = $Position }
}