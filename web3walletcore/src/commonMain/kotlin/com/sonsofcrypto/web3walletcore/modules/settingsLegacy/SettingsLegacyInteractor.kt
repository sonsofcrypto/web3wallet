package com.sonsofcrypto.web3walletcore.modules.settingsLegacy

import com.sonsofcrypto.web3walletcore.services.settings.SettingLegacy
import com.sonsofcrypto.web3walletcore.services.settings.SettingsLegacyService
import com.sonsofcrypto.web3walletcore.services.settings.SettingsServiceActionTrigger

interface SettingsLegacyInteractor {
    fun isSelected(settingLegacy: SettingLegacy): Boolean
    fun select(settingLegacy: SettingLegacy)
}

class DefaultSettingsLegacyInteractor(
    private val settingsLegacyService: SettingsLegacyService,
    private val settingsServiceActionTrigger: SettingsServiceActionTrigger,
): SettingsLegacyInteractor {

    override fun isSelected(settingLegacy: SettingLegacy): Boolean = settingsLegacyService.isSelected(settingLegacy)

    override fun select(settingLegacy: SettingLegacy) {
        settingsLegacyService.select(settingLegacy)
        val action = settingLegacy.action ?: return
        settingsServiceActionTrigger.trigger(action)
    }
}