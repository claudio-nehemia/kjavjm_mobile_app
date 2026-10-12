@echo off
echo ========================================
echo  BUILD APK - ABSENSI KJAVJM
echo ========================================
echo.

REM Periksa Flutter
echo [1/3] Memeriksa Flutter...
flutter --version
if errorlevel 1 (
    echo ERROR: Flutter tidak ditemukan! Pastikan Flutter SDK sudah terinstal.
    pause
    exit /b 1
)
echo ✓ Flutter OK
echo.

REM Dapatkan dependensi
echo [2/3] Memasang dependensi...
call flutter pub get
if errorlevel 1 (
    echo ERROR: Gagal memasang dependensi!
    pause
    exit /b 1
)
echo ✓ Dependensi OK
echo.

REM Build APK debug
echo [3/3] Building APK Debug...
call flutter build apk --debug
if errorlevel 1 (
    echo ERROR: Gagal build APK!
    pause
    exit /b 1
)
echo.
echo ========================================
echo  ✓ BUILD BERHASIL!
echo ========================================
echo.
echo Lokasi file APK:
echo build\app\outputs\flutter-apk\app-debug.apk
echo.
explorer build\app\outputs\flutter-apk\

pause
