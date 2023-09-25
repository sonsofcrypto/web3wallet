package com.sonsofcrypto.web3walletcore.modules.settingsLegacy

import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.services.settings.SettingLegacy

sealed class SettingsLegacyWireframeDestination {
    object Dismiss: SettingsLegacyWireframeDestination()
    data class SettingsLegacy(val context: SettingsLegacyWireframeContext): SettingsLegacyWireframeDestination()
}

interface SettingsLegacyWireframe {
    fun present()
    fun navigate(destination: SettingsLegacyWireframeDestination)
}

data class SettingsLegacyWireframeContext(
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
            val settingLegacy: SettingLegacy,
        )
        data class Footer(
            val text: String,
            val alignment: Alignment,
        ) {
            enum class Alignment { LEFT, CENTER }
        }
    }

    companion object Factory {
        fun create(settingLegacy: SettingLegacy?): SettingsLegacyWireframeContext = when (settingLegacy?.group) {
            SettingLegacy.Group.THEME -> themeContext
            SettingLegacy.Group.IMPROVEMENT -> emptyContext
            SettingLegacy.Group.DEVELOPER -> developerContext
            SettingLegacy.Group.DEVELOPER_APIS -> developerAPIsContext
            SettingLegacy.Group.DEVELOPER_APIS_NFTS -> developerAPIsNFTsContext
            SettingLegacy.Group.DEVELOPER_TRANSITIONS -> developerTransitionsContext
            SettingLegacy.Group.ABOUT -> aboutContext
            SettingLegacy.Group.FEEDBACK -> emptyContext
            null -> rootContext
        }

        private val emptyContext: SettingsLegacyWireframeContext get() = SettingsLegacyWireframeContext(
            "", emptyList()
        )

        private val rootContext: SettingsLegacyWireframeContext get() = SettingsLegacyWireframeContext(
            Localized("settings"),
            listOf(
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.themes"),
                            SettingLegacy(SettingLegacy.Group.THEME, null)
                        ),
                        Group.Item(
                            Localized("settings.improvement"),
                            SettingLegacy(SettingLegacy.Group.IMPROVEMENT, SettingLegacy.Action.IMPROVEMENT_PROPOSALS)
                        ),
                        Group.Item(
                            Localized("settings.developer"),
                            SettingLegacy(SettingLegacy.Group.DEVELOPER, null)
                        ),
                    ),
                    null,
                ),
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.about"),
                            SettingLegacy(SettingLegacy.Group.ABOUT, null)
                        ),
                    ),
                    null,
                ),
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.feedback"),
                            SettingLegacy(SettingLegacy.Group.FEEDBACK, SettingLegacy.Action.FEEDBACK_REPORT)
                        ),
                    ),
                    null,
                ),
            ),
        )

        private val themeContext: SettingsLegacyWireframeContext get() = SettingsLegacyWireframeContext(
            Localized("settings.themes"),
            listOf(
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.themes.miami.light"),
                            SettingLegacy(SettingLegacy.Group.THEME, SettingLegacy.Action.THEME_MIAMI_LIGHT)
                        ),
                        Group.Item(
                            Localized("settings.themes.miami.dark"),
                            SettingLegacy(SettingLegacy.Group.THEME, SettingLegacy.Action.THEME_MIAMI_DARK)
                        ),
                        Group.Item(
                            Localized("settings.themes.ios.light"),
                            SettingLegacy(SettingLegacy.Group.THEME, SettingLegacy.Action.THEME_IOS_LIGHT)
                        ),
                        Group.Item(
                            Localized("settings.themes.ios.dark"),
                            SettingLegacy(SettingLegacy.Group.THEME, SettingLegacy.Action.THEME_IOS_DARK)
                        ),
                    ),
                    null,
                ),
            ),
        )

        private val developerContext: SettingsLegacyWireframeContext get() = SettingsLegacyWireframeContext(
            Localized("settings.developer"),
            listOf(
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.developer.apis"),
                            SettingLegacy(SettingLegacy.Group.DEVELOPER_APIS, null)
                        ),
                        Group.Item(
                            Localized("settings.developer.transitions"),
                            SettingLegacy(SettingLegacy.Group.DEVELOPER_TRANSITIONS, null)
                        ),
                        Group.Item(
                            Localized("settings.developer.resetKeyStore"),
                            SettingLegacy(
                                SettingLegacy.Group.DEVELOPER,
                                SettingLegacy.Action.DEVELOPER_RESET_KEYSTORE
                            )
                        ),
                    ),
                    null,
                ),
            ),
        )

        private val developerAPIsContext: SettingsLegacyWireframeContext get() = SettingsLegacyWireframeContext(
            Localized("settings.developer.apis"),
            listOf(
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.developer.apis.nfts"),
                            SettingLegacy(SettingLegacy.Group.DEVELOPER_APIS_NFTS, null)
                        ),
                    ),
                    null,
                ),
            ),
        )

        private val developerAPIsNFTsContext: SettingsLegacyWireframeContext get() = SettingsLegacyWireframeContext(
            Localized("settings.developer.apis.nfts"),
            listOf(
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.developer.apis.nfts.openSea"),
                            SettingLegacy(
                                SettingLegacy.Group.DEVELOPER_APIS_NFTS,
                                SettingLegacy.Action.DEVELOPER_APIS_NFTS_OPEN_SEA
                            )
                        ),
                    ),
                    null,
                ),
            ),
        )

        private val developerTransitionsContext: SettingsLegacyWireframeContext get() = SettingsLegacyWireframeContext(
            Localized("settings.developer.transitions"),
            listOf(
                Group(
                    null,
                    listOf(
                        Group.Item(
                            Localized("settings.developer.transitions.cardFlip"),
                            SettingLegacy(
                                SettingLegacy.Group.DEVELOPER_TRANSITIONS,
                                SettingLegacy.Action.DEVELOPER_TRANSITIONS_CARD_FLIP
                            )
                        ),
                        Group.Item(
                            Localized("settings.developer.transitions.sheet"),
                            SettingLegacy(
                                SettingLegacy.Group.DEVELOPER_TRANSITIONS,
                                SettingLegacy.Action.DEVELOPER_TRANSITIONS_SHEET
                            )
                        ),
                    ),
                    null,
                ),
            ),
        )

        private val aboutContext: SettingsLegacyWireframeContext get() = SettingsLegacyWireframeContext(
            Localized("settings.about"),
            listOf(
                Group(
                    Localized("settings.about.socials"),
                    listOf(
                        Group.Item(
                            Localized("settings.about.socials.website"),
                            SettingLegacy(SettingLegacy.Group.ABOUT, SettingLegacy.Action.ABOUT_WEBSITE),
                        ),
                        Group.Item(
                            Localized("settings.about.socials.github"),
                            SettingLegacy(SettingLegacy.Group.ABOUT, SettingLegacy.Action.ABOUT_GIT_HUB),
                        ),
                        Group.Item(
                            Localized("settings.about.socials.twitter"),
                            SettingLegacy(SettingLegacy.Group.ABOUT, SettingLegacy.Action.ABOUT_TWITTER),
                        ),
                        Group.Item(
                            Localized("settings.about.socials.telegram"),
                            SettingLegacy(SettingLegacy.Group.ABOUT, SettingLegacy.Action.ABOUT_TELEGRAM),
                        ),
                        Group.Item(
                            Localized("settings.about.socials.discord"),
                            SettingLegacy(SettingLegacy.Group.ABOUT, SettingLegacy.Action.ABOUT_DISCORD),
                        ),
                        Group.Item(
                            Localized("settings.about.socials.medium"),
                            SettingLegacy(SettingLegacy.Group.ABOUT, SettingLegacy.Action.ABOUT_MEDIUM),
                        ),
                    ),
                    null,
                ),
                Group(
                    Localized("settings.about.contactUs"),
                    listOf(
                        Group.Item(
                            Localized("settings.about.contactUs.mail"),
                            SettingLegacy(SettingLegacy.Group.ABOUT, SettingLegacy.Action.ABOUT_MAIL)
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

