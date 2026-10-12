# Panduan Instal Aplikasi ke Perangkat Android

## Panduan untuk Menjalankan Aplikasi Absensi KJAVJM di HP Android

---

## 📋 Prasyarat yang Dibutuhkan

Pastikan Anda sudah memasang:

1. **Flutter SDK** (cek dengan perintah `flutter --version` di terminal)
2. **Android Studio** (untuk Android SDK dan emulator)
3. **Perangkat Android** (asli, bukan emulator - untuk pengujian GPS akurat)
4. **Kabel USB** untuk menghubungkan HP ke laptop

---

## 🚀 Langkah 1: Siapkan Perangkat Android

### A. Aktifkan Opsi Pengembang di HP

1. Buka **Pengaturan** di HP Android
2. Gulir ke bawah dan pilih **Tentang Ponsel** / **About Phone**
3. Tekan **Nomor Build** / **Build Number** sebanyak **7x** sampai muncul pesan "Anda sekarang adalah pengembang!"
4. Kembali ke **Pengaturan** utama
5. Buka **Opsi Pengembang** / **Developer Options**
6. Aktifkan **USB Debugging**

### B. Hubungkan HP ke Laptop

1. Pakai kabel USB untuk menghubungkan HP ke laptop
2. Di HP, akan muncul notifikasi "Izinkan USB Debugging?" → pilih **Izinkan** / **Allow**
3. (Opsional) Pilih mode **Transfer File** / **File Transfer** di HP

---

## 🚀 Langkah 2: Verifikasi Perangkat Terhubung

Buka **Terminal** (PowerShell/Command Prompt) di laptop, lalu jalankan:

```bash
flutter devices
```

Jika berhasil, Anda akan melihat perangkat Android Anda terdaftar! Contoh output:

```
2 connected devices:
Android SDK built for x86 (mobile) • emulator-5554 • android-x86 • Android 11 (API 30) (emulator)
Redmi Note 10 Pro (mobile) • abc12345 • android-arm64 • Android 13 (API 33)
```

---

## 🚀 Langkah 3: Jalankan Aplikasi ke Perangkat

### Opsi A: Menjalankan dengan Hot Reload (Untuk Pengembangan)

Cara ini memudahkan karena bisa melihat perubahan secara instan:

1. Buka terminal di direktori proyek:
  ```bash
   cd c:\Users\LENOVO\Documents\GitHub\kjavjm_mobile_app
  ```
2. Jalankan aplikasi:
  ```bash
   flutter run
  ```
3. Tunggu sampai proses selesai - aplikasi akan otomatis terinstal dan terbuka di HP!

**Fitur Hot Reload:**

- Tekan `**r`** di terminal untuk Hot Reload (melihat perubahan cepat)
- Tekan `**R`** untuk Hot Restart (memulai ulang aplikasi)
- Tekan `**q**` untuk keluar

---

### Opsi B: Build APK dan Instal Manual (Untuk Pengujian Lapangan)

Cara ini menghasilkan file APK yang bisa dibagikan dan diinstal tanpa laptop:

1. Buka terminal di direktori proyek:
  ```bash
   cd c:\Users\LENOVO\Documents\GitHub\kjavjm_mobile_app
  ```
2. Build APK debug:
  ```bash
   flutter build apk --debug
  ```
3. Tunggu sampai proses selesai. File APK akan berada di:
  ```
   build\app\outputs\flutter-apk\app-debug.apk
  ```
4. Kirim file APK ke HP (via Bluetooth, WhatsApp, Google Drive, dll.)
5. Di HP, buka file APK dan izinkan instalasi dari sumber tidak dikenal
6. Instal aplikasi!

---

## 🚀 Langkah 4: Berikan Izin Lokasi

Setelah aplikasi terinstal:

1. Buka aplikasi **Absensi KJAVJM**
2. Login (jika diperlukan)
3. Ketika muncul permintaan izin lokasi:
  - Pilih **Selalu Izinkan** / **Allow all the time** (penting untuk geofencing!)
4. Aktifkan **GPS** / **Lokasi** di HP dengan mode **Akurasi Tinggi**

---

## 📝 Catatan Penting

### Untuk Pengujian Geofencing yang Akurat:

1. **Gunakan perangkat Android asli**, bukan emulator (GPS emulator tidak akurat)
2. Aktifkan mode **Akurasi Tinggi** di pengaturan lokasi HP
3. Pastikan izin lokasi **Selalu Izinkan**
4. Lakukan pengujian di **area terbuka** (tidak di dalam gedung tertutup) untuk sinyal GPS yang baik

---

## ❗ Troubleshooting

### Masalah: Perangkat tidak terdeteksi

- Coba ganti kabel USB (pastikan kabel mendukung data, bukan hanya charging)
- Nonaktifkan dan aktifkan kembali **USB Debugging** di HP
- Coba port USB yang berbeda di laptop
- Restart HP dan laptop

### Masalah: Error saat build

- Pastikan Flutter SDK sudah terinstal dengan benar:
  ```bash
  flutter doctor
  ```
- Jalankan `flutter pub get` untuk memasang dependensi:
  ```bash
  flutter pub get
  ```
- Pastikan tidak ada proses build yang berjalan bersamaan

### Masalah: GPS tidak akurat

- Keluar dari gedung dan cari area terbuka
- Restart GPS di HP
- Coba aplikasi GPS lain (misal: Google Maps) untuk memastikan GPS berfungsi normal

---

## 🎉 Selesai!

Sekarang Anda bisa menjalankan aplikasi di HP Android dan mulai pengujian geofencing! Jika ada kendala, cek `flutter doctor` untuk melihat status konfigurasi Flutter Anda.

Selamat mencoba! 📱