@echo off
REM Quick test Flutter web with CORS disabled Chrome

echo ========================================
echo Flutter Web - CORS Workaround Test
echo ========================================
echo.
echo Closing Chrome instances...
taskkill /F /IM chrome.exe 2>nul
timeout /t 2 /nobreak >nul

echo.
echo Starting Chrome with CORS disabled...
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --disable-web-security --user-data-dir="C:\tmp\chrome-dev" --disable-site-isolation-trials http://localhost:8080

echo.
echo Starting web server on port 8080...
cd build\web
python -m http.server 8080

pause
