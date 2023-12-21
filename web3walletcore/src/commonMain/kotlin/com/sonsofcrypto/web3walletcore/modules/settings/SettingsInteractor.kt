package com.sonsofcrypto.web3walletcore.modules.settings

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3walletcore.common.ThemeId
import com.sonsofcrypto.web3walletcore.common.ThemeVariant
import com.sonsofcrypto.web3walletcore.services.settings.NFTCarouselSize
import com.sonsofcrypto.web3walletcore.services.settings.SettingsService

interface SettingsInteractor {
    var themeId: ThemeId
    var themeVariant: ThemeVariant
    var nftCarouselSize: NFTCarouselSize
    var expertMode: Boolean
    fun resetKeyStore()
}

class DefaultSettingsInteractor(
    private val settingsService: SettingsService,
    private val signerStoreService: SignerStoreService,
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

    override var expertMode: Boolean
        get() = settingsService.expertMode
        set(value) { settingsService.expertMode = value }

    override fun resetKeyStore() {
        signerStoreService.items().forEach {
            signerStoreService.remove(it)
        }
    }
}
