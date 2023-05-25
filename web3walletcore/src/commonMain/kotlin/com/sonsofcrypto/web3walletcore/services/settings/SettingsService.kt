package com.sonsofcrypto.web3walletcore.services.settings

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3walletcore.services.settings.Setting.Action.DEVELOPER_APIS_NFTS_OPEN_SEA
import com.sonsofcrypto.web3walletcore.services.settings.Setting.Action.DEVELOPER_TRANSITIONS_CARD_FLIP
import com.sonsofcrypto.web3walletcore.services.settings.Setting.Action.THEME_MIAMI_LIGHT
import com.sonsofcrypto.web3walletcore.services.settings.Setting.Group.DEVELOPER_APIS_NFTS
import com.sonsofcrypto.web3walletcore.services.settings.Setting.Group.DEVELOPER_TRANSITIONS
import com.sonsofcrypto.web3walletcore.services.settings.Setting.Group.THEME

data class Setting(
    val group: Group,
    val action: Action?,
) {
    enum class Group {
        /** THEME */
        THEME,
        /** IMPROVEMENT */
        IMPROVEMENT,
        /** DEVELOPER */
        DEVELOPER,
        DEVELOPER_APIS,
        DEVELOPER_APIS_NFTS,
        DEVELOPER_TRANSITIONS,
        /** ABOUT */
        ABOUT,
        /** FEEDBACK */
        FEEDBACK,
    }

    enum class Action {
        /** THEME */
        THEME_MIAMI_LIGHT,
        THEME_MIAMI_DARK,
        THEME_IOS_LIGHT,
        THEME_IOS_DARK,
        /** IMPROVEMENT */
        IMPROVEMENT_PROPOSALS,
        /** DEVELOPER_APIS_NFTS */
        DEVELOPER_APIS_NFTS_OPEN_SEA,
        /** DEVELOPER_TRANSITIONS */
        DEVELOPER_TRANSITIONS_CARD_FLIP,
        DEVELOPER_TRANSITIONS_SHEET,
        /** DEVELOPER */
        DEVELOPER_RESET_KEYSTORE,
        /** ABOUT */
        ABOUT_WEBSITE,
        ABOUT_GIT_HUB,
        ABOUT_TWITTER,
        ABOUT_TELEGRAM,
        ABOUT_DISCORD,
        ABOUT_MEDIUM,
        ABOUT_MAIL,
        /** FEEDBACK */
        FEEDBACK_REPORT,
    }
}

interface SettingsService {
    fun select(setting: Setting)
    fun isSelected(setting: Setting): Boolean
}

class DefaultSettingsService(
    private val store: KeyValueStore,
): SettingsService {

    init {
        if (!isInitialized(THEME)) {
            select(Setting(THEME, THEME_MIAMI_LIGHT))
        }
        if (!isInitialized(DEVELOPER_APIS_NFTS)) {
            select(Setting(DEVELOPER_APIS_NFTS, DEVELOPER_APIS_NFTS_OPEN_SEA))
        }
        if (!isInitialized(DEVELOPER_TRANSITIONS)) {
            select(Setting(DEVELOPER_TRANSITIONS, DEVELOPER_TRANSITIONS_CARD_FLIP))
        }
    }

    override fun select(setting: Setting) {
        val action = setting.action ?: return
        store[setting.group.toString()] = action.toString()
    }

    override fun isSelected(setting: Setting): Boolean {
        val action = setting.action ?: return false
        return action.toString() == store.get<String>(setting.group.toString())
    }

    private fun isInitialized(group: Setting.Group): Boolean =
        null != store.get<String>(group.toString())
}