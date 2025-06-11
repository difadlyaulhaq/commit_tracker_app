plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase config
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin (harus di bawah android & kotlin)
}

android {
    namespace = "com.example.commit_tracker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.commit_tracker"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        // Aktifkan Java 11 dan desugaring
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Desugar JDK libraries agar bisa pakai java.time, dll
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")


    // Tambahan lain jika dibutuhkan
    implementation("androidx.core:core-ktx:1.12.0")
}
