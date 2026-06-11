plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.motivi.exelbid.v2.exelbid_plugin_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.motivi.exelbid.v2.exelbid_plugin_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 미디에이션 네트워크 SDK — 호스트 앱이 "사용하는 네트워크"만 추가한다.
    // (플러그인은 어댑터 코드만 compileOnly로 제공하므로 SDK는 여기서 포함.)
    // AdFit(com.kakao.adfit)은 Kakao maven 저장소가 필요하다.
    implementation("com.google.android.gms:play-services-ads:23.4.0") // AdMob
    implementation("com.facebook.android:audience-network-sdk:6.20.0") // FAN
    implementation("com.kakao.adfit:ads-base:3.12.9") // AdFit
}
