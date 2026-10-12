@echo off
echo ========================================
echo  APLIKASI ABSENSI KJAVJM - ANDROID
echo ========================================
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

REM Periksa perangkat
echo [2/4] Memeriksa perangkat Android...
flutter devices
echo.

REM Dapatkan dependensi
echo [3/4] Memasang dependensi...
flutter pub get
if errorlevel 1 (
    echo ERROR: Gagal memasang dependensi!
    pause
    exit /b 1
)
echo ✓ Dependensi OK
echo.

REM Jalankan aplikasi
echo [4/4] Menjalankan aplikasi ke perangkat Android...
echo.
echo Catatan: Tekan 'r' untuk Hot Reload, 'R' untuk Hot Restart, 'q' untuk keluar.
echo.
flutter run

pause
