package com.sonsofcrypto.web3walletcore.services.settings

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3walletcore.common.ThemeId
import com.sonsofcrypto.web3walletcore.common.ThemeVariant

interface SettingsService {
    var themeId: ThemeId
    var themeVariant: ThemeVariant
}

class DefaultSettingsService(
    private val store: KeyValueStore
): SettingsService {
    override var themeId: ThemeId
        get() = ThemeId.values().firstOrNull {
            it.raw == (store.get<String>("themeId") ?: "")
        } ?: ThemeId.MIAMI
        set(id) = store.set("themeId", id.raw)
    override var themeVariant: ThemeVariant
        get() = ThemeVariant.values().firstOrNull {
            it.raw == (store.get<String>("themeVariant") ?: "")
        } ?: ThemeVariant.LIGHT
        set(mode) = store.set("themeVariant", mode.raw)
}

