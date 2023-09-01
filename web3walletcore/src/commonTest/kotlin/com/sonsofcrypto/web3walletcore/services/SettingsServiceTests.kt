package com.sonsofcrypto.web3walletcore.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3walletcore.services.settings.DefaultSettingsService
import com.sonsofcrypto.web3walletcore.services.settings.Setting
import com.sonsofcrypto.web3walletcore.services.settings.Setting.Action.DEVELOPER_TRANSITIONS_CARD_FLIP
import com.sonsofcrypto.web3walletcore.services.settings.Setting.Group.DEVELOPER_TRANSITIONS
import kotlin.test.Test
import kotlin.test.assertTrue

class SettingsServiceTests {

    @Test
    fun testDefaultSettings() {
        val settings = DefaultSettingsService(
            KeyValueStore("SettingsServiceTests")
        )
        val defaultTransition = settings.isSelected(
            Setting(DEVELOPER_TRANSITIONS, DEVELOPER_TRANSITIONS_CARD_FLIP)
        )
        assertTrue(
            defaultTransition,
            "Unexpected default setting for DEVELOPER_TRANSITIONS"
        )
    }
}