# 🌐 Panduan Build Flutter Web

## ❌ Error yang Terjadi

Error `Uncaught Error at kC.b5Z` biasanya disebabkan oleh:
1. **Plugin tidak kompatibel dengan web** (geolocator, file_picker, dll)
2. **File .env tidak tersedia** di web build
3. **Missing permissions** atau konfigurasi web
4. **CORS issues** dengan API backend

## ✅ Solusi yang Sudah Diterapkan

### 1. **Error Handling untuk .env**
```dart
// Di main.dart - sekarang sudah ada try-catch
try {
  await dotenv.load(fileName: "assets/.env");
} catch (e) {
  debugPrint('Warning: Could not load .env file: $e');
  debugPrint('Using default configuration for web');
}
```

### 2. **Web Compatibility untuk Location Service**
```dart
// Di location_service.dart - sekarang sudah support web
if (kIsWeb) {
  // Browser akan handle permission sendiri
  return LocationPermission.whileInUse;
}
```

### 3. **Loading Indicator di Web**
File `web/index.html` sudah diupdate dengan:
- Loading indicator
- Error handling
- Service worker support

## 🚀 Cara Build Web dengan Benar

### Build untuk Development (dengan debug info)

```bash
# Clean terlebih dahulu
flutter clean

# Get dependencies
flutter pub get

# Build web (canvaskit - better compatibility)
flutter build web --web-renderer canvaskit --dart-define=API_BASE_URL=https://your-api.com

# Atau dengan HTML renderer (lebih ringan, tapi kadang bermasalah)
flutter build web --web-renderer html --dart-define=API_BASE_URL=https://your-api.com
```

### Build untuk Production

```bash
# Build dengan optimization
flutter build web --release --web-renderer canvaskit --dart-define=API_BASE_URL=https://your-api.com

# Build dengan source maps (untuk debugging production)
flutter build web --release --web-renderer canvaskit --source-maps --dart-define=API_BASE_URL=https://your-api.com
```

### Build dengan Profile Mode (untuk performance testing)

```bash
flutter build web --profile --web-renderer canvaskit --dart-define=API_BASE_URL=https://your-api.com
```

## 🔧 Troubleshooting

### 1. **Error saat build - Plugin tidak support web**

**Solusi:** Tambahkan conditional import

```dart
// Gunakan kIsWeb
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  // Web-specific code
} else {
  // Mobile-specific code
}
```

### 2. **CORS Error saat hit API**

**Solusi:** Tambahkan CORS headers di backend Anda:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

Atau gunakan proxy di development:

```bash
# Install cors-anywhere atau gunakan browser extension
# Chrome: Allow CORS
# Firefox: CORS Everywhere
```

### 3. **File .env tidak terbaca**

**Solusi:** Gunakan `--dart-define` saat build:

```bash
flutter build web --dart-define=API_BASE_URL=https://api.com --dart-define=API_KEY=your-key
```

Atau buat file `web_config.dart` (sudah dibuat di `lib/core/config/web_config.dart`)

### 4. **Ukuran build terlalu besar**

**Solusi:**

```bash
# Gunakan HTML renderer (lebih kecil)
flutter build web --release --web-renderer html

# Atau split defer loading
flutter build web --release --web-renderer canvaskit --split-debug-info=build/debug-info
```

### 5. **Performance buruk di web**

**Solusi:**

```bash
# Build dengan tree-shaking
flutter build web --release --tree-shake-icons

# Atau gunakan CanvasKit
flutter build web --release --web-renderer canvaskit
```

## 📋 Checklist Sebelum Build Web

- [ ] Cek semua plugin support web (`flutter pub outdated`)
- [ ] Test di `flutter run -d chrome` terlebih dahulu
- [ ] Pastikan API endpoint benar
- [ ] Setup CORS di backend
- [ ] Test loading time (target <3 detik)
- [ ] Test di berbagai browser (Chrome, Firefox, Safari)
- [ ] Check responsive design
- [ ] Test file upload (jika ada)
- [ ] Test location permission (jika ada)

## 🌍 Deploy Web Build

### Deploy ke Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Init
firebase init hosting

# Build
flutter build web --release --web-renderer canvaskit

# Deploy
firebase deploy --only hosting
```

### Deploy ke Netlify

```bash
# Build
flutter build web --release --web-renderer canvaskit

# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --dir=build/web --prod
```

### Deploy ke GitHub Pages

```bash
# Build dengan base-href
flutter build web --release --base-href /repo-name/

# Copy ke docs folder atau gh-pages branch
cp -r build/web/* docs/

# Push
git add docs/
git commit -m "Deploy to GitHub Pages"
git push
```

### Deploy ke Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Build
flutter build web --release --web-renderer canvaskit

# Deploy
vercel --prod build/web
```

## 🎯 Web Renderer Comparison

| Renderer | Size | Performance | Compatibility | Best For |
|----------|------|-------------|---------------|----------|
| **canvaskit** | Lebih besar (~2MB+) | Tinggi | Chrome, Firefox | Production apps dengan animasi complex |
| **html** | Lebih kecil (~200KB) | Sedang | Semua browser | Simple apps, content-heavy |
| **auto** | Varies | Varies | Auto-detect | Flutter decides based on device |

## 📱 Testing di Local

```bash
# Run di Chrome
flutter run -d chrome

# Run di Edge
flutter run -d edge

# Run dengan hot reload
flutter run -d chrome --web-hot-restart

# Run dengan specific renderer
flutter run -d chrome --web-renderer html
flutter run -d chrome --web-renderer canvaskit
```

## 🔐 Environment Variables untuk Web

**Opsi 1: Dart Define (Recommended)**
```bash
flutter build web --dart-define=API_BASE_URL=https://api.com
```

**Opsi 2: Web Config File**
```dart
// lib/core/config/web_config.dart (sudah dibuat)
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://api.example.com',
);
```

**Opsi 3: Index.html Script**
```html
<script>
  window.API_BASE_URL = 'https://api.example.com';
</script>
```

## 📊 Performance Optimization

### 1. **Code Splitting**
```bash
flutter build web --release --split-debug-info=build/debug
```

### 2. **Tree Shaking**
```bash
flutter build web --release --tree-shake-icons
```

### 3. **Compression**
```bash
# Install gzip
# Compress output files
cd build/web
gzip -k *.js
gzip -k *.css
```

### 4. **Caching Strategy**
Update `web/index.html` dengan service worker untuk caching

## 🆘 Common Issues

### Issue: "Failed to load .env"
**Fix:** Sudah ditangani dengan try-catch di `main.dart`

### Issue: "Plugin not available for web"
**Fix:** Check `pubspec.yaml` dan tambahkan web support atau gunakan alternatif

### Issue: "CORS blocked"
**Fix:** Setup CORS di backend atau gunakan proxy

### Issue: "White screen on load"
**Fix:** Check browser console, kemungkinan JavaScript error

### Issue: "Slow loading"
**Fix:** Gunakan CanvasKit atau optimize images/assets

## 📚 Resources

- [Flutter Web Docs](https://docs.flutter.dev/platform-integration/web)
- [Web Renderers](https://docs.flutter.dev/platform-integration/web/renderers)
- [Deploying Web Apps](https://docs.flutter.dev/deployment/web)
- [Web FAQ](https://docs.flutter.dev/platform-integration/web/faq)

## 🎉 Next Steps

1. **Test build web:**
   ```bash
   flutter clean
   flutter pub get
   flutter build web --release --web-renderer canvaskit
   ```

2. **Run locally:**
   ```bash
   cd build/web
   python -m http.server 8000
   # Buka http://localhost:8000
   ```

3. **Deploy ke hosting pilihan Anda**

4. **Setup CI/CD** untuk auto-deploy (GitHub Actions, Codemagic, dll)
