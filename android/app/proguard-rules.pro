# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep OkHttp/Dio for network calls
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**

# Keep Dio specific classes
-keep class dio.** { *; }
-dontwarn dio.**

# Keep JSON/Gson parser
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep Retrofit if used
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# Keep Kotlin metadata
-keepclassmembers class kotlin.Metadata { *; }

# Keep network security config classes
-keep class android.security.NetworkSecurityPolicy { *; }
-dontwarn android.security.NetworkSecurityPolicy

# Keep SSL/TLS classes
-keep class javax.net.ssl.** { *; }
-dontwarn javax.net.ssl.**

# Keep certificates and trust managers
-keep class java.security.cert.** { *; }
-keep class javax.security.cert.** { *; }
