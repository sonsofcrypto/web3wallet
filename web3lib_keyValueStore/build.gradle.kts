import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework

plugins {
    kotlin("multiplatform")
    kotlin("plugin.serialization")
    id("com.android.library")
}

kotlin {
    android()
    
    val xcf = XCFramework()
    listOf(
        iosX64(),
        iosArm64(),
        iosSimulatorArm64()
    ).forEach {
        it.binaries.framework {
            baseName = "web3lib_keyValueStore"
            xcf.add(this)
        }
    }

    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation("com.russhwolf:multiplatform-settings:${rootProject.ext["settings_version"]}")
                implementation("com.russhwolf:multiplatform-settings-serialization:${rootProject.ext["settings_version"]}")
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-core:${rootProject.ext["serialization_version"]}")
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:${rootProject.ext["serialization_version"]}")
            }
        }
        val commonTest by getting {
            dependencies {
                dependsOn(commonMain)
                implementation(kotlin("test"))
                implementation(kotlin("test-common"))
                implementation(kotlin("test-annotations-common"))
            }
        }
        val androidMain by getting {
            dependencies {
                implementation("com.russhwolf:multiplatform-settings:${rootProject.ext["settings_version"]}")
                implementation("com.russhwolf:multiplatform-settings-serialization:${rootProject.ext["settings_version"]}")
            }
        }
        val androidTest by getting {
            dependencies {
                implementation(kotlin("test"))
                implementation(kotlin("test-junit"))
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-core:${rootProject.ext["serialization_version"]}")
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:${rootProject.ext["serialization_version"]}")
            }
        }
        val iosX64Main by getting
        val iosArm64Main by getting
        val iosSimulatorArm64Main by getting
        val iosMain by creating {
            dependsOn(commonMain)
            iosX64Main.dependsOn(this)
            iosArm64Main.dependsOn(this)
            iosSimulatorArm64Main.dependsOn(this)
        }
        val iosX64Test by getting
        val iosArm64Test by getting
        val iosSimulatorArm64Test by getting
        val iosTest by creating {
            dependsOn(commonTest)
            iosX64Test.dependsOn(this)
            iosArm64Test.dependsOn(this)
            iosSimulatorArm64Test.dependsOn(this)
        }
    }
}

android {
    compileSdk = 32
    sourceSets["main"].manifest.srcFile("src/androidMain/AndroidManifest.xml")
    defaultConfig {
        minSdk = 29
        targetSdk = 32
    }
}

val serializationVersion = "1.3.3"

dependencies {
    implementation("com.russhwolf:multiplatform-settings:${rootProject.ext["settings_version"]}")
    implementation("com.russhwolf:multiplatform-settings-serialization:${rootProject.ext["settings_version"]}")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-core:${rootProject.ext["serialization_version"]}")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:${rootProject.ext["serialization_version"]}")
}
