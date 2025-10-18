# 🔍 Debug Image Loading Issue - Web

## Masalah
- ✅ Upload foto berhasil (tersimpan ke database)
- ❌ Foto tidak muncul di web (hanya initial)
- ✅ Foto muncul di mobile

## Kemungkinan Penyebab

### 1. URL Format Salah
**Test:**
```dart
// Check console logs:
🖼️ [UserAvatar] Loading image...
   Platform: Web
   Raw photoUrl: storage/photos/abc123.jpg
   Full URL: https://demo-kjavmj.prosesin.id/storage/photos/abc123.jpg?t=1729234567890
```

**Expected:**
- Raw photoUrl harus ada (tidak null atau empty)
- Full URL harus valid (https://...)
- Timestamp untuk cache busting

**If Error:**
- ℹ️ No photoUrl provided → Database tidak return photo_url
- Full URL salah → Check BASE_URL configuration

### 2. CORS Error
**Test di Browser Console:**
```
1. Open DevTools (F12)
2. Go to Console tab
3. Look for CORS errors:
   ❌ Access to image at 'https://...' from origin 'http://localhost:8080' 
      has been blocked by CORS policy
```

**Solution:**
Server harus send CORS headers:
```php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, Accept");
```

### 3. Image URL 404
**Test:**
```
1. Copy Full URL from console log
2. Paste di browser tab baru
3. Check result:
   - ✅ Image loads → CORS issue
   - ❌ 404 Not Found → File tidak ada di server
   - ❌ 403 Forbidden → Permission issue
```

**If 404:**
- Check server storage path
- Verify file upload successful
- Check symlink: `php artisan storage:link`

### 4. Network Tab Check
**Test:**
```
1. Open DevTools → Network tab
2. Filter: Img
3. Refresh page
4. Look for image request:
   - Status 200 → OK but not displaying (render issue)
   - Status 404 → File not found
   - Status 403 → Permission denied
   - (failed) → CORS or network error
```

## Debug Steps

### Step 1: Check Console Logs
```
Run app in web, open console (F12), check logs:

✅ Good Logs:
🖼️ [UserAvatar] Loading image...
   Platform: Web
   Raw photoUrl: storage/photos/user_123.jpg
   Full URL: https://demo-kjavmj.prosesin.id/storage/photos/user_123.jpg?t=...
✅ [UserAvatar] Image loaded successfully

❌ Bad Logs:
ℹ️ [UserAvatar] No photoUrl provided, showing initials
→ Database tidak return photo_url

❌ [UserAvatar] Error loading image
   Error: NetworkImageLoadException
→ CORS atau network issue
```

### Step 2: Test Image URL Directly
```
1. Copy Full URL from console
2. Open di browser tab baru
3. Jika image muncul → CORS issue
4. Jika 404 → File tidak ada
```

### Step 3: Check API Response
```
Open DevTools → Network → XHR
Find API call yang get user data:
- /api/profile
- /api/dashboard
- /api/auth/me

Check response JSON:
{
  "user": {
    "name": "...",
    "photo_url": "storage/photos/xxx.jpg"  // ← Must exist!
  }
}

If photo_url is null/empty → Upload tidak update database
```

### Step 4: Check Upload Response
```
Saat upload foto, check response di Network tab:

POST /api/profile/update-photo

Response should be:
{
  "success": true,
  "message": "Photo updated",
  "user": {
    "photo_url": "storage/photos/newfile.jpg"  // ← New photo URL
  }
}
```

## Fixes Applied

### 1. ✅ Enhanced Logging
```dart
// Added detailed logs to UserAvatar:
print('🖼️ [UserAvatar] Loading image...');
print('   Platform: Web');
print('   Raw photoUrl: $photoUrl');
print('   Full URL: $fullUrl');
```

### 2. ✅ Cache Busting on Web
```dart
// Force reload image on web:
if (kIsWeb) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  fullUrl = '$fullUrl?t=$timestamp';
}
```

### 3. ✅ Simplified Image Loading
```dart
// Use Image.network for both web and mobile:
Image.network(
  fullUrl,
  fit: BoxFit.cover,
  loadingBuilder: ...,
  errorBuilder: ...,
)
```

### 4. ✅ Better Error Handling
```dart
errorBuilder: (context, error, stackTrace) {
  print('❌ [UserAvatar] Error loading image');
  print('   URL: $fullUrl');
  print('   Error: $error');
  return _buildInitialsAvatar();
}
```

## Quick Test Checklist

Open http://localhost:8080 dan check:

- [ ] Login berhasil
- [ ] Dashboard loads
- [ ] Open browser console (F12)
- [ ] Look for logs: `🖼️ [UserAvatar] Loading image...`
- [ ] Check if "Raw photoUrl" has value
- [ ] Check if "Full URL" is correct
- [ ] Look for success: `✅ [UserAvatar] Image loaded successfully`
- [ ] Or error: `❌ [UserAvatar] Error loading image`
- [ ] Copy Full URL, test in browser tab
- [ ] Check Network tab for image request status

## Most Common Issues

### Issue 1: photoUrl is null
**Symptom:**
```
ℹ️ [UserAvatar] No photoUrl provided
```

**Solution:**
Database tidak return photo_url. Check:
1. Upload response includes photo_url
2. Auth state di-update dengan photo_url baru
3. API /profile atau /dashboard return photo_url

### Issue 2: CORS Error
**Symptom:**
```
Access blocked by CORS policy
```

**Solution:**
Add CORS headers di server Laravel:
```php
// In middleware or controller:
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
```

### Issue 3: 404 Not Found
**Symptom:**
```
❌ [UserAvatar] Error: NetworkImage provider failed
```

**Solution:**
1. Run: `php artisan storage:link`
2. Check file exists: `storage/app/public/photos/`
3. Check URL format matches server path

### Issue 4: Image Cached
**Symptom:**
- Old photo still showing
- Upload successful but no visual change

**Solution:**
- ✅ Already fixed with cache busting (`?t=timestamp`)
- Force reload: Ctrl+Shift+R

## Server Requirements

### Laravel Storage Setup
```bash
# 1. Create symbolic link
php artisan storage:link

# 2. Set permissions
chmod -R 755 storage/
chmod -R 755 public/storage/

# 3. Check .env
FILESYSTEM_DISK=public
```

### Apache/Nginx CORS
```apache
# Apache (.htaccess)
Header set Access-Control-Allow-Origin "*"
Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
Header set Access-Control-Allow-Headers "Content-Type, Authorization"
```

```nginx
# Nginx (server block)
add_header Access-Control-Allow-Origin *;
add_header Access-Control-Allow-Methods 'GET, POST, PUT, DELETE, OPTIONS';
add_header Access-Control-Allow-Headers 'Content-Type, Authorization';
```

## Next Steps

1. **Open web app:** http://localhost:8080
2. **Open console:** Press F12
3. **Login** dengan account yang sudah upload foto
4. **Check logs** untuk debug info
5. **Report findings:**
   - What logs do you see?
   - What's the Full URL?
   - Does URL work when opened directly?
   - Any CORS errors?
   - What's the network tab status?

**With this info, I can pinpoint the exact issue!** 🎯
