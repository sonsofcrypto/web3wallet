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
include(":web3lib_utils")
include(":web3lib_core")
include(":web3lib_keyValueStore")
include(":web3lib_keyStore")
include(":web3lib_provider")
