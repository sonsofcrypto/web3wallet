val compileSdkVersion by extra(33)
buildscript {
    val kotlinVersion = "1.9.21"
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        classpath("com.android.tools.build:gradle:8.1.1")
        classpath("org.jetbrains.kotlin:kotlin-serialization:$kotlinVersion")
        classpath("com.codingfeline.buildkonfig:buildkonfig-gradle-plugin:0.13.3")
    }
}

allprojects {
    ext["settings_version"] = "1.0.0"
    ext["serialization_version"] = "1.6.2"
    ext["coroutines_version"] = "1.7.3"
    ext["ktor_version"] = "2.3.7"
    ext["bignum_version"] = "0.3.8"
    ext["datetime_version"] = "0.5.0"
    ext["kotlin_version"] = "1.9.21"

    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
        uri("https://oss.sonatype.org/content/repositories/snapshots")
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}

//task("printProps") {
//    setGroup("help")
//    val props = listOf(
//        "org.gradle.java.home",
//        "org.gradle.jvmargs",
//        "javax.net.ssl.trustStore",
//        "javax.net.ssl.keyStore",
//    )
//    val sysProps = listOf(
//        "file.encoding",
//        "user.country",
//        "user.language",
//        "java.io.tmpdir",
//        "user.variant",
//        "javax.net.ssl.trustStore",
//        "javax.net.ssl.keyStore",
//    )
//    println("JAVA_HOME=${System.getenv("JAVA_HOME")}")
//    props.forEach { println("$it=${ project.findProperty(it)}") }
//    sysProps.forEach { println("$it=${ System.getProperty(it) }") }
//    println("All props")
//    System.getProperties().keys.forEach{ println("$it ${System.getProperty(it as? String ?: "")}") }
//    println("All env")
//    System.getenv().keys.forEach{ println("$it ${System.getenv()[it]}") }
//}

tasks.register("updateResources") {
    val bundledAssets = rootProject.projectDir.path + "/bundledAssets"
    val web3libRes = rootProject.project("web3lib").projectDir.path + "/src/androidMain/res/raw"
    val web3walletCore = rootProject.project("web3walletcore").projectDir.path + "/src/androidMain/res/raw"
    val iosRes = rootProject.projectDir.path + "/iosApp/iosApp/Resources/bundledAssets"
    val androidRes = rootProject.projectDir.path + "/androidApp/src/main/assets"

    listOf("/contracts", "/currencies_meta", "/docs").forEach {
        delete(web3libRes + it)
        delete(web3walletCore + it)
        delete(iosRes + it)
        delete(androidRes + it)
        copy { from(bundledAssets + it); into(web3libRes + it) }
        copy { from(bundledAssets + it); into(web3walletCore + it) }
        copy { from(bundledAssets + it); into(iosRes + it) }
        copy { from(bundledAssets + it); into(androidRes + it) }
    }
}