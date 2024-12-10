# Existing ProGuard rules (if any) should remain unchanged.

# Suppress warnings for missing annotation classes
-dontwarn com.google.errorprone.annotations.CanIgnoreReturnValue
-dontwarn com.google.errorprone.annotations.CheckReturnValue
-dontwarn com.google.errorprone.annotations.Immutable
-dontwarn com.google.errorprone.annotations.RestrictedApi
-dontwarn javax.annotation.Nullable
-dontwarn javax.annotation.concurrent.GuardedBy

# Google Play Core library warnings
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Chaquopy Python rules
-keep class com.chaquo.python.** { *; }
-dontwarn com.chaquo.python.**

# Keep Python module classes and methods
-keep class org.python.** { *; }
-dontwarn org.python.**

# Python Dependencies
-keep class six.** { *; }
-dontwarn six.**

# Requests and its dependencies
-keep class requests.** { *; }
-keep class urllib3.** { *; }
-keep class certifi.** { *; }
-keep class charset_normalizer.** { *; }
-keep class idna.** { *; }
-dontwarn requests.**
-dontwarn urllib3.**
-dontwarn certifi.**
-dontwarn charset_normalizer.**
-dontwarn idna.**

# Kia API libraries
-keep class kia_uvo.** { *; }
-keep class hyundai_kia_connect_api.** { *; }
-dontwarn kia_uvo.**
-dontwarn hyundai_kia_connect_api.**

# Keep the Python bridge classes
-keepclassmembers class * {
    @com.chaquo.python.annotation.* *;
}

# Keep specific Python bridge methods
-keepclassmembers class com.example.my_kia_query.** {
    @com.chaquo.python.annotation.Python *;
}

# Keep the KiaBridge class and its methods
-keep class com.example.my_kia_query.KiaBridge { *; }
-keepclassmembers class com.example.my_kia_query.KiaBridge {
    void authenticate(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String);
    java.lang.String getVehicles();
    boolean refreshVehicleData();
}

# Kotlin Coroutines rules
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}
-keepclassmembers class kotlin.coroutines.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep your custom Python bridge classes
-keep class com.example.my_kia_query.** { *; }

# JSON classes
-keep class org.json.** { *; }
-keep class * implements org.json.** { *; }

# Keep any native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# DateTime handling
-keep class java.time.** { *; }
-keep class org.joda.time.** { *; }
-dontwarn org.joda.time.**

# Keep Python datetime
-keep class datetime.** { *; }
-dontwarn datetime.**

# Keep VehicleManager and related classes
-keep class * extends com.chaquo.python.PyObject { *; }
-keepclassmembers class * extends com.chaquo.python.PyObject {
    <init>(long);
}

# Keep Play Core library classes
-keep class com.google.android.play.core.** { *; }

# SSL/TLS classes (needed for requests/urllib3)
-keep class javax.net.ssl.** { *; }
-dontwarn javax.net.ssl.**
-keep class org.apache.http.** { *; }
-dontwarn org.apache.http.**
