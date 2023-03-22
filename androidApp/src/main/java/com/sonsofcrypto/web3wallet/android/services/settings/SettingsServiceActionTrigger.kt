package com.sonsofcrypto.web3wallet.android.services.settings

import com.sonsofcrypto.web3wallet.android.BuildConfig
import com.sonsofcrypto.web3wallet.android.BuildConfig.VERSION_NAME
import com.sonsofcrypto.web3wallet.android.assembler
import com.sonsofcrypto.web3wallet.android.common.AppTheme
import com.sonsofcrypto.web3wallet.android.common.themeMiamiSunriseDark
import com.sonsofcrypto.web3wallet.android.common.themeMiamiSunriseLight
import com.sonsofcrypto.web3wallet.android.modules.compose.improvementproposals.ImprovementProposalsWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.improvementproposals.ImprovementProposalsWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.networks.NetworksWireframeFactory
import com.sonsofcrypto.web3walletcore.app.App
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.services.settings.Setting
import com.sonsofcrypto.web3walletcore.services.settings.SettingsServiceActionTrigger
import smartadapter.internal.extension.name

class DefaultSettingsServiceActionTrigger: SettingsServiceActionTrigger {

    override fun trigger(action: Setting.Action) {
        when (action) {
            Setting.Action.THEME_MIAMI_LIGHT -> { AppTheme.value = themeMiamiSunriseLight }
            Setting.Action.THEME_MIAMI_DARK -> { AppTheme.value = themeMiamiSunriseDark }
            Setting.Action.THEME_IOS_LIGHT -> {}
            Setting.Action.THEME_IOS_DARK -> {}
            Setting.Action.IMPROVEMENT_PROPOSALS -> {
//                val factory: ImprovementProposalsWireframeFactory = assembler.resolve(
//                    ImprovementProposalsWireframeFactory::class.name
//                )
//                factory.make(App.activity.supportFragmentManager).present()
            }
            Setting.Action.DEVELOPER_APIS_NFTS_OPEN_SEA -> {}
            Setting.Action.DEVELOPER_TRANSITIONS_CARD_FLIP -> {}
            Setting.Action.DEVELOPER_TRANSITIONS_SHEET -> {}
            Setting.Action.DEVELOPER_RESET_KEYSTORE -> {}
            Setting.Action.ABOUT_WEBSITE -> {
                App.openUrl("https://www.sonsofcrypto.com")
            }
            Setting.Action.ABOUT_GIT_HUB -> {
                App.openUrl("https://github.com/sonsofcrypto")
            }
            Setting.Action.ABOUT_TWITTER -> {
                App.openUrl("https://twitter.com/sonsofcryptolab")
            }
            Setting.Action.ABOUT_TELEGRAM -> {
                App.openUrl("https://t.me/+osHUInXKmwMyZjQ0")
            }
            Setting.Action.ABOUT_DISCORD -> {
                App.openUrl("https://discord.gg/DW8kUu6Q6E")
            }
            Setting.Action.ABOUT_MEDIUM -> {
                App.openUrl("https://medium.com/@sonsofcrypto")
            }
            Setting.Action.ABOUT_MAIL -> {
                App.openUrl("mailto:sonsofcrypto@protonmail.com")
            }
            Setting.Action.FEEDBACK_REPORT -> {
                val subject = Localized("settings.feedback.subject.beta", VERSION_NAME)
                println("[AA] subject -> $subject")
                App.openUrl("mailto:sonsofcrypto@protonmail.com?subject=$subject")
            }
        }
    }
}

