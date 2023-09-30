package com.sonsofcrypto.web3walletcore.modules.settings

sealed class SettingsWireframeDestination() {
    data class Settings(val id: SettingsScreenId): SettingsWireframeDestination()
    data class Website(val url: String): SettingsWireframeDestination()
    object Improvements: SettingsWireframeDestination()
    object Mail: SettingsWireframeDestination()
    object KeyStore: SettingsWireframeDestination()
}

interface SettingsWireframe {
    fun present()
    fun navigate(destination: SettingsWireframeDestination)
}