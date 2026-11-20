import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release key: SribeesHub/secrets.out/key.properties (git-ignored), or the path in
// HUB_KEY_PROPERTIES (CI). The Hub's key never changes: losing it means every phone
// must uninstall the Hub to get a new one.
val keyPropsFile = System.getenv("HUB_KEY_PROPERTIES")?.let { file(it) }
    ?: rootProject.file("../../secrets.out/key.properties")
val keyProps = Properties().apply {
    if (keyPropsFile.exists()) load(FileInputStream(keyPropsFile))
}

android {
    namespace = "com.sribees.hub"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.sribees.hub"
        minSdk = flutter.minSdkVersion
        // Silent updates (USER_ACTION_NOT_REQUIRED) need a recent target SDK.
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keyPropsFile.exists()) {
            create("release") {
                storeFile = file(keyProps.getProperty("storeFile"))
                storePassword = keyProps.getProperty("storePassword")
                keyAlias = keyProps.getProperty("keyAlias")
                keyPassword = keyProps.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // No key = no release build (never ship a debug-signed Hub).
            signingConfig = signingConfigs.findByName("release")
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
