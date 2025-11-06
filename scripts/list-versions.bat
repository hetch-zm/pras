@echo off
REM ============================================
REM List Versions Script
REM ============================================

echo.
echo ========================================
echo  Version History
echo ========================================
echo.

REM Check if git repository
git rev-parse --git-dir > nul 2>&1
if errorlevel 1 (
    echo Error: Not a git repository
    exit /b 1
)

echo Git Tags (Versions):
echo --------------------
git tag -l -n1
echo.

echo Recent Commits:
echo ---------------
git log --oneline --decorate -10
echo.

echo Current Status:
echo ---------------
git status --short
echo.

echo Backup Directory:
echo -----------------
set BACKUP_DIR=..\purchase-requisition-backups
if exist "%BACKUP_DIR%" (
    echo Available backups:
    dir /B "%BACKUP_DIR%\*.zip" 2>nul
    echo.
    echo Backup folders:
    dir /B /AD "%BACKUP_DIR%\prs-*" 2>nul
) else (
    echo No backups directory found
)
echo.

exit /b 0
