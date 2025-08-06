# Littlegods Utility Transparent Desktop

Una aplicación completa para Windows que permite controlar la transparencia de ventanas de manera inteligente con una interfaz gráfica moderna y múltiples modos de funcionamiento.

## Estructura del Proyecto

```
├── src/
│   ├── core/
│   │   └── WindowTransparency.ps1     # Motor principal de transparencia
│   ├── ui/
│   │   ├── TransparencyControl.ps1    # Interfaz gráfica principal
│   │   └── ThemeManager.ps1           # Sistema de temas y fuentes
│   └── utils/
│       ├── TaskbarTransparency.ps1    # Control de transparencia de barra de tareas
│       └── ShellEffects.ps1           # Efectos globales del sistema
├── config/                            # Archivos de configuración XML
├── assets/                            # Iconos y recursos gráficos
├── tools/                             # Herramientas de configuración y pruebas
├── Start.cmd                          # Punto de entrada principal
└── README.md
```

## Características Principales

### Modos de Transparencia
- **Global**: Todas las ventanas transparentes
- **Inteligente**: Solo ventanas sin foco son transparentes  
- **Inteligente Inverso**: Solo la ventana con foco es transparente

### Interfaz Multiidioma
- Español, Inglés, Portugués, Chino, Japonés
- Detección automática del idioma del sistema

### Sistema de Temas
- Tema claro, oscuro y automático (sigue el tema del sistema)
- Fuentes personalizables
- Interfaz moderna con colores adaptativos

## Instrucciones de uso

## Instalación y Uso

### Instalación Rápida

1. Ejecuta PowerShell como administrador
2. Permite la ejecución de scripts:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Ejecuta la aplicación:
   ```cmd
   Start.cmd
   ```

### Configuración de Autoarranque

Para que se inicie automáticamente con Windows:
```powershell
.\tools\ConfigurarAutoarranque.ps1
```

### Verificación del Sistema

Para verificar que todos los archivos están correctos:
```powershell
.\tools\Test-Transparency.ps1
```

## Gestión Avanzada

### Exclusiones de Aplicaciones
- Lista personalizable de aplicaciones excluidas de la transparencia
- Interfaz gráfica para agregar/quitar exclusiones
- Detección automática de procesos en ejecución

### Control de Transparencia
- Control independiente de transparencia de barra de tareas
- Efectos de transparencia globales del sistema (Menú Inicio, notificaciones)
- Niveles de transparencia ajustables (0-255)

### Configuración
- Icono en bandeja del sistema con menú contextual
- Prevención de múltiples instancias
- Configuración persistente en archivos XML

## Desinstalación

Para desinstalar completamente:
1. Detén la aplicación desde la bandeja del sistema
2. Elimina el acceso directo de autoarranque:
   ```
   %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Littlegods Utility Transparent Desktop.lnk
   ```
3. Elimina la carpeta del proyecto

## Tecnologías

- **PowerShell** con Windows Forms para la GUI
- **Windows API** (user32.dll) para manipulación de ventanas  
- **Registro de Windows** para configuraciones del sistema
- **XML** para persistencia de configuraciones
- **Mutex** para control de instancia única

## Notas Técnicas

- Utiliza las API de Windows para modificar ventanas de forma segura
- Optimización de rendimiento con cache de procesos
- Manejo robusto de errores y validaciones
- Compatible con Windows 10/11 