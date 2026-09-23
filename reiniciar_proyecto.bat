@echo off
setlocal

cd /d "%~dp0"
set "PORT=8771"

echo.
echo Reiniciando ComuniCAA...
echo.

echo Deteniendo servidores anteriores del proyecto...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ports = @(8767, 8771); foreach ($port in $ports) { $listeners = Get-NetTCPConnection -LocalAddress 127.0.0.1 -LocalPort $port -State Listen -ErrorAction SilentlyContinue; foreach ($listener in $listeners) { $process = Get-CimInstance Win32_Process -Filter ('ProcessId=' + $listener.OwningProcess) -ErrorAction SilentlyContinue; if ($process -and $process.CommandLine -match 'http\.server') { Stop-Process -Id $listener.OwningProcess -Force -ErrorAction SilentlyContinue; Write-Host ('Servidor detenido en puerto ' + $port); } } }"

echo.
echo Construyendo version web sin cache PWA...
call flutter build web --pwa-strategy=none
if errorlevel 1 (
  echo.
  echo No se pudo construir el proyecto. Revisa los errores anteriores.
  pause
  exit /b 1
)

echo.
echo Levantando servidor local en http://127.0.0.1:%PORT%/
start "ComuniCAA servidor" /min cmd /c "cd /d ""%~dp0build\web"" && python -m http.server %PORT% --bind 127.0.0.1"

echo.
echo Esperando servidor...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Sleep -Seconds 2; try { Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:%PORT%/' -TimeoutSec 5 | Out-Null; Write-Host 'Servidor listo.' } catch { Write-Host 'El servidor sigue iniciando; espera unos segundos y refresca.' }"

echo.
echo Abre esta URL:
echo http://127.0.0.1:%PORT%/?v=icon3
echo.
pause
