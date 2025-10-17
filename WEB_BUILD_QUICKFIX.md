# 🚀 Quick Fix - Flutter Web Build Error

## ❌ Error yang Anda Alami
```
Uncaught Error at kC.b5Z [as a] (main.dart.js:4504:23)
```

## ✅ Solusi Cepat

### 1. **Clean & Rebuild** (Try this first!)

**Windows (PowerShell):**
```powershell
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit
```

**Mac/Linux (Terminal):**
```bash
./build_web.bat release canvaskit
```

### 2. **Test di Browser Dulu**

```bash
# Run di Chrome untuk debug
flutter run -d chrome

# Lihat console browser untuk error lebih jelas
```

### 3. **Build dengan Different Renderer**

Jika canvaskit error, coba HTML:

```bash
flutter build web --release --web-renderer html
```

### 4. **Set API URL**

```bash
flutter build web --release --dart-define=API_BASE_URL=https://your-api.com
```

## 🔧 Files yang Sudah Diperbaiki

✅ **main.dart** - Added .env error handling
✅ **location_service.dart** - Added web compatibility
✅ **index.html** - Added loading indicator & error handling
✅ **web_config.dart** - Added fallback config

## 📋 Build Commands Lengkap

```bash
# Development (fastest)
flutter build web --web-renderer canvaskit

# Production (optimized)
flutter build web --release --web-renderer canvaskit --tree-shake-icons

# With API URL
flutter build web --release --dart-define=API_BASE_URL=https://api.com

# Profile (for testing)
flutter build web --profile --web-renderer canvaskit --source-maps
```

## 🎯 Test Locally

```bash
# Setelah build
cd build/web

# Python 3
python -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000

# Node.js
npx http-server

# Buka: http://localhost:8000
```

## 🐛 Still Getting Errors?

### Check Browser Console
1. Buka browser DevTools (F12)
2. Lihat tab Console
3. Cari error message yang lebih detail
4. Screenshot dan share jika masih error

### Common Fixes

**CORS Error?**
```bash
# Add CORS headers di backend
# Atau gunakan --web-browser-flag untuk testing
flutter run -d chrome --web-browser-flag="--disable-web-security"
```

**Plugin Error?**
```bash
# Check pubspec.yaml
flutter pub outdated

# Update dependencies
flutter pub upgrade
```

**Memory Error?**
```bash
# Increase memory
flutter build web --release --dart-define=VM_SERVICE_MAX_MEMORY=4096
```

## 📱 Mobile Build (Jika Web Masih Bermasalah)

Android:
```bash
flutter build apk --release
```

iOS (Mac only):
```bash
flutter build ios --release
```

## 🆘 Need Help?

1. Check **WEB_BUILD_GUIDE.md** untuk dokumentasi lengkap
2. Run `flutter doctor -v` untuk check setup
3. Check Flutter version: `flutter --version`
4. Share browser console error screenshot

## 🎉 Quick Start

**Cara Tercepat:**

```bash
# Windows
build_web.bat release canvaskit

# Mac/Linux  
./build_web.sh release canvaskit

# Manual
flutter clean && flutter pub get && flutter build web --release --web-renderer canvaskit
```

**Test:**
```bash
cd build/web
python -m http.server 8000
# Open http://localhost:8000
```

**Deploy:**
- Firebase: `firebase deploy --only hosting`
- Netlify: `netlify deploy --dir=build/web --prod`
- Vercel: `vercel --prod build/web`

---

💡 **Tip:** Gunakan CanvasKit untuk production, HTML untuk development/testing
