@echo off
setlocal

cd /d "%~dp0"

echo.
echo Apagando servidores locales de ComuniCAA...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ports = @(8767, 8771); $stopped = $false; foreach ($port in $ports) { $listeners = Get-NetTCPConnection -LocalAddress 127.0.0.1 -LocalPort $port -State Listen -ErrorAction SilentlyContinue; foreach ($listener in $listeners) { $process = Get-CimInstance Win32_Process -Filter ('ProcessId=' + $listener.OwningProcess) -ErrorAction SilentlyContinue; if ($process -and $process.CommandLine -match 'http\.server') { Stop-Process -Id $listener.OwningProcess -Force -ErrorAction SilentlyContinue; Write-Host ('Servidor detenido en puerto ' + $port); $stopped = $true; } } }; if (-not $stopped) { Write-Host 'No habia servidores de ComuniCAA activos en 8767 o 8771.' }"

echo.
pause
