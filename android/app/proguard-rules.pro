# Flutter enables R8 for release builds, which is what makes these necessary.
# Debug builds never hit any of it, so a release APK is the only place these
# failures show up.

# flutter_local_notifications keeps its pending-notification store as JSON via
# Gson, and Gson needs generic signatures at runtime. R8 strips them, after
# which every call that touches the store dies with
#   java.lang.RuntimeException: Missing type parameter.
# The failure is silent: NotificationService catches it and logs, so reminders
# simply never fire and nothing says why.
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Gson's own documented R8 rules — TypeToken subclasses must survive with their
# type arguments intact.
-keep class * extends com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
