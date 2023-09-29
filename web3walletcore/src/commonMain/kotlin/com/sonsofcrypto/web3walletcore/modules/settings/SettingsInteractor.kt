package com.sonsofcrypto.web3walletcore.modules.settings

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3walletcore.common.ThemeId
import com.sonsofcrypto.web3walletcore.common.ThemeVariant
import com.sonsofcrypto.web3walletcore.services.settings.SettingsService

interface SettingsInteractor {
    var themeId: ThemeId
    var themeVariant: ThemeVariant

    fun selectedThemeIdx(): Int
    fun resetKeyStore()
}

class DefaultSettingsInteractor(
    private val settingsService: SettingsService,
    private val keyStoreService: KeyStoreService,
): SettingsInteractor {

    override var themeId: ThemeId
        get() = settingsService.themeId
        set(id) { settingsService.themeId = id }

    override var themeVariant: ThemeVariant
        get() = settingsService.themeVariant
        set(variant) { settingsService.themeVariant = variant }

    override fun selectedThemeIdx(): Int {
        var idx = if (themeId == ThemeId.MIAMI) 0 else 2
        idx += if (themeVariant == ThemeVariant.DARK) 1 else 0
        return idx
    }

    override fun resetKeyStore() {
        keyStoreService.items().forEach {
            keyStoreService.remove(it)
        }
    }
}
