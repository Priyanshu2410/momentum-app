import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing. Android only allows an update to install over an existing
// app when both are signed with the same key, so releases must not use the
// per-machine debug key — CI's would differ from yours and every update would
// fail with "App not installed".
//
// Locally: android/key.properties (gitignored).
// In CI:   MOMENTUM_KEYSTORE / _STORE_PASSWORD / _KEY_ALIAS / _KEY_PASSWORD.
// See SETUP.md for the one-time keystore steps.
val keyProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

fun signing(name: String, key: String): String? =
    System.getenv(name) ?: keyProperties.getProperty(key)

val keystorePath = signing("MOMENTUM_KEYSTORE", "storeFile")

android {
    namespace = "com.momentum.momentum"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.momentum.momentum"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // API 26 per the brief — also the floor for exact alarms.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePath != null) {
            create("release") {
                storeFile = file(keystorePath)
                storePassword = signing("MOMENTUM_STORE_PASSWORD", "storePassword")
                keyAlias = signing("MOMENTUM_KEY_ALIAS", "keyAlias")
                keyPassword = signing("MOMENTUM_KEY_PASSWORD", "keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Falls back to the debug key when no keystore is configured, so a
            // fresh clone can still build a release APK — it just cannot ship
            // one that updates cleanly over a previous install.
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
