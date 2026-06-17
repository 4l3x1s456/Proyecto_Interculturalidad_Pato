# Reglas de R8/ProGuard para el release.

# --- TensorFlow Lite (tflite_flutter) ---
# El delegado GPU es OPCIONAL; sus clases no se empaquetan y R8 las reporta
# como faltantes. Se conservan las clases de TFLite y se ignoran esos avisos.
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.gpu.**
-dontwarn org.tensorflow.**

# --- Firebase / Google Play Services (usan reflexion) ---
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# --- Flutter ---
-dontwarn io.flutter.embedding.**
