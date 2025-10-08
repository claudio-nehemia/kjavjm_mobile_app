# Panduan Build iOS Simulator dengan Codemagic

## 📋 Prasyarat

1. **Akun Codemagic**
   - Daftar di [codemagic.io](https://codemagic.io/)
   - Hubungkan dengan repository GitHub Anda

2. **Repository**
   - Push file `codemagic.yaml` ke repository
   - Pastikan file berada di root project

## 🚀 Cara Setup di Codemagic

### 1. Tambahkan Aplikasi di Codemagic

1. Login ke [Codemagic Dashboard](https://codemagic.io/apps)
2. Klik **"Add application"**
3. Pilih **GitHub** sebagai source
4. Pilih repository **kjavjm_mobile_app**
5. Klik **"Finish: Add application"**

### 2. Konfigurasi Build iOS Simulator

1. Di Codemagic dashboard, pilih aplikasi Anda
2. Klik tab **"Workflow editor"** atau biarkan menggunakan `codemagic.yaml`
3. Pilih workflow: **"ios-simulator-workflow"**
4. Klik **"Start new build"**

### 3. Download Hasil Build

Setelah build selesai:
1. Buka build yang berhasil
2. Download file **`ios-simulator-app.zip`** dari artifacts
3. Extract file zip tersebut
4. Anda akan mendapat file **`Runner.app`**

## 🖥️ Cara Install ke iOS Simulator

### Metode 1: Via Terminal (Recommended)

```bash
# 1. Extract file zip
unzip ios-simulator-app.zip

# 2. Install ke simulator yang sedang running
xcrun simctl install booted Runner.app

# 3. Launch aplikasi
xcrun simctl launch booted com.example.kjavjmmobileapp
```

### Metode 2: Via Xcode

1. Buka **Xcode**
2. Buka **Window > Devices and Simulators** (⇧⌘2)
3. Pilih tab **"Simulators"**
4. Pilih simulator yang ingin digunakan
5. Klik tombol **"+"** di bagian **"Installed Apps"**
6. Pilih file **`Runner.app`** yang sudah di-extract
7. Aplikasi akan terinstall dan bisa dibuka dari home screen simulator

### Metode 3: Via Drag & Drop

1. Buka iOS Simulator
2. Drag file **`Runner.app`** ke window simulator
3. Aplikasi akan otomatis terinstall

## 📱 Testing di Simulator

Setelah install, aplikasi bisa dibuka seperti aplikasi normal di simulator:

```bash
# List semua simulator
xcrun simctl list devices

# Boot simulator tertentu (jika belum running)
xcrun simctl boot "iPhone 15 Pro"

# Launch aplikasi
xcrun simctl launch booted com.example.kjavjmmobileapp

# Uninstall aplikasi (jika perlu)
xcrun simctl uninstall booted com.example.kjavjmmobileapp
```

## ⚙️ Konfigurasi Lanjutan

### Build Otomatis pada Push

Tambahkan triggering di `codemagic.yaml`:

```yaml
workflows:
  ios-simulator-workflow:
    name: iOS Simulator Build
    triggering:
      events:
        - push
      branch_patterns:
        - pattern: 'main'
          include: true
          source: true
        - pattern: 'develop'
          include: true
          source: true
```

### Build dengan Environment Variables

Jika aplikasi Anda butuh API keys atau secrets:

1. Di Codemagic dashboard, buka **Application settings**
2. Pilih **Environment variables**
3. Tambahkan variable (contoh):
   - `API_KEY`
   - `BASE_URL`
   - dll.

4. Update `codemagic.yaml`:

```yaml
environment:
  vars:
    API_KEY: $API_KEY
    BASE_URL: $BASE_URL
scripts:
  - name: Set environment variables
    script: |
      echo "API_KEY=$API_KEY" > .env
      echo "BASE_URL=$BASE_URL" >> .env
```

## 🔧 Troubleshooting

### Error: "No such module"

**Solusi:**
```yaml
scripts:
  - name: Clean and get dependencies
    script: |
      flutter clean
      flutter pub get
      cd ios && pod deintegrate && pod install
```

### Error: Build timeout

**Solusi:** Increase `max_build_duration`:
```yaml
workflows:
  ios-simulator-workflow:
    max_build_duration: 90  # Increase dari 60 ke 90 menit
```

### Error: Simulator architecture mismatch

**Pastikan build untuk simulator:**
```bash
flutter build ios --simulator --debug
# BUKAN
flutter build ios --debug  # Ini untuk device
```

## 📊 Build Types

### Debug Build (Untuk Testing)
```yaml
script: |
  flutter build ios --simulator --debug
```

**Keuntungan:**
- Lebih cepat
- Hot reload available (jika run dari Xcode)
- Debug mode enabled

### Release Build (Untuk QA)
```yaml
script: |
  flutter build ios --simulator --release
```

**Keuntungan:**
- Performance lebih baik
- Ukuran lebih kecil
- Mirip production build

## 🎯 Best Practices

1. **Gunakan Debug Build untuk Development:**
   ```bash
   flutter build ios --simulator --debug
   ```

2. **Gunakan Release Build untuk QA Testing:**
   ```bash
   flutter build ios --simulator --release
   ```

3. **Buat Workflow Terpisah:**
   - `ios-simulator-dev` → debug build
   - `ios-simulator-qa` → release build
   - `ios-device-prod` → production build untuk App Store

4. **Setup Notifikasi Email:**
   ```yaml
   publishing:
     email:
       recipients:
         - dev-team@example.com
       notify:
         success: true
         failure: true
   ```

## 📚 Resources

- [Codemagic Documentation](https://docs.codemagic.io/)
- [Flutter iOS Build Guide](https://docs.flutter.dev/deployment/ios)
- [Xcode Simulator Commands](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator)

## 💡 Tips

1. **Cache Dependencies untuk Build Lebih Cepat:**
   ```yaml
   cache:
     cache_paths:
       - $HOME/.pub-cache
       - $HOME/Library/Caches/CocoaPods
   ```

2. **Parallel Builds:**
   Buat multiple workflows untuk build iOS simulator + Android APK secara bersamaan

3. **Artifacts Retention:**
   Artifacts di Codemagic disimpan selama 30 hari (free plan) atau unlimited (paid plan)

## 🆘 Support

Jika ada masalah:
1. Check Codemagic build logs
2. Baca error message dengan teliti
3. Cari di [Codemagic Community](https://community.codemagic.io/)
4. Contact Codemagic support (paid plans)
