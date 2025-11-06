@echo off
REM ============================================
REM Create New Version Script
REM ============================================

echo.
echo ========================================
echo  Create New Version
echo ========================================
echo.

REM Check if version number is provided
if "%1"=="" (
    echo Usage: create-version.bat [version] [description]
    echo Example: create-version.bat v3.0.1 "Bug fixes and improvements"
    echo.
    exit /b 1
)

set VERSION=%1
set DESCRIPTION=%2

if "%DESCRIPTION%"=="" (
    set DESCRIPTION="Version %VERSION%"
)

echo Creating version: %VERSION%
echo Description: %DESCRIPTION%
echo.

REM Check if there are uncommitted changes
git status --short > nul 2>&1
if errorlevel 1 (
    echo Error: Not a git repository
    exit /b 1
)

git diff-index --quiet HEAD --
if errorlevel 1 (
    echo Warning: You have uncommitted changes
    echo.
    choice /C YN /M "Do you want to commit all changes now"
    if errorlevel 2 goto skip_commit
    if errorlevel 1 goto do_commit
) else (
    echo No uncommitted changes detected
    goto create_tag
)

:do_commit
echo.
echo Staging all changes...
git add .

echo.
set /p COMMIT_MSG="Enter commit message: "
if "%COMMIT_MSG%"=="" set COMMIT_MSG="Updates for %VERSION%"

git commit -m "%COMMIT_MSG%"
echo.

:create_tag
echo Creating git tag %VERSION%...
git tag -a %VERSION% -m %DESCRIPTION%

echo.
echo ✅ Version %VERSION% created successfully!
echo.
echo To view all versions: git tag -l
echo To view this version details: git show %VERSION%
echo.

:skip_commit
exit /b 0
