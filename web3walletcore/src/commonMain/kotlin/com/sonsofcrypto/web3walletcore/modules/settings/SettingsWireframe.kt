package com.sonsofcrypto.web3walletcore.modules.settings

import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.services.settings.Setting

sealed class SettingsWireframeDestination {
    object Dismiss: SettingsWireframeDestination()
    data class Settings(val context: SettingsWireframeContext): SettingsWireframeDestination()
}

interface SettingsWireframe {
    fun present()
    fun navigate(destination: SettingsWireframeDestination)
}

data class SettingsWireframeContext(
    val title: String,
    val groups: List<Group>,
) {
    data class Group(
        val title: String?,
        val items: List<Item>,
        val footer: Footer?
    ) {
        data class Item(
            val name: String,
            val setting: Setting,
        )
        data class Footer(
            val text: String,
            val alignment: Alignment,
        ) {
            enum class Alignment { LEFT, CENTER }
        }
    }

    companion object Factory {
        fun create(setting: Setting?): SettingsWireframeContext = when (setting?.group) {
            Setting.Group.THEME -> themeContext
            Setting.Group.IMPROVEMENT -> emptyContext
            Setting.Group.DEVELOPER -> developerContext
            Setting.Group.DEVELOPER_APIS -> developerAPIsContext
            Setting.Group.DEVELOPER_APIS_NFTS -> developerAPIsNFTsContext
            Setting.Group.DEVELOPER_TRANSITIONS -> developerTransitionsContext
            Setting.Group.ABOUT -> aboutContext
            Setting.Group.FEEDBACK -> emptyContext
            null -> rootContext
        }

        private val emptyContext: SettingsWireframeContext get() = SettingsWireframeContext(
            "", emptyList()
        )

        private val rootContext: SettingsWireframeContext get() = SettingsWireframeContext(
            Localized("settings"),
            listOf(
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.themes"),
                            Setting(Setting.Group.THEME, null)
                        ),
                        Group.Item(
                            Localized("settings.improvement"),
                            Setting(Setting.Group.IMPROVEMENT, Setting.Action.IMPROVEMENT_PROPOSALS)
                        ),
                        Group.Item(
                            Localized("settings.developer"),
                            Setting(Setting.Group.DEVELOPER, null)
                        ),
                    ),
                    null,
                ),
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.about"),
                            Setting(Setting.Group.ABOUT, null)
                        ),
                    ),
                    null,
                ),
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.feedback"),
                            Setting(Setting.Group.FEEDBACK, Setting.Action.FEEDBACK_REPORT)
                        ),
                    ),
                    null,
                ),
            ),
        )

        private val themeContext: SettingsWireframeContext get() = SettingsWireframeContext(
            Localized("settings.themes"),
            listOf(
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.themes.miami.light"),
                            Setting(Setting.Group.THEME, Setting.Action.THEME_MIAMI_LIGHT)
                        ),
                        Group.Item(
                            Localized("settings.themes.miami.dark"),
                            Setting(Setting.Group.THEME, Setting.Action.THEME_MIAMI_DARK)
                        ),
                        Group.Item(
                            Localized("settings.themes.ios.light"),
                            Setting(Setting.Group.THEME, Setting.Action.THEME_IOS_LIGHT)
                        ),
                        Group.Item(
                            Localized("settings.themes.ios.dark"),
                            Setting(Setting.Group.THEME, Setting.Action.THEME_IOS_DARK)
                        ),
                    ),
                    null,
                ),
            ),
        )

        private val developerContext: SettingsWireframeContext get() = SettingsWireframeContext(
            Localized("settings.developer"),
            listOf(
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.developer.apis"),
                            Setting(Setting.Group.DEVELOPER_APIS, null)
                        ),
                        Group.Item(
                            Localized("settings.developer.transitions"),
                            Setting(Setting.Group.DEVELOPER_TRANSITIONS, null)
                        ),
                        Group.Item(
                            Localized("settings.developer.resetKeyStore"),
                            Setting(
                                Setting.Group.DEVELOPER,
                                Setting.Action.DEVELOPER_RESET_KEYSTORE
                            )
                        ),
                    ),
                    null,
                ),
            ),
        )

        private val developerAPIsContext: SettingsWireframeContext get() = SettingsWireframeContext(
            Localized("settings.developer.apis"),
            listOf(
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.developer.apis.nfts"),
                            Setting(Setting.Group.DEVELOPER_APIS_NFTS, null)
                        ),
                    ),
                    null,
                ),
            ),
        )

        private val developerAPIsNFTsContext: SettingsWireframeContext get() = SettingsWireframeContext(
            Localized("settings.developer.apis.nfts"),
            listOf(
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.developer.apis.nfts.openSea"),
                            Setting(
                                Setting.Group.DEVELOPER_APIS_NFTS,
                                Setting.Action.DEVELOPER_APIS_NFTS_OPEN_SEA
                            )
                        ),
                    ),
                    null,
                ),
            ),
        )

        private val developerTransitionsContext: SettingsWireframeContext get() = SettingsWireframeContext(
            Localized("settings.developer.transitions"),
            listOf(
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.developer.transitions.cardFlip"),
                            Setting(
                                Setting.Group.DEVELOPER_TRANSITIONS,
                                Setting.Action.DEVELOPER_TRANSITIONS_CARD_FLIP
                            )
                        ),
                        Group.Item(
                            Localized("settings.developer.transitions.sheet"),
                            Setting(
                                Setting.Group.DEVELOPER_TRANSITIONS,
                                Setting.Action.DEVELOPER_TRANSITIONS_SHEET
                            )
                        ),
                    ),
                    null,
                ),
            ),
        )

        private val aboutContext: SettingsWireframeContext get() = SettingsWireframeContext(
            Localized("settings.about"),
            listOf(
                Group(
                    Localized("settings.about.socials"),
                    listOf(
                        Group.Item(
                            Localized("settings.about.socials.website"),
                            Setting(Setting.Group.ABOUT, Setting.Action.ABOUT_WEBSITE),
                        ),
                        Group.Item(
                            Localized("settings.about.socials.github"),
                            Setting(Setting.Group.ABOUT, Setting.Action.ABOUT_GIT_HUB),
                        ),
                        Group.Item(
                            Localized("settings.about.socials.twitter"),
                            Setting(Setting.Group.ABOUT, Setting.Action.ABOUT_TWITTER),
                        ),
                        Group.Item(
                            Localized("settings.about.socials.telegram"),
                            Setting(Setting.Group.ABOUT, Setting.Action.ABOUT_TELEGRAM),
                        ),
                        Group.Item(
                            Localized("settings.about.socials.discord"),
                            Setting(Setting.Group.ABOUT, Setting.Action.ABOUT_DISCORD),
                        ),
                        Group.Item(
                            Localized("settings.about.socials.medium"),
                            Setting(Setting.Group.ABOUT, Setting.Action.ABOUT_MEDIUM),
                        ),
                    ),
                    null,
                ),
                Group(
                    Localized("settings.about.contactUs"),
                    listOf(
                        Group.Item(
                            Localized("settings.about.contactUs.mail"),
                            Setting(Setting.Group.ABOUT, Setting.Action.ABOUT_MAIL)
                        ),
                    ),
                    Group.Footer(
                        Localized("settings.about.contactUs.footer"),
                        Group.Footer.Alignment.LEFT
                    )
                ),
            ),
        )
    }
}

