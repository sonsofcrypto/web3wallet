pluginManagement {
    repositories {
        google()
        gradlePluginPortal()
        mavenCentral()
    }
}

rootProject.name = "web3wallet"
include(":androidApp")
include(":corecrypto")
include(":web3lib")
include(":web3walletcore")
