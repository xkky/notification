plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services 插件 - 解析 google-services.json,为极光 FCM 通道提供配置
    // 暂时禁用: 需放置 google-services.json 到 android/app/ 后方可启用
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.notification_project"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13113456"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.xkky.obsidian.plan.notification"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 极光推送 manifestPlaceholders 由 jpush_flutter_android 插件根据
        // pubspec.yaml 中的 jpush_android.* 节点自动注入,无需在此手动配置。
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

    // Firebase Messaging - 极光 FCM 通道依赖
    // 海外设备(有 Google Play 服务)会自动走 FCM,国内走厂商通道
    // 版本需与 jpush_flutter_android 内部 FCM 插件兼容
    implementation("com.google.firebase:firebase-messaging:23.4.1")
}

flutter {
    source = "../.."
}
