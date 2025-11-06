@echo off
REM ============================================
REM Backup Version Script
REM ============================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo  Version Backup Utility
echo ========================================
echo.

REM Set backup directory
set BACKUP_DIR=..\purchase-requisition-backups
set TIMESTAMP=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%

REM Check if version is specified
if "%1"=="" (
    echo Backing up current working state...
    set VERSION=current
    set BACKUP_NAME=prs-backup-%TIMESTAMP%
) else (
    set VERSION=%1
    set BACKUP_NAME=prs-%VERSION%-%TIMESTAMP%
)

echo Version: %VERSION%
echo Backup name: %BACKUP_NAME%
echo.

REM Create backup directory if it doesn't exist
if not exist "%BACKUP_DIR%" (
    echo Creating backup directory: %BACKUP_DIR%
    mkdir "%BACKUP_DIR%"
)

REM Create version-specific backup
echo Creating backup...

if "%VERSION%"=="current" (
    REM Backup current working directory
    xcopy /E /I /H /Y . "%BACKUP_DIR%\%BACKUP_NAME%" > nul
    if errorlevel 1 (
        echo Error: Backup failed
        exit /b 1
    )
) else (
    REM Export specific git version
    git archive --format=zip --output="%BACKUP_DIR%\%BACKUP_NAME%-code.zip" %VERSION%
    if errorlevel 1 (
        echo Error: Version %VERSION% not found
        exit /b 1
    )

    REM Extract the zip to a folder
    powershell -command "Expand-Archive -Path '%BACKUP_DIR%\%BACKUP_NAME%-code.zip' -DestinationPath '%BACKUP_DIR%\%BACKUP_NAME%' -Force"
    del "%BACKUP_DIR%\%BACKUP_NAME%-code.zip"
)

REM Backup database separately (always from current)
echo Backing up database files...
if exist "backend\requisitions.db" (
    copy "backend\requisitions.db" "%BACKUP_DIR%\%BACKUP_NAME%\backend\" > nul
)
if exist "backend\purchase_requisition.db" (
    copy "backend\purchase_requisition.db" "%BACKUP_DIR%\%BACKUP_NAME%\backend\" > nul
)
if exist "purchase_requisition.db" (
    copy "purchase_requisition.db" "%BACKUP_DIR%\%BACKUP_NAME%\" > nul
)

REM Backup uploads directory
if exist "backend\uploads" (
    echo Backing up uploads directory...
    xcopy /E /I /Y "backend\uploads" "%BACKUP_DIR%\%BACKUP_NAME%\backend\uploads" > nul
)

REM Backup .env file
if exist "backend\.env" (
    echo Backing up environment configuration...
    copy "backend\.env" "%BACKUP_DIR%\%BACKUP_NAME%\backend\" > nul
)

REM Create backup info file
echo Creating backup info...
(
    echo Backup Information
    echo ==================
    echo.
    echo Backup Date: %date% %time%
    echo Version: %VERSION%
    echo Backup Name: %BACKUP_NAME%
    echo.
    echo Contents:
    echo - Source code
    echo - Database files
    echo - Uploads directory
    echo - Environment configuration
    echo.
    echo To restore:
    echo 1. Stop the application servers
    echo 2. Copy contents from this backup to your project directory
    echo 3. Run: cd backend ^&^& node scripts/hashPasswords.js
    echo 4. Start servers: npm start
) > "%BACKUP_DIR%\%BACKUP_NAME%\BACKUP_INFO.txt"

REM Create compressed archive
echo Creating compressed archive...
powershell -command "Compress-Archive -Path '%BACKUP_DIR%\%BACKUP_NAME%' -DestinationPath '%BACKUP_DIR%\%BACKUP_NAME%.zip' -Force"

REM Calculate size
for %%A in ("%BACKUP_DIR%\%BACKUP_NAME%.zip") do set SIZE=%%~zA
set /a SIZE_MB=%SIZE% / 1048576

echo.
echo ========================================
echo ✅ Backup completed successfully!
echo ========================================
echo.
echo Backup location: %BACKUP_DIR%\%BACKUP_NAME%.zip
echo Backup size: %SIZE_MB% MB
echo Folder backup: %BACKUP_DIR%\%BACKUP_NAME%
echo.
echo To restore this backup:
echo   scripts\restore-version.bat %BACKUP_NAME%
echo.

exit /b 0
