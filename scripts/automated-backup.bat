@echo off
REM ============================================
REM Automated Daily Backup Script
REM ============================================
REM Add this to Windows Task Scheduler for automated backups

setlocal enabledelayedexpansion

REM Configuration
set PROJECT_DIR=C:\projects\purchase-requisition-system
set BACKUP_DIR=C:\backups\purchase-requisition-system
set RETENTION_DAYS=30
set LOG_FILE=%BACKUP_DIR%\backup-log.txt

REM Create directories if they don't exist
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
if not exist "%BACKUP_DIR%\daily" mkdir "%BACKUP_DIR%\daily"
if not exist "%BACKUP_DIR%\weekly" mkdir "%BACKUP_DIR%\weekly"
if not exist "%BACKUP_DIR%\monthly" mkdir "%BACKUP_DIR%\monthly"

REM Get current date and time
set TIMESTAMP=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set DAY_OF_WEEK=%date:~0,3%
set DAY_OF_MONTH=%date:~0,2%

echo ========================================= >> "%LOG_FILE%"
echo Automated Backup - %date% %time% >> "%LOG_FILE%"
echo ========================================= >> "%LOG_FILE%"

REM Change to project directory
cd /d "%PROJECT_DIR%"

REM Determine backup type
set BACKUP_TYPE=daily
if "%DAY_OF_WEEK%"=="Sun" set BACKUP_TYPE=weekly
if "%DAY_OF_MONTH%"=="01" set BACKUP_TYPE=monthly

echo Backup Type: %BACKUP_TYPE% >> "%LOG_FILE%"

REM Create backup name
set BACKUP_NAME=prs-auto-%BACKUP_TYPE%-%TIMESTAMP%

REM Get current git tag/version
for /f "tokens=*" %%a in ('git describe --tags --abbrev^=0 2^>nul') do set GIT_VERSION=%%a
if "%GIT_VERSION%"=="" set GIT_VERSION=untagged

echo Version: %GIT_VERSION% >> "%LOG_FILE%"
echo Backup Name: %BACKUP_NAME% >> "%LOG_FILE%"

REM Create backup directory
set BACKUP_PATH=%BACKUP_DIR%\%BACKUP_TYPE%\%BACKUP_NAME%
mkdir "%BACKUP_PATH%"

REM Backup source code
echo Backing up source code... >> "%LOG_FILE%"
xcopy /E /I /H /Y "%PROJECT_DIR%\backend" "%BACKUP_PATH%\backend" > nul
xcopy /E /I /H /Y "%PROJECT_DIR%\frontend" "%BACKUP_PATH%\frontend" > nul
xcopy /E /I /H /Y "%PROJECT_DIR%\scripts" "%BACKUP_PATH%\scripts" > nul

REM Copy important files
copy "%PROJECT_DIR%\package.json" "%BACKUP_PATH%\" > nul 2>&1
copy "%PROJECT_DIR%\package-lock.json" "%BACKUP_PATH%\" > nul 2>&1
copy "%PROJECT_DIR%\README.md" "%BACKUP_PATH%\" > nul 2>&1
copy "%PROJECT_DIR%\.gitignore" "%BACKUP_PATH%\" > nul 2>&1

REM Backup database (CRITICAL)
echo Backing up database... >> "%LOG_FILE%"
if exist "%PROJECT_DIR%\backend\requisitions.db" (
    copy "%PROJECT_DIR%\backend\requisitions.db" "%BACKUP_PATH%\backend\" > nul
    echo - requisitions.db backed up >> "%LOG_FILE%"
)
if exist "%PROJECT_DIR%\backend\purchase_requisition.db" (
    copy "%PROJECT_DIR%\backend\purchase_requisition.db" "%BACKUP_PATH%\backend\" > nul
    echo - purchase_requisition.db backed up >> "%LOG_FILE%"
)

REM Backup uploads directory
echo Backing up uploads... >> "%LOG_FILE%"
if exist "%PROJECT_DIR%\backend\uploads" (
    xcopy /E /I /Y "%PROJECT_DIR%\backend\uploads" "%BACKUP_PATH%\backend\uploads" > nul
)

REM Backup environment file
if exist "%PROJECT_DIR%\backend\.env" (
    copy "%PROJECT_DIR%\backend\.env" "%BACKUP_PATH%\backend\" > nul
    echo - .env backed up >> "%LOG_FILE%"
)

REM Create backup info
(
    echo Automated Backup Information
    echo ============================
    echo.
    echo Backup Date: %date% %time%
    echo Backup Type: %BACKUP_TYPE%
    echo Git Version: %GIT_VERSION%
    echo Backup Name: %BACKUP_NAME%
    echo.
    echo This is an automated backup created by the backup scheduler.
    echo.
    echo To restore this backup:
    echo 1. Stop the application servers
    echo 2. Copy contents to your project directory
    echo 3. Run: cd backend ^&^& npm install
    echo 4. Run: node scripts/hashPasswords.js
    echo 5. Start the application
) > "%BACKUP_PATH%\BACKUP_INFO.txt"

REM Compress backup
echo Creating compressed archive... >> "%LOG_FILE%"
powershell -command "Compress-Archive -Path '%BACKUP_PATH%' -DestinationPath '%BACKUP_PATH%.zip' -Force"

REM Calculate size
for %%A in ("%BACKUP_PATH%.zip") do set SIZE=%%~zA
set /a SIZE_MB=%SIZE% / 1048576

echo Backup size: %SIZE_MB% MB >> "%LOG_FILE%"
echo Backup completed successfully >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

REM Clean up old backups (older than retention days)
echo Cleaning up old backups... >> "%LOG_FILE%"
forfiles /P "%BACKUP_DIR%\daily" /S /M *.zip /D -%RETENTION_DAYS% /C "cmd /c del @path" 2>nul
forfiles /P "%BACKUP_DIR%\daily" /S /M prs-* /D -%RETENTION_DAYS% /C "cmd /c if @isdir==TRUE rmdir /S /Q @path" 2>nul

REM Keep weekly backups for 90 days
forfiles /P "%BACKUP_DIR%\weekly" /S /M *.zip /D -90 /C "cmd /c del @path" 2>nul
forfiles /P "%BACKUP_DIR%\weekly" /S /M prs-* /D -90 /C "cmd /c if @isdir==TRUE rmdir /S /Q @path" 2>nul

echo Cleanup completed >> "%LOG_FILE%"
echo ========================================= >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

exit /b 0
