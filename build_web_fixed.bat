@echo off
REM Script untuk build Flutter Web di Windows dengan BASE_URL otomatis
REM Usage: build_web.bat [mode] [renderer]

setlocal enabledelayedexpansion

echo ================================================
echo        Flutter Web Build Script (Windows)
echo ================================================
echo.

REM Default values
set MODE=%1
if "%MODE%"=="" set MODE=release

set RENDERER=%2
if "%RENDERER%"=="" set RENDERER=canvaskit

REM Use BASE_URL from .env (hardcoded for now)
set BASE_URL=https://demo-kjavmj.prosesin.id/api

echo Build Configuration:
echo   Mode: %MODE%
echo   Renderer: %RENDERER%
echo   BASE_URL: %BASE_URL%
echo.

REM Clean build
echo Cleaning previous build...
call flutter clean
if errorlevel 1 goto :error

REM Get dependencies
echo Getting dependencies...
call flutter pub get
if errorlevel 1 goto :error

REM Build based on mode
echo.
echo Building web app...

if "%MODE%"=="debug" (
    call flutter build web --web-renderer %RENDERER% --dart-define=BASE_URL=%BASE_URL%
) else if "%MODE%"=="profile" (
    call flutter build web --profile --web-renderer %RENDERER% --dart-define=BASE_URL=%BASE_URL% --source-maps
) else if "%MODE%"=="release" (
    call flutter build web --release --web-renderer %RENDERER% --dart-define=BASE_URL=%BASE_URL% --tree-shake-icons
) else (
    echo Invalid mode: %MODE%
    echo Valid modes: debug, profile, release
    goto :error
)

if errorlevel 1 goto :error

echo.
echo ================================================
echo Build completed successfully!
echo ================================================
echo.
echo To test locally:
echo   cd build\web
echo   python -m http.server 8080
echo   Open: http://localhost:8080
echo.
echo Or use PHP:
echo   cd build\web
echo   php -S localhost:8080
echo.
echo To deploy:
echo   Firebase:  firebase deploy --only hosting
echo   Netlify:   netlify deploy --dir=build/web --prod
echo   Vercel:    vercel --prod build/web
echo.
goto :end

:error
echo.
echo ================================================
echo Build failed!
echo ================================================
exit /b 1

:end
endlocal
