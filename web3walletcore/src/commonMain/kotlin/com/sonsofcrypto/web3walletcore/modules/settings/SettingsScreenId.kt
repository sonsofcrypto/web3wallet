package com.sonsofcrypto.web3walletcore.modules.settings

import com.sonsofcrypto.web3walletcore.extensions.Localized

enum class SettingsScreenId(val value: String) {
    ROOT(Localized("settings")),
    THEMES(Localized("settings.themes")),
    UITWEAKS(Localized("settings.uitweaks")),
    DEVELOPER(Localized("settings.developer")),
}