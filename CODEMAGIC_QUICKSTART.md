# 🚀 Quick Start: Build iOS Simulator dengan Codemagic

## Setup (Sekali saja)

1. **Push konfigurasi ke repository:**
   ```bash
   git add codemagic.yaml
   git commit -m "Add Codemagic configuration for iOS simulator build"
   git push
   ```

2. **Hubungkan repository di Codemagic:**
   - Buka [codemagic.io](https://codemagic.io/)
   - Login dengan GitHub
   - Add application → Pilih repository ini
   - Workflow akan otomatis terdeteksi dari `codemagic.yaml`

## Build iOS Simulator

### Di Codemagic Dashboard:

1. Pilih workflow: **"iOS Simulator Build"**
2. Klik **"Start new build"**
3. Tunggu build selesai (~10-15 menit)
4. Download **`ios-simulator-app.zip`** dari artifacts

### Install ke Simulator (Mac):

**Cara Cepat (Terminal):**
```bash
# Make script executable (sekali saja)
chmod +x install_simulator_build.sh

# Install dan launch
./install_simulator_build.sh ios-simulator-app.zip
```

**Cara Manual:**
```bash
# Extract dan install
unzip ios-simulator-app.zip
xcrun simctl install booted Runner.app
xcrun simctl launch booted com.example.kjavjmmobileapp
```

**Cara Drag & Drop:**
1. Buka iOS Simulator
2. Drag `Runner.app` ke simulator window
3. Done!

## Workflows Available

| Workflow | Description | Output |
|----------|-------------|--------|
| `ios-simulator-workflow` | iOS Simulator build (debug) | `.app` untuk simulator |
| `ios-device-workflow` | iOS Device build untuk App Store | `.ipa` untuk device |
| `android-workflow` | Android APK/AAB build | `.apk` / `.aab` |

## Troubleshooting

### Build gagal?
1. Check build logs di Codemagic
2. Pastikan `pubspec.yaml` tidak ada error
3. Pastikan iOS dependencies (CocoaPods) OK

### Simulator tidak mau install?
```bash
# Check simulators yang available
xcrun simctl list devices

# Boot simulator
xcrun simctl boot "iPhone 15 Pro"
open -a Simulator

# Retry install
xcrun simctl install booted Runner.app
```

## 📚 Dokumentasi Lengkap

Baca [CODEMAGIC_SETUP.md](./CODEMAGIC_SETUP.md) untuk:
- Setup environment variables
- Build otomatis on push
- Multiple build types
- Dan lainnya

## 💡 Tips

1. **Debug Build** (default) → Lebih cepat untuk testing
2. **Release Build** → Edit `codemagic.yaml`, ganti `--debug` dengan `--release`
3. **Auto-build on push** → Uncomment bagian `triggering` di config
4. **Email notification** → Update email di bagian `publishing.email`

## 🆘 Need Help?

- Codemagic Docs: https://docs.codemagic.io/
- Flutter iOS Docs: https://docs.flutter.dev/deployment/ios
- Issues: [GitHub Issues](https://github.com/claudio-nehemia/kjavjm_mobile_app/issues)
