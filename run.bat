@echo off
cd /d "%~dp0"

set "LOVE_EXE="
where love >nul 2>nul
if not errorlevel 1 set "LOVE_EXE=love"

if not defined LOVE_EXE if exist "%ProgramFiles%\LOVE\love.exe" set "LOVE_EXE=%ProgramFiles%\LOVE\love.exe"
if not defined LOVE_EXE if exist "%ProgramFiles(x86)%\LOVE\love.exe" set "LOVE_EXE=%ProgramFiles(x86)%\LOVE\love.exe"

if not defined LOVE_EXE (
    echo LÖVE was not found on this machine.
    echo Install LÖVE and make sure the executable is on PATH, then run this again.
    pause
    exit /b 1
)

cd game
echo Starting Never Left...
"%LOVE_EXE%" .
