buildscript {
    val kotlinVersion = "1.7.10"
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.0")
        classpath("com.android.tools.build:gradle:7.2.1")
        classpath("org.jetbrains.kotlin:kotlin-serialization:$kotlinVersion")
    }
}

allprojects {

    ext["settings_version"] = "1.0.0-alpha01"
    ext["serialization_version"] = "1.3.3"
    ext["coroutines_version"] = "1.6.0-native-mt"
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
