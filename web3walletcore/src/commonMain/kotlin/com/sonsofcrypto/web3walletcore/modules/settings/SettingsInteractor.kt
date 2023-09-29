package com.sonsofcrypto.web3walletcore.modules.settings

import com.sonsofcrypto.web3walletcore.services.settings.SettingsService

interface SettingsInteractor {
    var themeId: String?
    var themeMode: String?
}

class DefaultSettingsInteractor(
    private val settingsService: SettingsService
): SettingsInteractor {

    override var themeId: String?
        get() = settingsService.themeId
        set(id) { settingsService.themeId = id }

    override var themeMode: String?
        get() = settingsService.themeMode
        set(mode) { settingsService.themeMode = mode }
}
