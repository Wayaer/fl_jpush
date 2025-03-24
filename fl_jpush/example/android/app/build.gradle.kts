plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.jpush.example"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    defaultConfig {
        applicationId = "com.jpush.example"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["JPUSH_PKGNAME"] = "com.jpush.example"
        // JPush 上注册的包名对应的 Appkey.
        manifestPlaceholders["JPUSH_APPKEY"] = "3af087cca42c9f95df54ab89"
        manifestPlaceholders["JPUSH_CHANNEL"] = "flutter"
        // 下面是多厂商配置，如需要开通使用请联系技术支持
        // 如果不需要使用，预留空字段即可
        manifestPlaceholders["MEIZU_APPKEY"] = "MZ-1f5fc5c3fc994610bca9f786780fbf5b"
        manifestPlaceholders["MEIZU_APPID"] = "MZ-148373"
        manifestPlaceholders["XIAOMI_APPID"] = "MI-2882303761518374309"
        manifestPlaceholders["XIAOMI_APPKEY"] = "MI-5361837424309"
        manifestPlaceholders["OPPO_APPKEY"] = "OP-2323f82cf0c244a6b0a3bab2742a738a"
        manifestPlaceholders["OPPO_APPID"] = "OP-30266024"
        manifestPlaceholders["OPPO_APPSECRET"] = "OP-9d6c485dd03c41b083fc688ab063d4c6"
        manifestPlaceholders["VIVO_APPKEY"] = "dc885006bf3147f45b2a7293b81234ee"
        manifestPlaceholders["VIVO_APPID"] = "103892077"
        manifestPlaceholders["HUAWEI_APPID"] = "102086831"
        manifestPlaceholders["HUAWEI_CPID"] = "2850086000347619388"
        manifestPlaceholders["HONOR_APPID"] = ""
    }
    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
