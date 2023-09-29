package com.sonsofcrypto.web3walletcore.modules.settings

import com.sonsofcrypto.web3walletcore.extensions.Localized


enum class SettingsWireframeDestination(val value: String) {
    ROOT(Localized("settings")),
    THEMES(Localized("settings.themes")),
    DEVELOPER(Localized("settings.developer")),
}

interface SettingsWireframe {
    fun present()
    fun navigate(destination: SettingsWireframeDestination)
}