pluginManagement {
    repositories {
        google()
        gradlePluginPortal()
        mavenCentral()
    }
}

rootProject.name = "web3wallet"
include(":androidApp")
include(":web3lib")
include(":web3lib_bip39")
include(":web3lib_crypto")
include(":web3lib_extensions")
