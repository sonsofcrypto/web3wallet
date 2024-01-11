import com.codingfeline.buildkonfig.compiler.FieldSpec.Type
import org.jetbrains.kotlin.gradle.plugin.mpp.KotlinNativeTarget
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework
import java.util.Properties

plugins {
    kotlin("multiplatform")
    kotlin("plugin.serialization")
    id("com.android.library")
    id("com.codingfeline.buildkonfig")
}

kotlin {
    android()
    val xcf = XCFramework()
    val frameworkPath = project.file("$rootDir/coreCrypto/build/ios").absolutePath
    listOf(
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
                implementation("com.russhwolf:multiplatform-settings-test:${rootProject.ext["settings_version"]}")
                implementation("io.ktor:ktor-client-core:${rootProject.ext["ktor_version"]}")
                implementation("io.ktor:ktor-client-logging:${rootProject.ext["ktor_version"]}")
                implementation("io.ktor:ktor-client-content-negotiation:${rootProject.ext["ktor_version"]}")
                implementation("io.ktor:ktor-serialization-kotlinx-json:${rootProject.ext["ktor_version"]}")
                implementation("io.ktor:ktor-client-auth:${rootProject.ext["ktor_version"]}")
                implementation("com.squareup.okio:okio:3.3.0")

            }
        }
        val commonTest by getting {
            dependencies {
                implementation(kotlin("test"))
                implementation(kotlin("test-annotations-common"))
            }
        }
        val androidMain by getting {
            dependencies {
                implementation(files("$rootDir/coreCrypto/build/android/coreCrypto-sources.jar"))
                implementation(files("$rootDir/coreCrypto/build/android/coreCrypto.aar"))
                implementation("io.ktor:ktor-client-okhttp:${rootProject.ext["ktor_version"]}")
            }
        }
        val androidUnitTest by getting {
            dependencies {
                implementation(files("$rootDir/coreCrypto/build/hostOS/coreCrypto.jar"))
                // Core library
                implementation("androidx.test:core-ktx:1.5.0")
                // AndroidJUnitRunner and JUnit Rules
                implementation("androidx.test:runner:1.5.2")
                implementation("androidx.test:rules:1.5.0")
                // Espresso dependencies
                implementation("androidx.test.espresso:espresso-core:3.5.1")
                implementation("androidx.test.espresso:espresso-contrib:3.5.1")
                implementation("androidx.test.espresso:espresso-intents:3.5.1")
                implementation("androidx.test.espresso:espresso-accessibility:3.5.1")
                implementation("androidx.test.espresso:espresso-web:3.5.1")
                implementation("androidx.test.espresso.idling:idling-concurrent:3.5.1")
                // Espresso dependency can be "implementation", "androidTestImplementation".
                // Whether you want the APK's compile classpath or the test APK classpath.
                implementation("androidx.test.espresso:espresso-idling-resource:3.5.1")
                implementation("junit:junit:4.13.2")
                implementation("org.robolectric:robolectric:4.11.1")
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
            dependencies {
                implementation("io.ktor:ktor-client-darwin:${rootProject.ext["ktor_version"]}")
            }
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

//        tasks.register<Copy>("copyiOSTestResources") {
//            from("../src/res")
//            into("build/bin/iosX64/debugTest/resources")
//            into("build/bin/iosArm64/debugTest/resources")
//            into("build/bin/iosSimulatorArm64/debugTest/resources")
//            into("build/bin/iosX64/releaseTest/res")
//            into("build/bin/iosArm64/releaseTest/res")
//            into("build/bin/iosSimulatorArm64/releaseTest/res")
//        }
//
//        tasks.findByName("iosX64Test")!!.dependsOn("copyiOSTestResources")
//        tasks.findByName("iosArm64Test")!!.dependsOn("copyiOSTestResources")
//        tasks.findByName("iosSimulatorArm64Test")!!.dependsOn("copyiOSTestResources")

    }

//    tasks.withType<Test> {
//        // set system property using a property specified in gradle
//        systemProperty("java.library.path", "/Users/blockexplorer/Development/soc/web3wallet/coreCrypto/build/android/coreCrypto/jni/x86/")
//    }

    val testBinary = kotlin.targets.getByName<KotlinNativeTarget>("iosSimulatorArm64").binaries.getTest("DEBUG")
    val runIosTests by project.tasks.creating(IosSimulatorTestsTask::class) {
        dependsOn(testBinary.linkTask)
        testExecutable.set(testBinary.outputFile)
        simulatorId.set("6F2501E5-656F-41CE-A2B8-0F638E5E7213")
    }
}

buildkonfig {
    packageName = "com.sonsofcrypto.web3lib"
    exposeObjectWithName = "BuildKonfig"
    defaultConfigs {
        val properties = Properties().apply {
            load(rootProject.file("local.properties").reader())
        }
        buildConfigField(Type.STRING, "poktPortalId", properties["com.sonsofcrypto.pokt.portalId"] as String)
        buildConfigField(Type.STRING, "poktSecretKey", properties["com.sonsofcrypto.pokt.secretKey"] as String)
        buildConfigField(Type.STRING, "poktPublicKey", properties["com.sonsofcrypto.pokt.publicKey"] as String)
        buildConfigField(Type.STRING, "alchemyKey", properties["com.sonsofcrypto.alchemyKey"] as String)
        buildConfigField(Type.STRING, "etherscanKey", properties["com.sonsofcrypto.etherscanKey"] as String)
        buildConfigField(Type.STRING, "testMnemonic", properties["com.sonsofcrypto.testMnemonic"] as String)
        buildConfigField(Type.STRING, "testPrvKey", properties["com.sonsofcrypto.testPrvKey"] as String)
        buildConfigField(Type.STRING, "moralisKey", properties["com.sonsofcrypto.moralisKey"] as String)
        buildConfigField(Type.STRING, "sourceSet", "default")
    }
}

android {
    compileSdk = 33
    sourceSets["main"].manifest.srcFile("src/androidMain/AndroidManifest.xml")
    defaultConfig {
        minSdk = 29
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }
    namespace = "com.sonsofcrypto.web3lib"
    buildToolsVersion = "33.0.2"
    testOptions {
        unitTests.isIncludeAndroidResources = true
        unitTests.isReturnDefaultValues = true
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    ndkVersion = "25.2.9519653"
}

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-core:${rootProject.ext["serialization_version"]}")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:${rootProject.ext["serialization_version"]}")
    implementation("com.russhwolf:multiplatform-settings:${rootProject.ext["settings_version"]}")
    implementation(files("$rootDir/coreCrypto/build/android/coreCrypto-sources.jar"))
    implementation(files("$rootDir/coreCrypto/build/android/coreCrypto.aar"))
}
