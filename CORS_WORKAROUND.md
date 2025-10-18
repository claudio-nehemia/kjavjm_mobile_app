# 🚀 Temporary Workaround: Chrome with CORS Disabled

Sambil menunggu backend fix CORS, Anda bisa test dengan disable CORS di Chrome untuk development.

## ⚠️ WARNING
**JANGAN gunakan cara ini untuk production!**  
Ini hanya untuk development/testing saja.

## 🔧 Cara 1: Chrome dengan CORS Disabled (Windows)

1. **Tutup semua instance Chrome** yang sedang berjalan

2. **Buat shortcut baru Chrome** dengan parameter CORS disabled:

   **Target:**
   ```
   "C:\Program Files\Google\Chrome\Application\chrome.exe" --disable-web-security --user-data-dir="C:\tmp\chrome-dev" --disable-site-isolation-trials
   ```

3. **Run shortcut tersebut**

4. **Test Flutter Web:**
   ```bash
   cd build\web
   python -m http.server 8080
   ```

5. **Buka:** http://localhost:8080

## 🔧 Cara 2: Run Flutter dengan Chrome CORS Disabled

```bash
flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=C:/tmp/chrome-dev"
```

## 🔧 Cara 3: Install CORS Extension (Paling Mudah)

1. **Install Extension:** 
   - [Allow CORS: Access-Control-Allow-Origin](https://chrome.google.com/webstore/detail/allow-cors-access-control/lhobafahddgcelffkeicbaginigeejlf)

2. **Enable extension** saat testing

3. **Test Flutter Web**

## 🎯 Test Command

```bash
# Build
flutter build web --release --tree-shake-icons --dart-define=BASE_URL=https://demo-kjavmj.prosesin.id/api

# Serve
cd build\web
python -m http.server 8080

# Open browser (dengan CORS disabled)
# http://localhost:8080
```

## ✅ Expected Result

Dengan CORS disabled, gambar akan muncul normal:
- ✅ Profile photo terlihat
- ✅ Upload works
- ✅ No statusCode: 0 error

## 📝 Notes

- ❌ **JANGAN** gunakan Chrome dengan CORS disabled untuk browsing normal
- ✅ **HANYA** untuk testing Flutter web development
- 🎯 **SOLUSI PERMANENT:** Fix CORS di backend Laravel (lihat BACKEND_CORS_FIX.md)

---

## 🎨 Alternative: Base64 Image (Jika Backend Tidak Bisa Diubah)

Jika backend developer tidak bisa update CORS, kita bisa pakai base64:

### Backend Changes (Laravel)
```php
// Instead of returning URL, return base64
$user->photo_base64 = base64_encode(Storage::get($user->profile_picture));
```

### Flutter Changes
```dart
// Display base64 image
Image.memory(
  base64Decode(user.photoBase64),
  fit: BoxFit.cover,
)
```

Tapi ini **TIDAK DIREKOMENDASIKAN** karena:
- ❌ File size lebih besar (base64 = +33% size)
- ❌ Tidak bisa di-cache oleh browser
- ❌ Slower performance

**RECOMMENDED:** Fix CORS di backend! 🎯
