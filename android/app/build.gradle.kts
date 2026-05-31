import java.io.File
import java.io.FileInputStream
import java.util.Properties

val keystoreProperties = Properties()
val repoRootDir: File = rootProject.projectDir.parentFile
val keyPropertiesCandidates =
    listOf(
        File(repoRootDir, "key.properties"),
        rootProject.file("key.properties"),
    )
val keystorePropertiesFile = keyPropertiesCandidates.firstOrNull { it.exists() }

if (keystorePropertiesFile != null) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

fun signingProperty(name: String): String? =
    keystoreProperties.getProperty(name)?.takeIf { it.isNotBlank() }

val hasReleaseSigningProperties =
    listOf("keyAlias", "keyPassword", "storeFile", "storePassword")
        .all { signingProperty(it) != null }

plugins {
    id("com.android.application")
    id("kotlin-android")
    
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.auth_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        
        applicationId = "com.example.auth_app"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appLabel"] = "Rahhala"
    }

    flavorDimensions += "environment"

    productFlavors {
        create("development") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["appLabel"] = "Rahhala Dev"
        }

        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            manifestPlaceholders["appLabel"] = "Rahhala Staging"
        }

        create("production") {
            dimension = "environment"
            manifestPlaceholders["appLabel"] = "Rahhala"
        }
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigningProperties) {
                keyAlias = signingProperty("keyAlias")!!
                keyPassword = signingProperty("keyPassword")!!
                val configuredStoreFile = File(signingProperty("storeFile")!!)
                storeFile =
                    if (configuredStoreFile.isAbsolute) {
                        configuredStoreFile
                    } else {
                        File(keystorePropertiesFile!!.parentFile, configuredStoreFile.path)
                    }
                storePassword = signingProperty("storePassword")!!
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (hasReleaseSigningProperties) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

flutter {
    source = "../.."
}

tasks.register("copyProductionReleaseApkForFlutter") {
    dependsOn("assembleProductionRelease")

    doLast {
        val flutterApkDir = File(repoRootDir, "build/app/outputs/flutter-apk")
        val productionApk = File(flutterApkDir, "app-production-release.apk")

        if (productionApk.exists()) {
            productionApk.copyTo(File(flutterApkDir, "app-release.apk"), overwrite = true)
        }

        val productionSha1 = File(flutterApkDir, "app-production-release.apk.sha1")
        if (productionSha1.exists()) {
            productionSha1.copyTo(
                File(flutterApkDir, "app-release.apk.sha1"),
                overwrite = true,
            )
        }
    }
}

tasks.matching { it.name == "assembleRelease" }.configureEach {
    finalizedBy("copyProductionReleaseApkForFlutter")
}
