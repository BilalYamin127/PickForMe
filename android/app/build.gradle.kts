import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseProperties = Properties()
val releasePropertiesFile = rootProject.file("key.properties")
if (releasePropertiesFile.exists()) {
    releasePropertiesFile.inputStream().use { releaseProperties.load(it) }
}
fun releaseValue(property: String, environment: String): String? =
    System.getenv(environment)?.takeIf { it.isNotBlank() }
        ?: releaseProperties.getProperty(property)?.takeIf { it.isNotBlank() }

val uploadStoreFile = releaseValue("storeFile", "PICKFORME_KEYSTORE_PATH")
val uploadStorePassword = releaseValue("storePassword", "PICKFORME_STORE_PASSWORD")
val uploadKeyAlias = releaseValue("keyAlias", "PICKFORME_KEY_ALIAS")
val uploadKeyPassword = releaseValue("keyPassword", "PICKFORME_KEY_PASSWORD")
val hasReleaseSigning = listOf(uploadStoreFile, uploadStorePassword, uploadKeyAlias, uploadKeyPassword)
    .all { it != null }
// CI preview APKs must explicitly opt in; Play bundles never allow debug signing.
val allowPreviewSigning = providers.gradleProperty("allowPreviewSigning").orNull == "true"
val isReleaseTask = gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) }
val isBundleTask = gradle.startParameter.taskNames.any { it.contains("bundle", ignoreCase = true) }
if (isReleaseTask && !hasReleaseSigning && (!allowPreviewSigning || isBundleTask)) {
    throw GradleException("Release signing is required. Configure android/key.properties or PICKFORME signing environment variables. Debug signing is not allowed for Play bundles.")
}

android {
    namespace = "com.bilalyamin.pick_for_me"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    defaultConfig {
        applicationId = "com.bilalyamin.pick_for_me"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    signingConfigs {
        if (hasReleaseSigning) {
            create("upload") {
                storeFile = rootProject.file(uploadStoreFile!!)
                storePassword = uploadStorePassword
                keyAlias = uploadKeyAlias
                keyPassword = uploadKeyPassword
            }
        }
    }
    buildTypes {
        release {
            signingConfig = when {
                hasReleaseSigning -> signingConfigs.getByName("upload")
                allowPreviewSigning -> signingConfigs.getByName("debug")
                else -> null
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}
flutter { source = "../.." }
