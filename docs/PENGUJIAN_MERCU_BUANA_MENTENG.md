# Panduan Pengujian Akurasi Geofence — Universitas Mercu Buana Menteng

Panduan lapangan untuk Bab 4 skripsi. Gunakan bersama halaman **Uji Geofence** di aplikasi Android.

---

## 1. Konfigurasi geofence di aplikasi


| Parameter       | Nilai                                           |
| --------------- | ----------------------------------------------- |
| Nama area       | Mercu Buana Menteng                             |
| Alamat          | Jl. Menteng Raya No. 29, Menteng, Jakarta Pusat |
| Latitude pusat  | **-6,1856**                                     |
| Longitude pusat | **106,8364**                                    |
| Radius          | **200 meter**                                   |


Peta pusat: [Google Maps](https://www.google.com/maps?q=-6.1856,106.8364)

---

## 2. Cara membuka alat uji di aplikasi

1. Build & install di **HP Android** (GPS asli, bukan emulator).
2. Login → menu **Absensi**.
3. Tap tombol **「Uji Akurasi Geofence (Mercu Buana Menteng)」** (muncul di mode debug).
4. Atau navigasi langsung ke route `/geofence-test`.

---

## 3. Titik uji di kampus (T1–T5)

**Penting:** Koordinat referensi di bawah adalah **perkiraan**. Sebelum skripsi, tandai ulang di Google Maps dan sesuaikan jika perlu.


| Titik  | Lokasi fisik (petunjuk)                                                   | Label benar | Jarak ref. ke pusat |
| ------ | ------------------------------------------------------------------------- | ----------- | ------------------- |
| **T1** | Lobi Gedung Tedja Buana / area utama dalam kampus                         | INSIDE      | ~50 m               |
| **T2** | Area dalam kampus mendekati batas 200 m (koridor luar gedung masih dalam) | INSIDE      | ~180 m              |
| **T3** | Trotoar luar / tepi Jl. Menteng Raya (baru lewat batas)                   | OUTSIDE     | ~220 m              |
| **T4** | Jauh dari kampus (mis. arah St. Gondangdia / ≥500 m)                      | OUTSIDE     | ~500 m              |
| **T5** | Dalam gedung, sinyal GPS lemah (koridor, dekat dinding)                   | INSIDE*     | variabel            |


T5 untuk uji **stabilitas**; bandingkan berapa kali status berubah-ubah dalam 2 menit.

### Langkah penandaan titik (1 hari sebelum uji resmi)

1. Buka Google Maps di titik T1, catat lat/lng → simpan screenshot.
2. Ulangi T2–T4; pastikan T2 masih ≤200 m dan T3 >200 m dari pusat geofence.
3. Update file `geofence_test_helper.dart` jika koordinat referensi berubah.

---

## 4. Prosedur uji (M1 — Haversine, wajib)

Di setiap titik **T1, T2, T3, T4, T5**:

1. Pilih **Titik uji** dan **Metode M1** di aplikasi.
2. Berdiri diam ±1 menit (tunggu GPS stabil).
3. Tekan **Ambil Lokasi** → **10 kali** (jarak antar sampel ±10 detik).
4. Catat apakah kartu hijau **「Sesuai ground truth」** atau merah.
5. Tap **Salin semua log** → paste ke Excel (`template_data_pengujian_geofence.csv`).

**T2 & T3 tambahan (stabilitas):**  
Diam 2 menit, ambil sampel setiap 10 detik (12 sampel) → hitung berapa kali status flip INSIDE↔OUTSIDE.

---

## 5. Target kelulusan (isi di Bab 4)


| Metrik                    | Target                  |
| ------------------------- | ----------------------- |
| Akurasi T1 + T4           | ≥ 98%                   |
| Akurasi T2 + T3           | ≥ 90%                   |
| False inside (T3, T4)     | **0** dari 30 percobaan |
| Flip rate T2/T3 (2 menit) | ≤ 10%                   |


---

## 6. Contoh pengisian tabel skripsi

**Tabel 4.1 Hasil uji M1 — Mercu Buana Menteng (n = 10 per titik)**


| Titik | Ground truth | Benar | Salah | Akurasi | FI  | FO  |
| ----- | ------------ | ----- | ----- | ------- | --- | --- |
| T1    | INSIDE       | 10    | 0     | 100%    | 0   | 0   |
| T2    | INSIDE       | 9     | 1     | 90%     | 0   | 1   |
| T3    | OUTSIDE      | 9     | 1     | 90%     | 1   | 0   |
| T4    | OUTSIDE      | 10    | 0     | 100%    | 0   | 0   |
| T5    | INSIDE       | 8     | 2     | 80%     | 0   | 2   |


*(Angka di atas contoh format — ganti dengan data lapangan kamu.)*

---

## 7. Checklist hari H (di kampus)

- HP terisi baterai ≥80%, GPS mode **Akurasi tinggi**
- Izin lokasi **Izinkan sepanjang waktu** (jika uji M3)
- Backend/API hidup (login berhasil)
- Spreadsheet / CSV siap
- Screenshot peta T1–T5
- Cuaca dicatat (cerah/hujan)
- 50+ sampel M1 selesai
- Foto dokumentasi di setiap titik (untuk lampiran skripsi)

---

## 8. Lampiran skripsi

1. Screenshot halaman **Uji Geofence** (contoh T1 benar, T3 salah jika ada).
2. Peta Google Maps dengan 5 pin titik uji.
3. File CSV hasil export dari aplikasi.
4. Narasi lengkap: lihat `docs/BAB4_PENGUJIAN_GEOFENCING.md`.

---

*Proyek: KJAVJM HR Mobile App — pengujian khusus kampus Mercu Buana Menteng.*