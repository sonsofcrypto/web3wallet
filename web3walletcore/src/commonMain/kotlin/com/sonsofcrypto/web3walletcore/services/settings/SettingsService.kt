package com.sonsofcrypto.web3walletcore.services.settings

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore

interface SettingsService {
    var themeId: String?
    var themeMode: String?
}

class DefaultSettingsService(
    private val store: KeyValueStore
): SettingsService {
    override var themeId: String?
        get() = store.get<String>("themeId")
        set(id) = store.set("themeId", id)
    override var themeMode: String?
        get() = store.get<String>("themeMode")
        set(mode) = store.set("themeMode", mode)
}

