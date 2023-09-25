package com.sonsofcrypto.web3walletcore.services.settings

interface SettingsServiceActionTrigger {
    fun trigger(action: SettingLegacy.Action)
}