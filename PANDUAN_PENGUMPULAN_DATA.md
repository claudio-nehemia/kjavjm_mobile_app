# Panduan Pengumpulan Data Geofencing

## Panduan Lengkap untuk Skripsi - Aplikasi Absensi Mercu Buana

---

## 📋 Daftar Isi

1. [Persiapan Sebelum Pengujian](#1-persiapan-sebelum-pengujian)
2. [Struktur Kolom CSV](#2-struktur-kolom-csv)
3. [Langkah-Langkah Pengumpulan Data](#3-langkah-langkah-pengumpulan-data)
4. [Cara Memasukkan CSV ke Excel/Google Sheets](#4-cara-memasukkan-csv-ke-excelgoogle-sheets)
5. [Contoh Hasil Data](#5-contoh-hasil-data)
6. [Analisis Data Sederhana](#6-analisis-data-sederhana)

---

## 1. Persiapan Sebelum Pengujian

### A. Yang Perlu Disiapkan

1. Perangkat Android dengan GPS aktif dan izin lokasi "Selalu Izinkan"
2. Aplikasi absensi sudah diinstal di perangkat
3. Koneksi internet (opsional, untuk verifikasi koordinat di Google Maps)
4. Alat pencatat (opsional, untuk catatan lapangan)

### B. Verifikasi Titik Uji di Lapangan

**PENTING!** Pastikan koordinat titik T1-T5 sesuai dengan lokasi fisik di Kampus Mercu Buana Menteng:


| Titik | Nama Lokasi      | Koordinat Perkiraan | Ground Truth |
| ----- | ---------------- | ------------------- | ------------ |
| T1    | Dalam jelas      | -6.18515, 106.8364  | INSIDE       |
| T2    | Tepi dalam       | -6.18398, 106.8364  | INSIDE       |
| T3    | Tepi luar        | -6.18362, 106.8364  | OUTSIDE      |
| T4    | Luar jelas       | -6.18110, 106.8364  | OUTSIDE      |
| T5    | GPS tidak stabil | -6.18400, 106.8360  | INSIDE       |


Cara verifikasi:

1. Buka Google Maps di perangkat
2. Pergi ke lokasi titik uji
3. Tahan layar untuk menandai lokasi
4. Bandingkan koordinat dengan tabel di atas
5. Jika berbeda, update di file `lib/core/utils/geofence_test_helper.dart`

---

## 2. Struktur Kolom CSV

File CSV yang dihasilkan memiliki kolom sebagai berikut:


| No  | Nama Kolom     | Deskripsi                                         |
| --- | -------------- | ------------------------------------------------- |
| 1   | `test_id`      | ID unik untuk setiap sampel (contoh: M1_T1_12345) |
| 2   | `waktu`        | Waktu pengambilan sampel (format ISO 8601 lokal)  |
| 3   | `metode`       | Metode algoritma yang digunakan (M1/M2/M3)        |
| 4   | `titik`        | Titik uji (T1/T2/T3/T4/T5)                        |
| 5   | `ground_truth` | Label seharusnya (INSIDE/OUTSIDE)                 |
| 6   | `prediksi`     | Hasil prediksi aplikasi (INSIDE/OUTSIDE)          |
| 7   | `benar`        | Flag apakah prediksi sesuai (YA/TIDAK)            |
| 8   | `lat`          | Latitude yang digunakan untuk perhitungan         |
| 9   | `lng`          | Longitude yang digunakan untuk perhitungan        |
| 10  | `raw_lat`      | Latitude GPS mentah (khusus M2)                   |
| 11  | `raw_lng`      | Longitude GPS mentah (khusus M2)                  |
| 12  | `jarak_m`      | Jarak ke pusat geofence dalam meter               |


---

## 3. Langkah-Langkah Pengumpulan Data

### Alur Pengujian yang Disarankan

Uji **satu metode terlebih dahulu** untuk semua titik, baru lanjut ke metode berikutnya:

1. Metode M1 (Haversine - GPS mentah)
2. Metode M2 (Kalman Filter)
3. Metode M3 (OS Geofence)

---

### Langkah 1: Buka Halaman Uji Geofence

1. Buka aplikasi **Absensi KJAVJM**
2. Login (jika diperlukan)
3. Buka halaman **Absensi**
4. Klik tombol **"Uji Akurasi Geofence (Mercu Buana Menteng)"**

---

### Langkah 2: Pilih Titik Uji

1. Di bagian **"Titik uji (ground truth)"**, pilih titik yang ingin diuji (misal: T1 - Dalam jelas)
2. Pastikan Anda **berada secara fisik di lokasi titik tersebut**!

---

### Langkah 3: Pilih Metode Algoritma

1. Di bagian **"Metode algoritma"**, pilih metode yang ingin diuji:
  - **M1 — Haversine (GPS mentah)** (direkomendasikan pertama)
  - **M2 — Kalman (koordinat GPS)**
  - **M3 — OS Geofence (label uji)**

---

### Langkah 4: Ambil Sampel Lokasi

1. Tekan tombol **"Ambil Lokasi"** (tombol biru mengambang di kanan bawah)
2. Tunggu sampai proses selesai
3. Ulangi **10x** untuk satu titik dan satu metode!
  - Contoh: Untuk T1 dan M1, ambil 10x sampel berturut-turut

---

### Langkah 5: Salin Data Log

Setelah selesai mengambil 10x sampel:

1. Tekan tombol **"Salin semua log"**
2. Data CSV akan otomatis tersalin ke clipboard

---

### Langkah 6: Simpan ke Excel/Google Sheets

Lihat bagian 4 untuk panduan detail!

---

### Langkah 7: Ulangi untuk Titik dan Metode Lainnya

Setelah selesai satu titik dan satu metode:

1. Kembali ke langkah 2 untuk mengganti titik
2. Atau kembali ke langkah 3 untuk mengganti metode
3. **Jangan lupa membersihkan log** (tutup dan buka kembali halaman uji jika diperlukan)

---

## 4. Cara Memasukkan CSV ke Excel/Google Sheets

### Opsi A: Microsoft Excel

1. Buka Microsoft Excel
2. Buat **Workbook baru**
3. Di tab **Data**, pilih **From Text/CSV**
4. Atau, buat sheet baru dan **tempel (Ctrl+V)** data yang disalin
5. Excel akan otomatis mendeteksi format CSV dan memisahkan kolom
6. Simpan file dengan nama: `Data_Geofencing_[NAMA]_[TANGGAL].xlsx`

---

### Opsi B: Google Sheets

1. Buka [Google Sheets](https://sheets.google.com)
2. Buat **Spreadsheet baru**
3. Di sel **A1**, tempel (Ctrl+V) data CSV yang disalin
4. Pilih opsi **Split text to columns** (jika kolom tidak otomatis terpisah)
5. Simpan spreadsheet dengan nama yang jelas

---

### Struktur File Excel yang Direkomendasikan

Buat **sheet terpisah** untuk setiap metode:

- Sheet 1: M1 (Haversine)
- Sheet 2: M2 (Kalman Filter)
- Sheet 3: M3 (OS Geofence)
- Sheet 4: Ringkasan & Analisis

---

## 5. Contoh Hasil Data

Berikut adalah contoh baris data CSV:

```csv
test_id,waktu,metode,titik,ground_truth,prediksi,benar,lat,lng,raw_lat,raw_lng,jarak_m
M1_T1_1,2026-06-04T14:30:00.000,M1,T1,INSIDE,INSIDE,YA,-6.185150,106.836400,,,50.0
M1_T1_2,2026-06-04T14:30:05.000,M1,T1,INSIDE,INSIDE,YA,-6.185160,106.836410,,,51.2
```

---

## 6. Analisis Data Sederhana

Setelah semua data terkumpul, hitung metrik berikut untuk setiap metode:

### Rumus Perhitungan di Excel

1. **Akurasi** (Accuracy):
  ```excel
   =COUNTIF(benar_range, "YA") / COUNTA(benar_range) * 100%
  ```
2. **False Inside** (FI): Prediksi INSIDE tapi seharusnya OUTSIDE
  ```excel
   =COUNTIFS(ground_truth_range, "OUTSIDE", prediksi_range, "INSIDE")
  ```
3. **False Outside** (FO): Prediksi OUTSIDE tapi seharusnya INSIDE
  ```excel
   =COUNTIFS(ground_truth_range, "INSIDE", prediksi_range, "OUTSIDE")
  ```
4. **Rata-rata Jarak**
  ```excel
   =AVERAGE(jarak_m_range)
  ```

---

## 📊 Contoh Tabel Ringkasan

Buat tabel ringkasan seperti ini di sheet terpisah:


| Metode | Total Sampel | Akurasi (%) | False Inside | False Outside | Rata-rata Jarak (m) |
| ------ | ------------ | ----------- | ------------ | ------------- | ------------------- |
| M1     | 50           | 94          | 1            | 2             | 145.2               |
| M2     | 50           | 98          | 0            | 1             | 144.8               |
| M3     | 50           | 96          | 0            | 2             | 146.1               |


---

## 💡 Tips Penting untuk Pengujian

1. **Konsistensi**: Uji pada waktu yang sama (hindari pergantian hari) untuk menghindari perbedaan kualitas sinyal GPS
2. **Perangkat Tetap**: Gunakan perangkat yang sama untuk semua pengujian
3. **Sabar**: Tunggu beberapa detik sebelum mengambil sampel berikutnya agar GPS stabil
4. **Catat**: Jika ada kejadian aneh (misal: GPS tiba-tiba melompat jauh), catat di kolom "Keterangan"
5. **Backup**: Simpan file Excel di Google Drive atau cloud storage lainnya

---

## 📞 Bantuan

Jika mengalami kendala:

1. Pastikan GPS perangkat aktif dan akurasi tinggi
2. Pastikan izin lokasi "Selalu Izinkan"
3. Restart aplikasi jika terjadi error
4. Cek koordinat titik uji di Google Maps

---

Selamat mengumpulkan data! Semoga lancar untuk skripsinya! 🎓