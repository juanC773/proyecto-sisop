# Script de Administracion para Windows - Proyecto Final Sistemas Operacionales
# Universidad ICESI

# Funcion para mostrar el menu principal
function Show-MainMenu {
    Clear-Host
    Write-Host "====================================================="
    Write-Host "         HERRAMIENTA DE ADMINISTRACION WINDOWS       "
    Write-Host "====================================================="
    Write-Host "1. Procesos"
    Write-Host "2. Usuarios"
    Write-Host "3. Backup"
    Write-Host "4. Apagar el equipo"
    Write-Host "5. Salir"
    Write-Host "====================================================="
    $option = Read-Host "Seleccione una opcion"
    return $option
}

# Funcion para el menu de procesos
function Show-ProcessMenu {
    Clear-Host
    Write-Host "====================================================="
    Write-Host "                  GESTION DE PROCESOS                "
    Write-Host "====================================================="
    Write-Host "1. Listar procesos"
    Write-Host "2. 5 procesos que mas consumen procesador"
    Write-Host "3. 5 procesos que mas consumen memoria"
    Write-Host "4. Terminar un proceso"
    Write-Host "5. Volver al menu principal"
    Write-Host "====================================================="
    $option = Read-Host "Seleccione una opcion"
    return $option
}

# Funcion para el menu de usuarios
function Show-UserMenu {
    Clear-Host
    Write-Host "====================================================="
    Write-Host "                  GESTION DE USUARIOS                "
    Write-Host "====================================================="
    Write-Host "1. Listar los usuarios del sistema"
    Write-Host "2. Listado de usuarios segun vejez de contrasena"
    Write-Host "3. Cambiar la contrasena de un usuario"
    Write-Host "4. Volver al menu principal"
    Write-Host "====================================================="
    $option = Read-Host "Seleccione una opcion"
    return $option
}

# Funcion para listar todos los procesos
function List-AllProcesses {
    Clear-Host
    Write-Host "====================================================="
    Write-Host "                LISTADO DE PROCESOS                  "
    Write-Host "====================================================="
    Get-Process | Format-Table Id, ProcessName, CPU, WorkingSet -AutoSize
    Write-Host "====================================================="
    Read-Host "Presione Enter para continuar"
}

# Funcion para mostrar los 5 procesos que mas consumen CPU
function List-TopCPUProcesses {
    Clear-Host
    Write-Host "====================================================="
    Write-Host "         5 PROCESOS QUE MAS CONSUMEN CPU             "
    Write-Host "====================================================="
    Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 5 | Format-Table Id, ProcessName, CPU -AutoSize
    Write-Host "====================================================="
    Read-Host "Presione Enter para continuar"
}

# Funcion para mostrar los 5 procesos que mas consumen memoria
function List-TopMemoryProcesses {
    Clear-Host
    Write-Host "====================================================="
    Write-Host "        5 PROCESOS QUE MAS CONSUMEN MEMORIA          "
    Write-Host "====================================================="
    Get-Process | Sort-Object -Property WorkingSet -Descending | Select-Object -First 5 | Format-Table Id, ProcessName, WorkingSet -AutoSize
    Write-Host "====================================================="
    Read-Host "Presione Enter para continuar"
}

# Funcion para terminar un proceso
function Kill-SelectedProcess {
    Clear-Host
    Write-Host "====================================================="
    Write-Host "                TERMINAR UN PROCESO                  "
    Write-Host "====================================================="
    $processId = Read-Host "Ingrese el ID del proceso a terminar"
    try {
        Stop-Process -Id $processId -Force -ErrorAction Stop
        Write-Host "Proceso con ID $processId terminado correctamente." -ForegroundColor Green
    }
    catch {
        Write-Host "Error al terminar el proceso." -ForegroundColor Red
    }
    Write-Host "====================================================="
    Read-Host "Presione Enter para continuar"
}

# Funcion para listar todos los usuarios del sistema
function List-AllUsers {
    Clear-Host
    Write-Host "====================================================="
    Write-Host "             LISTADO DE USUARIOS DEL SISTEMA         "
    Write-Host "====================================================="
    Get-LocalUser | Format-Table Name, Enabled, LastLogon, PasswordLastSet -AutoSize
    Write-Host "====================================================="
    Read-Host "Presione Enter para continuar"
}

# Funcion para listar usuarios segun vejez de contrasena
function List-UsersByPasswordAge {
    Clear-Host
    Write-Host "====================================================="
    Write-Host "        USUARIOS SEGUN VEJEZ DE CONTRASENA           "
    Write-Host "====================================================="
    Get-LocalUser | Where-Object {$_.PasswordLastSet} | Sort-Object -Property PasswordLastSet | 
    Format-Table Name, @{Name="PasswordAge(Days)"; Expression={(Get-Date) - $_.PasswordLastSet | Select-Object -ExpandProperty Days}}, PasswordLastSet -AutoSize
    Write-Host "====================================================="
    Read-Host "Presione Enter para continuar"
}

# Funcion para cambiar la contrasena de un usuario
function Change-UserPassword {
    Clear-Host
    Write-Host "====================================================="
    Write-Host "            CAMBIAR CONTRASENA DE USUARIO            "
    Write-Host "====================================================="
    $username = Read-Host "Ingrese el nombre del usuario"
    
    try {
        $user = Get-LocalUser -Name $username -ErrorAction Stop
        $newPassword = Read-Host "Ingrese la nueva contrasena" -AsSecureString
        Set-LocalUser -Name $username -Password $newPassword
        Write-Host "Contrasena cambiada correctamente para el usuario $username." -ForegroundColor Green
    }
    catch {
        Write-Host "Error al cambiar la contrasena." -ForegroundColor Red
    }
    
    Write-Host "====================================================="
    Read-Host "Presione Enter para continuar"
}

# Funcion para realizar backup del directorio de usuarios
function Backup-UsersDirectory {
    Clear-Host
    Write-Host "====================================================="
    Write-Host "             BACKUP DE DIRECTORIO DE USUARIOS        "
    Write-Host "====================================================="
    
    # Directorio de usuarios en Windows
    $sourceDir = "$env:SystemDrive\Users"
    
    # Solicitar al usuario el directorio destino para el backup
    $backupBaseDir = Read-Host "Ingrese la ruta para guardar el backup (Ej: D:\Backups)"
    
    # Verificar si existe el directorio, si no, crearlo
    if (-not (Test-Path -Path $backupBaseDir)) {
        try {
            New-Item -Path $backupBaseDir -ItemType Directory -Force | Out-Null
            Write-Host "Se ha creado el directorio $backupBaseDir" -ForegroundColor Green
        }
        catch {
            Write-Host "Error al crear el directorio de backup." -ForegroundColor Red
            Read-Host "Presione Enter para continuar"
            return
        }
    }
    
    # Crear nombre del archivo de backup con la fecha actual
    $date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $backupFileName = "users_backup_$date.zip"
    $backupFilePath = Join-Path -Path $backupBaseDir -ChildPath $backupFileName
    
    try {
        Write-Host "Iniciando backup del directorio de usuarios..."
        Write-Host "Origen: $sourceDir"
        Write-Host "Destino: $backupFilePath"
        
        # Realizar el backup utilizando Compress-Archive
        Compress-Archive -Path $sourceDir -DestinationPath $backupFilePath -CompressionLevel Optimal
        
        Write-Host "Backup completado exitosamente." -ForegroundColor Green
        Write-Host "Archivo de backup guardado en: $backupFilePath" -ForegroundColor Green
    }
    catch {
        Write-Host "Error al realizar el backup." -ForegroundColor Red
    }
    
    Write-Host "====================================================="
    Read-Host "Presione Enter para continuar"
}

# Funcion para programar el backup automatico
function Schedule-AutomaticBackup {
    Clear-Host
    Write-Host "====================================================="
    Write-Host "          PROGRAMAR BACKUP AUTOMATICO                "
    Write-Host "====================================================="
    
    $backupDir = Read-Host "Ingrese el directorio donde guardar los backups automaticos"
    
    # Verificar si existe el directorio, si no, crearlo
    if (-not (Test-Path -Path $backupDir)) {
        try {
            New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
            Write-Host "Se ha creado el directorio $backupDir" -ForegroundColor Green
        }
        catch {
            Write-Host "Error al crear el directorio de backup." -ForegroundColor Red
            Read-Host "Presione Enter para continuar"
            return
        }
    }
    
    # Obtener ruta completa del script actual
    $scriptPath = $PSCommandPath
    
    # Crear una tarea programada para ejecutar el backup a las 3:00 AM
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -BackupOnly -BackupDir `"$backupDir`""
    $trigger = New-ScheduledTaskTrigger -Daily -At 3AM
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd
    
    try {
        # Registrar la tarea programada
        Register-ScheduledTask -TaskName "UserDirectoryBackup" -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest -Force
        Write-Host "Backup automatico programado correctamente para ejecutarse todos los dias a las 3:00 AM." -ForegroundColor Green
    }
    catch {
        Write-Host "Error al programar el backup automatico." -ForegroundColor Red
    }
    
    Write-Host "====================================================="
    Read-Host "Presione Enter para continuar"
}

# Funcion para apagar el equipo
function Shutdown-Computer {
    Clear-Host
    Write-Host "====================================================="
    Write-Host "                 APAGAR EL EQUIPO                    "
    Write-Host "====================================================="
    $confirm = Read-Host "Esta seguro que desea apagar el equipo? (S/N)"
    
    if ($confirm -eq "S" -or $confirm -eq "s") {
        Write-Host "Apagando el equipo en 10 segundos..."
        Start-Sleep -Seconds 5
        Stop-Computer -Force
    }
    else {
        Write-Host "Operacion cancelada."
        Read-Host "Presione Enter para continuar"
    }
}

# Verificar si se solicita solo hacer backup (para la tarea programada)
if ($args.Contains("-BackupOnly") -and $args.Contains("-BackupDir")) {
    $backupDir = $args[$args.IndexOf("-BackupDir") + 1]
    
    # Directorio de usuarios en Windows
    $sourceDir = "$env:SystemDrive\Users"
    
    # Crear nombre del archivo de backup con la fecha actual
    $date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $backupFileName = "users_backup_$date.zip"
    $backupFilePath = Join-Path -Path $backupDir -ChildPath $backupFileName
    
    # Realizar el backup utilizando Compress-Archive
    Compress-Archive -Path $sourceDir -DestinationPath $backupFilePath -CompressionLevel Optimal
    
    # Escribir un log del backup
    $logPath = Join-Path -Path $backupDir -ChildPath "backup_log.txt"
    "Backup realizado el $(Get-Date) - Archivo: $backupFileName" | Out-File -FilePath $logPath -Append
    
    exit 0
}

# Menu principal del script
function Main {
    # Programar el backup automatico al iniciar el script
    # Schedule-AutomaticBackup # Comentado para pruebas iniciales
    
    while ($true) {
        $mainOption = Show-MainMenu
        
        switch ($mainOption) {
            # Menu de procesos
            1 {
                while ($true) {
                    $processOption = Show-ProcessMenu
                    
                    switch ($processOption) {
                        1 { List-AllProcesses }
                        2 { List-TopCPUProcesses }
                        3 { List-TopMemoryProcesses }
                        4 { Kill-SelectedProcess }
                        5 { break }
                        default { Write-Host "Opcion no valida" -ForegroundColor Red; Start-Sleep -Seconds 1 }
                    }
                    
                    if ($processOption -eq 5) {
                        break
                    }
                }
            }
            
            # Menu de usuarios
            2 {
                while ($true) {
                    $userOption = Show-UserMenu
                    
                    switch ($userOption) {
                        1 { List-AllUsers }
                        2 { List-UsersByPasswordAge }
                        3 { Change-UserPassword }
                        4 { break }
                        default { Write-Host "Opcion no valida" -ForegroundColor Red; Start-Sleep -Seconds 1 }
                    }
                    
                    if ($userOption -eq 4) {
                        break
                    }
                }
            }
            
            # Backup
            3 { Backup-UsersDirectory }
            
            # Apagar el equipo
            4 { Shutdown-Computer }
            
            # Salir del script
            5 { 
                Clear-Host
                Write-Host "Gracias por usar la herramienta de administracion."
                exit 0
            }
            
            default { Write-Host "Opcion no valida" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

# Iniciar el script
Main