val compileSdkVersion by extra(33)
buildscript {
    val kotlinVersion = "1.8.20"
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        classpath("com.android.tools.build:gradle:8.0.2")
        classpath("org.jetbrains.kotlin:kotlin-serialization:$kotlinVersion")
        classpath("com.codingfeline.buildkonfig:buildkonfig-gradle-plugin:0.13.3")
    }
}

allprojects {
    ext["settings_version"] = "1.0.0"
    ext["serialization_version"] = "1.5.0"
    ext["coroutines_version"] = "1.6.3-native-mt"
    ext["ktor_version"] = "2.2.4"
    ext["bignum_version"] = "0.3.8"
    ext["datetime_version"] = "0.4.0"
    ext["kotlin_version"] = "1.8.20"

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
////    println("All props")
////    System.getProperties().keys.forEach{ println("$it ${System.getProperty(it as? String ?: "")}") }
////    println("All env")
////    System.getenv().keys.forEach{ println("$it ${System.getenv()[it]}") }
//}
