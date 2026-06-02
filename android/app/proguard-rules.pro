# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Agora
-keep class io.agora.** { *; }
-dontwarn io.agora.**

# Socket.IO
-keep class io.socket.** { *; }
-dontwarn io.socket.**

# OkHttp (used by socket.io)
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**

# Gson (used internally)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep your app classes
-keep class com.example.flamingo_child.** { *; }
-keep class com.example.flamingo_parent.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# Permission handler
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# Shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# HTTP
-keep class com.squareup.** { *; }
-dontwarn com.squareup.**

# General rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-dontwarn java.lang.invoke.**
-dontwarn **$$Lambda$*