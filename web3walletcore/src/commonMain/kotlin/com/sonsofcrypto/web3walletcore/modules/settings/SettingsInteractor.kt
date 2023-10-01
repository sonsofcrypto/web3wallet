package com.sonsofcrypto.web3walletcore.modules.settings

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3walletcore.common.ThemeId
import com.sonsofcrypto.web3walletcore.common.ThemeVariant
import com.sonsofcrypto.web3walletcore.services.settings.NFTCarouselSize
import com.sonsofcrypto.web3walletcore.services.settings.SettingsService

interface SettingsInteractor {
    var themeId: ThemeId
    var themeVariant: ThemeVariant
    var nftCarouselSize: NFTCarouselSize

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

    override var nftCarouselSize: NFTCarouselSize
        get() = settingsService.nftCarouselSize
        set(size) { settingsService.nftCarouselSize = size }

    override fun resetKeyStore() {
        keyStoreService.items().forEach {
            keyStoreService.remove(it)
        }
    }
}
