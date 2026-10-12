# Panduan Import Wireframe ke Figma

File native `**.fig**` tidak bisa dibuat langsung dari luar aplikasi Figma. Yang sudah disediakan di repo ini adalah **SVG wireframe** siap import + spesifikasi frame agar kamu bisa merapikan di Figma dalam ±15 menit.

---

## File SVG (drag & drop ke Figma)


| File                                         | Layar        |
| -------------------------------------------- | ------------ |
| `docs/figma-wireframes/01-login.svg`         | Login        |
| `docs/figma-wireframes/02-dashboard.svg`     | Dashboard    |
| `docs/figma-wireframes/03-absensi.svg`       | Absensi      |
| `docs/figma-wireframes/04-geofence-test.svg` | Uji Geofence |


---

## Cara import ke Figma (gratis)

### Opsi A — Drag & drop (paling cepat)

1. Buka [figma.com](https://www.figma.com) → login / buat akun gratis.
2. **New design file**.
3. Buka folder `docs/figma-wireframes/` di Explorer.
4. **Seret** file `01-login.svg` … `04-geofence-test.svg` ke kanvas Figma.
5. Atur posisi berdampingan (jarak ±40 px antar frame).

### Opsi B — Menu Import

1. Figma → **Menu (☰)** → **File** → **Import**.
2. Pilih semua file `.svg` di `docs/figma-wireframes/`.
3. Klik **Import**.

### Setelah import — rapikan frame

1. Pilih satu SVG → klik kanan → **Frame selection** (atau `Ctrl+Alt+G`).
2. Ubah nama frame:
  - `WF / 01 Login`
  - `WF / 02 Dashboard`
  - `WF / 03 Absensi`
  - `WF / 04 Geofence Test`
3. Atur ukuran frame: **360 × 800** (sudah sesuai di SVG).
4. (Opsional) Page baru: **Wireframe Skripsi**.

---

## Spesifikasi desain (sesuai app asli)

Gunakan ini kalau mau gambar ulang / polish di Figma:


| Token              | Nilai                 |
| ------------------ | --------------------- |
| Lebar frame mobile | 360 px                |
| Tinggi frame       | 800 px                |
| Primary blue       | `#1976D2` / `#2196F3` |
| Background app     | `#F5F5F5`             |
| Card radius        | 12–20 px              |
| Font (wireframe)   | Inter / Arial         |
| Bottom nav tinggi  | 64 px                 |
| App bar tinggi     | 56 px                 |


### Komponen yang bisa dibuat di Figma (Components)


| Component        | Isi                                     |
| ---------------- | --------------------------------------- |
| `Button/Primary` | Full width, h=52, radius 12, bg #1976D2 |
| `Input/Default`  | h=48, border #CED4DA, radius 8          |
| `Card/Action`    | Attendance action card dengan ikon kiri |
| `Card/Info`      | Info absensi hari ini                   |
| `BottomNav`      | 4 tab: Home, Absensi, Riwayat, Profil   |
| `SnackBar/Error` | Pesan luar area geofence                |
| `FAB/Location`   | Tombol "Ambil Lokasi"                   |


---

## Struktur halaman Figma yang disarankan

```
📁 KJAVJM Wireframe Skripsi
├── 📄 Cover (judul skripsi + nama)
├── 📄 WF — Auth
│   ├── 01 Login
│   └── 01b Splash (buat manual / copy login)
├── 📄 WF — Main App
│   ├── 02 Dashboard
│   ├── 03 Absensi
│   ├── 03b Dialog Check-in
│   ├── 03c SnackBar Luar Area
│   ├── 07 Riwayat (buat manual mengacu WIREFRAME_APLIKASI.md)
│   └── 08 Profil
├── 📄 WF — Geofence
│   └── 04 Geofence Test
└── 📄 User Flow
    └── Flowchart absensi + geofence
```

Layar **Riwayat**, **Profil**, **Splash**, dan **Dialog** belum ada SVG terpisah — acuannya ada di `docs/WIREFRAME_APLIKASI.md` (ASCII). Kamu bisa duplikasi frame Dashboard lalu edit, atau minta saya buatkan SVG tambahan.

---

## Export untuk skripsi (dari Figma)

1. Pilih semua frame wireframe.
2. Panel kanan → **Export** → format **PNG** @2x.
3. Sisipkan ke Word sebagai *Gambar 3.x Wireframe …*.

Atau export **PDF** satu halaman berisi semua frame untuk lampiran.

---

## Alternatif: Figma Community

Cari template gratis di Figma Community:

- "Mobile wireframe kit"
- "Android UI kit grayscale"

Lalu tempel layout dari `WIREFRAME_APLIKASI.md` ke template tersebut.

---

## Yang tidak bisa dilakukan dari sini


| Item                         | Keterangan                                     |
| ---------------------------- | ---------------------------------------------- |
| File `.fig` native           | Hanya bisa dibuat/di-save dari dalam app Figma |
| Akun / login Figma kamu      | Harus kamu yang buka sendiri                   |
| Edit langsung di cloud Figma | Tidak ada akses API Figma dari assistant ini   |


---

## Langkah berikutnya (kalau mau saya bantu lagi)

1. Buat SVG tambahan: **Riwayat**, **Profil**, **Dialog Check-in**, **SnackBar error**.
2. Buat **satu SVG panjang** berisi 6 layar (satu lembar untuk lampiran skripsi).
3. Buat file **draw.io** (`.drawio`) sebagai alternatif selain Figma.

---

*Proyek: kjavjm_mobile_app — wireframe untuk Bab 3 Metode Penelitian.*