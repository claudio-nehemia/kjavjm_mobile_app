# CORS Configuration Fix for Flutter Web

## 🚨 Problem
Flutter web app tidak bisa load image dari storage karena CORS error:
```
Error: HTTP request failed, statusCode: 0
```

## ✅ Solution: Update Laravel CORS Config

### 1. Edit `config/cors.php`

```php
<?php

return [
    'paths' => [
        'api/*',
        'storage/*',              // ✅ TAMBAHKAN INI - Untuk akses file storage
        'sanctum/csrf-cookie'
    ],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        'http://localhost:8080',           // Flutter dev server
        'http://localhost:*',              // Any localhost port
        'http://127.0.0.1:*',
        // TODO: Tambahkan production domain
        // 'https://your-production-domain.com',
    ],

    'allowed_origins_patterns' => [
        '/^http:\/\/localhost(:\d+)?$/',   // Pattern untuk localhost dengan port
        '/^http:\/\/127\.0\.0\.1(:\d+)?$/',
    ],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => true,        // ✅ Untuk authentication dengan token
];
```

### 2. Restart Laravel Server

```bash
php artisan config:clear
php artisan cache:clear
php artisan serve
```

### 3. Test Image URL

Buka browser dan test langsung:
```
https://demo-kjavmj.prosesin.id/storage/profile_pictures/profile_5_1760720463.jpg
```

Harus bisa diakses tanpa error.

## 🔧 Alternative: Apache .htaccess

Jika hosting menggunakan Apache, tambahkan di `public/.htaccess`:

```apache
<IfModule mod_headers.c>
    # Allow CORS for development
    Header always set Access-Control-Allow-Origin "*"
    Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header always set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With, Accept"
    Header always set Access-Control-Allow-Credentials "true"
    
    # Handle preflight requests
    RewriteEngine On
    RewriteCond %{REQUEST_METHOD} OPTIONS
    RewriteRule ^(.*)$ $1 [R=200,L]
</IfModule>
```

## 🔒 Production Configuration

Untuk production, jangan pakai `*` tapi specify domain:

```php
'allowed_origins' => [
    'https://your-production-domain.com',
    'https://www.your-production-domain.com',
],
```

## ✅ How to Verify CORS is Working

### Method 1: Browser Console
1. Open https://demo-kjavmj.prosesin.id/storage/profile_pictures/test.jpg
2. Check Network tab in DevTools
3. Look for response headers:
   ```
   Access-Control-Allow-Origin: *
   Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
   Access-Control-Allow-Headers: Content-Type, Authorization
   ```

### Method 2: CURL Test
```bash
curl -I -X GET https://demo-kjavmj.prosesin.id/storage/profile_pictures/test.jpg
```

Should include:
```
Access-Control-Allow-Origin: *
```

## 🎯 Expected Result

After fixing CORS:
- ✅ Image loading works in Flutter web
- ✅ No more statusCode: 0 errors
- ✅ Upload and display work seamlessly

## 📞 Contact

If you need help implementing this, contact the backend developer with this file.

**Issue:** CORS blocking Flutter web from accessing storage images
**Fix Required:** Update `config/cors.php` to allow localhost access
**Priority:** High - Blocking Flutter web development
