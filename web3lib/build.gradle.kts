import com.codingfeline.buildkonfig.compiler.FieldSpec.Type
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework
import java.util.*

plugins {
    kotlin("multiplatform")
    kotlin("plugin.serialization")
    id("com.android.library")
    id("com.codingfeline.buildkonfig")
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
            baseName = "web3lib"
            xcf.add(this)
        }
    }

    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-core:${rootProject.ext["serialization_version"]}")
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:${rootProject.ext["serialization_version"]}")
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-protobuf:${rootProject.ext["serialization_version"]}")
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:${rootProject.ext["coroutines_version"]}") {
                    version { strictly("${rootProject.ext["coroutines_version"]}") }
                }
                implementation("org.jetbrains.kotlinx:kotlinx-datetime:${rootProject.ext["datetime_version"]}")
                implementation("com.ionspin.kotlin:bignum:${rootProject.ext["bignum_version"]}")
                implementation("com.russhwolf:multiplatform-settings:${rootProject.ext["settings_version"]}")
                implementation("io.ktor:ktor-client-core:${rootProject.ext["ktor_version"]}")
                implementation("io.ktor:ktor-client-logging:${rootProject.ext["ktor_version"]}")
                implementation("io.ktor:ktor-client-content-negotiation:${rootProject.ext["ktor_version"]}")
                implementation("io.ktor:ktor-serialization-kotlinx-json:${rootProject.ext["ktor_version"]}")
                implementation("io.ktor:ktor-client-auth:${rootProject.ext["ktor_version"]}")
            }
        }
        val commonTest by getting {
            dependencies {
                implementation(kotlin("test"))
            }
        }
        val androidMain by getting {
            dependencies {
                implementation(files("./src/androidMain/libs/CoreCrypto.aar"))
                implementation("io.ktor:ktor-client-okhttp:${rootProject.ext["ktor_version"]}")
            }
        }
        val androidTest by getting
        val iosX64Main by getting
        val iosArm64Main by getting
        val iosSimulatorArm64Main by getting
        val iosMain by creating {
            dependsOn(commonMain)
            iosX64Main.dependsOn(this)
            iosArm64Main.dependsOn(this)
            iosSimulatorArm64Main.dependsOn(this)
            dependencies {
                implementation("io.ktor:ktor-client-darwin:${rootProject.ext["ktor_version"]}")
            }
        }
        val iosX64Test by getting {

        }
        val iosArm64Test by getting {

        }
        val iosSimulatorArm64Test by getting
        val iosTest by creating {
            dependsOn(commonTest)
            iosX64Test.dependsOn(this)
            iosArm64Test.dependsOn(this)
            iosSimulatorArm64Test.dependsOn(this)
        }
    }
}


buildkonfig {
    packageName = "com.sonsofcrypto.web3lib"
    defaultConfigs {
        val properties = Properties().apply {
            load(rootProject.file("local.properties").reader())
        }
        buildConfigField(Type.STRING, "poktPortalId", properties["com.sonsofcrypto.pokt.portalId"] as String)
        buildConfigField(Type.STRING, "poktSecretKey", properties["com.sonsofcrypto.pokt.secretKey"] as String)
        buildConfigField(Type.STRING, "poktPublicKey", properties["com.sonsofcrypto.pokt.publicKey"] as String)
        buildConfigField(Type.STRING, "alchemyKey", properties["com.sonsofcrypto.alchemyKey"] as String)
        buildConfigField(Type.STRING, "etherscanKey", properties["com.sonsofcrypto.etherscanKey"] as String)
    }
}

android {
    compileSdk = 32
    sourceSets["main"].manifest.srcFile("src/androidMain/AndroidManifest.xml")
    defaultConfig {
        minSdk = 29
        targetSdk = 32
    }
    namespace = "com.sonsofcrypto.web3lib"
}

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-core:${rootProject.ext["serialization_version"]}")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:${rootProject.ext["serialization_version"]}")
    implementation("com.russhwolf:multiplatform-settings:${rootProject.ext["settings_version"]}")

}