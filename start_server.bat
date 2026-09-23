@echo off
cd /d "%~dp0"
echo Starting MengToSketchbookLandingPage Server...
powershell -ExecutionPolicy Bypass -File "%~dp0server.ps1"
pause
