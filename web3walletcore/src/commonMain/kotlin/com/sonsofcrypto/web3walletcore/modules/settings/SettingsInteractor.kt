package com.sonsofcrypto.web3walletcore.modules.settings

import com.sonsofcrypto.web3walletcore.services.settings.Setting
import com.sonsofcrypto.web3walletcore.services.settings.SettingsService
import com.sonsofcrypto.web3walletcore.services.settings.SettingsServiceActionTrigger

interface SettingsInteractor {
    fun isSelected(setting: Setting): Boolean
    fun select(setting: Setting)
}

class DefaultSettingsInteractor(
    private val settingsService: SettingsService,
    private val settingsServiceActionTrigger: SettingsServiceActionTrigger,
): SettingsInteractor {

    override fun isSelected(setting: Setting): Boolean = settingsService.isSelected(setting)

    override fun select(setting: Setting) {
        settingsService.select(setting)
        val action = setting.action ?: return
        settingsServiceActionTrigger.trigger(action)
    }
}