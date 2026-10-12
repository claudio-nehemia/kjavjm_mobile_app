@echo off
echo ========================================
echo  APLIKASI ABSENSI KJAVJM - CHROME WEB
echo ========================================
echo.
echo Catatan: GPS di web mungkin tidak seakurat perangkat Android asli.
echo Untuk pengujian geofencing akurat, gunakan perangkat Android asli.
echo.

REM Periksa Flutter
echo [1/4] Memeriksa Flutter...
flutter --version
if errorlevel 1 (
    echo ERROR: Flutter tidak ditemukan! Pastikan Flutter SDK sudah terinstal.
    pause
    exit /b 1
)
echo ✓ Flutter OK
echo.

REM Enable web support
echo [2/4] Memastikan web support aktif...
flutter config --enable-web
echo ✓ Web support OK
echo.

REM Dapatkan dependensi
echo [3/4] Memasang dependensi...
call flutter pub get
if errorlevel 1 (
    echo ERROR: Gagal memasang dependensi!
    pause
    exit /b 1
)
echo ✓ Dependensi OK
echo.

REM Jalankan aplikasi di Chrome
echo [4/4] Menjalankan aplikasi di Chrome...
call flutter run -d chrome --web-port=8080

pause
