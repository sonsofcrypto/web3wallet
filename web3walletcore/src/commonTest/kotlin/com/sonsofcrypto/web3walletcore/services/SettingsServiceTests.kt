package com.sonsofcrypto.web3walletcore.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3walletcore.services.settings.DefaultSettingsLegacyService
import com.sonsofcrypto.web3walletcore.services.settings.SettingLegacy
import com.sonsofcrypto.web3walletcore.services.settings.SettingLegacy.Action.DEVELOPER_TRANSITIONS_CARD_FLIP
import com.sonsofcrypto.web3walletcore.services.settings.SettingLegacy.Group.DEVELOPER_TRANSITIONS
import kotlin.test.Test
import kotlin.test.assertTrue

class SettingsServiceTests {

    @Test
    fun testDefaultSettings() {
        val settings = DefaultSettingsLegacyService(
            KeyValueStore("SettingsServiceTests")
        )
        val defaultTransition = settings.isSelected(
            SettingLegacy(DEVELOPER_TRANSITIONS, DEVELOPER_TRANSITIONS_CARD_FLIP)
        )
        assertTrue(
            defaultTransition,
            "Unexpected default setting for DEVELOPER_TRANSITIONS"
        )
    }
}