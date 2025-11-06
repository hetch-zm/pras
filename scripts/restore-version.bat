@echo off
REM ============================================
REM Restore Version Script
REM ============================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo  Version Restore Utility
echo ========================================
echo.

REM Set backup directory
set BACKUP_DIR=..\purchase-requisition-backups

if "%1"=="" (
    echo Usage: restore-version.bat [backup-name]
    echo.
    echo Available backups:
    dir /B "%BACKUP_DIR%\*.zip" 2>nul
    echo.
    exit /b 1
)

set BACKUP_NAME=%1
set BACKUP_FILE=%BACKUP_DIR%\%BACKUP_NAME%.zip
set BACKUP_FOLDER=%BACKUP_DIR%\%BACKUP_NAME%

REM Check if backup exists
if not exist "%BACKUP_FILE%" (
    if not exist "%BACKUP_FOLDER%" (
        echo Error: Backup not found: %BACKUP_NAME%
        echo.
        echo Available backups:
        dir /B "%BACKUP_DIR%\*.zip" 2>nul
        exit /b 1
    )
)

echo ⚠️  WARNING: This will replace your current files!
echo.
echo Backup to restore: %BACKUP_NAME%
echo.
choice /C YN /M "Are you sure you want to continue"
if errorlevel 2 goto cancelled
if errorlevel 1 goto continue

:continue
echo.
echo Stopping servers (if running)...
taskkill /IM node.exe /F > nul 2>&1
taskkill /IM python.exe /F > nul 2>&1
timeout /t 2 > nul

echo.
echo Creating safety backup of current state...
set TIMESTAMP=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set SAFETY_BACKUP=%BACKUP_DIR%\safety-backup-%TIMESTAMP%
mkdir "%SAFETY_BACKUP%" > nul 2>&1
xcopy /E /I /H /Y . "%SAFETY_BACKUP%" > nul

echo.
echo Extracting backup...

if exist "%BACKUP_FILE%" (
    REM Extract from zip
    powershell -command "Expand-Archive -Path '%BACKUP_FILE%' -DestinationPath '%BACKUP_DIR%\temp_restore' -Force"
    set SOURCE_DIR=%BACKUP_DIR%\temp_restore
) else (
    REM Use existing folder
    set SOURCE_DIR=%BACKUP_FOLDER%
)

echo.
echo Restoring files...

REM Restore backend files
if exist "%SOURCE_DIR%\backend" (
    echo Restoring backend...
    xcopy /E /I /H /Y "%SOURCE_DIR%\backend\*" "backend\" > nul
)

REM Restore frontend files
if exist "%SOURCE_DIR%\frontend" (
    echo Restoring frontend...
    xcopy /E /I /H /Y "%SOURCE_DIR%\frontend\*" "frontend\" > nul
)

REM Restore root files
if exist "%SOURCE_DIR%\package.json" (
    echo Restoring root files...
    copy /Y "%SOURCE_DIR%\package.json" . > nul
    copy /Y "%SOURCE_DIR%\package-lock.json" . > nul 2>nul
    copy /Y "%SOURCE_DIR%\README.md" . > nul 2>nul
)

REM Clean up temp directory
if exist "%BACKUP_DIR%\temp_restore" (
    rmdir /S /Q "%BACKUP_DIR%\temp_restore"
)

echo.
echo Reinstalling dependencies...
cd backend
call npm install > nul 2>&1

echo.
echo Reinitializing database...
node scripts\hashPasswords.js

cd ..

echo.
echo ========================================
echo ✅ Restore completed successfully!
echo ========================================
echo.
echo Safety backup created at: %SAFETY_BACKUP%
echo.
echo Next steps:
echo 1. Start backend: cd backend ^&^& npm start
echo 2. Start frontend: cd frontend ^&^& python -m http.server 3000
echo.
echo Or use the quick start script if available.
echo.
exit /b 0

:cancelled
echo.
echo Restore cancelled.
exit /b 0
