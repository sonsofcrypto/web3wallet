import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework

plugins {
    kotlin("multiplatform")
    id("com.android.library")
}

kotlin {
    android()
    val xcf = XCFramework()
    val frameworkPath = project.file("src/iosMain/libs/CoreCrypto").absolutePath
    listOf(
        iosX64() {
            compilations.getByName("main") {
                val CoreCrypto by cinterops.creating {
                    defFile("$frameworkPath/ios-arm64_x86_64-simulator/CoreCrypto.def")
                    compilerOpts("-framework", "CoreCrypto", "-F$frameworkPath/ios-arm64_x86_64-simulator/")
                }
            }
            binaries.all {
                linkerOpts("-framework", "CoreCrypto", "-F$frameworkPath/ios-arm64_x86_64-simulator/")
            }
        },
        iosArm64() {
            compilations.getByName("main") {
                val CoreCrypto by cinterops.creating {
                    defFile("$frameworkPath/ios-arm64/CoreCrypto.def")
                    compilerOpts("-framework", "CoreCrypto", "-F$frameworkPath/ios-arm64/")
                }
            }
            binaries.all {
                linkerOpts("-framework", "CoreCrypto", "-F$frameworkPath/ios-arm64/")
            }
        },
        iosSimulatorArm64() {
            compilations.getByName("main") {
                val CoreCrypto by cinterops.creating {
                    defFile("$frameworkPath/ios-arm64_x86_64-simulator/CoreCrypto.def")
                    compilerOpts("-framework", "CoreCrypto", "-F$frameworkPath/ios-arm64_x86_64-simulator/")
                }
            }
            binaries.all {
                linkerOpts("-framework", "CoreCrypto", "-F$frameworkPath/ios-arm64_x86_64-simulator/")
            }
        },
    ).forEach {
        it.binaries.framework {
            baseName = "web3lib_provider"
            xcf.add(this)
        }
    }

    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation(project(":web3lib_utils"))
                implementation(project(":web3lib_core"))
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:${rootProject.ext["coroutines_version"]}") {
                    version {
                        strictly("${rootProject.ext["coroutines_version"]}")
                    }
                }
            }
        }
        val commonTest by getting {
            dependencies {
                implementation(kotlin("test"))
            }
        }
        val androidMain by getting
        val androidTest by getting
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