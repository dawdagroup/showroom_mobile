# Keep Error Prone Annotations
-keep class com.google.errorprone.annotations.** { *; }

# Keep javax.annotation Annotations
-keep class javax.annotation.** { *; }

# Keep Crypto Tink Classes
-keep class com.google.crypto.tink.** { *; }

# Add at the bottom of your proguard-rules.pro
-dontwarn javax.lang.model.element.Modifier