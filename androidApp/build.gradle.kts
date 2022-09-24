plugins {
    id("com.android.application")
    kotlin("android")
    kotlin("plugin.serialization")

}

android {
    compileSdk = 32
    defaultConfig {
        applicationId = "com.sonsofcrypto.web3wallet.android"
        minSdk = 29
        targetSdk = 32
        versionCode = 1
        versionName = "1.0"
    }
    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
        }
    }
    namespace = "com.sonsofcrypto.web3wallet.android"
}

dependencies {
    implementation(project(":web3lib"))
    implementation("com.google.android.material:material:1.4.0")
    implementation("androidx.appcompat:appcompat:1.3.1")
    implementation("androidx.constraintlayout:constraintlayout:2.1.0")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-core:${rootProject.ext["serialization_version"]}")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:${rootProject.ext["serialization_version"]}")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-protobuf:${rootProject.ext["serialization_version"]}")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:${rootProject.ext["coroutines_version"]}") {
        version { strictly("${rootProject.ext["coroutines_version"]}") }
    }
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:${rootProject.ext["coroutines_version"]}") {
        version { strictly("${rootProject.ext["coroutines_version"]}") }
    }
}
