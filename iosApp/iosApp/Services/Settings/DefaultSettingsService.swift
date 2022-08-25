// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

final class DefaultSettingsService {

    let defaults: UserDefaults
    let keyStoreService: KeyStoreService

    init(
        defaults: UserDefaults,
        keyStoreService: KeyStoreService
    ) {
        
        self.defaults = defaults
        self.keyStoreService = keyStoreService
    }
    
    func isInitialized(
        item: Setting.ItemIdentifier
    ) -> Bool {
        
        defaults.string(forKey: item.rawValue) != nil
    }
    
    func didSelect(
        item: Setting.ItemIdentifier?,
        action: Setting.ActionIdentifier,
        fireAction: Bool
    ) {
        
        if let item = item {
            
            defaults.set(action.rawValue, forKey: item.rawValue)
            defaults.synchronize()
        }
        
        if fireAction {
            
            fire(action: action)
        }
    }
}

extension DefaultSettingsService: SettingsService {
    
    func settings(
        for setting: Setting.ItemIdentifier
    ) -> [SettingsWireframeContext.Group] {
        
        switch setting {
            
        case .theme:
            
            return [
                .init(
                    title: nil,
                    items: [
                        .init(
                            title: Localized("settings.theme.miami.light"),
                            type: .action(
                                item: .theme,
                                action: .themeMiamiLight,
                                showTickOnSelected: true
                            )
                        ),
                        .init(
                            title: Localized("settings.theme.miami.dark"),
                            type: .action(
                                item: .theme,
                                action: .themeMiamiDark,
                                showTickOnSelected: true
                            )
                        ),
                        .init(
                            title: Localized("settings.theme.ios.light"),
                            type: .action(
                                item: .theme,
                                action: .themeIOSLight,
                                showTickOnSelected: true
                            )
                        ),
                        .init(
                            title: Localized("settings.theme.ios.dark"),
                            type: .action(
                                item: .theme,
                                action: .themeIOSDark,
                                showTickOnSelected: true
                            )
                        )
                    ],
                    footer: nil
                )
            ]
            
        case .improvement:
            
            return []
            
        case .debug:
            
            return [
                .init(
                    title: nil,
                    items: [
                        .init(
                            title: Localized("settings.debug.apis"),
                            type: .item(.debugAPIs)
                        ),
                        .init(
                            title: Localized("settings.debug.resetKeyStore"),
                            type: .action(
                                item: .debug,
                                action: .resetKeystore,
                                showTickOnSelected: false
                            )
                        )
                    ],
                    footer: nil
                )
            ]

        case .debugAPIs:
            
            return [
                .init(
                    title: nil,
                    items: [
                        .init(
                            title: Localized("settings.debug.apis.nfts"),
                            type: .item(.debugAPIsNFTs)
                        )
                    ],
                    footer: nil
                )
            ]
            
        case .debugAPIsNFTs:
            
            return [
                .init(
                    title: nil,
                    items: [
                        .init(
                            title: Localized("settings.debug.apis.nfts.openSea"),
                            type: .action(
                                item: .debugAPIsNFTs,
                                action: .debugAPIsNFTsOpenSea,
                                showTickOnSelected: true
                            )
                        )
                    ],
                    footer: nil
                )
            ]
            
        case .about:
            
            return [
                .init(
                    title: Localized("settings.about.socials"),
                    items: [
                        .init(
                            title: Localized("settings.about.website"),
                            type: .action(
                                item: .about,
                                action: .aboutWebsite,
                                showTickOnSelected: false
                            )
                        ),
                        .init(
                            title: Localized("settings.about.github"),
                            type: .action(
                                item: .about,
                                action: .aboutGitHub,
                                showTickOnSelected: false
                            )
                        ),
                        .init(
                            title: Localized("settings.about.medium"),
                            type: .action(
                                item: .about,
                                action: .aboutMedium,
                                showTickOnSelected: false
                            )
                        ),
                        .init(
                            title: Localized("settings.about.telegram"),
                            type: .action(
                                item: .about,
                                action: .aboutTelegram,
                                showTickOnSelected: false
                            )
                        ),
                        .init(
                            title: Localized("settings.about.twitter"),
                            type: .action(
                                item: .about,
                                action: .aboutTwitter,
                                showTickOnSelected: false
                            )
                        ),
                        .init(
                            title: Localized("settings.about.discord"),
                            type: .action(
                                item: .about,
                                action: .aboutDiscord,
                                showTickOnSelected: false
                            )
                        )
                    ],
                    footer: nil
                ),
                .init(
                    title: Localized("settings.about.contactUs"),
                    items: [
                        .init(
                            title: Localized("settings.about.mail"),
                            type: .action(
                                item: .about,
                                action: .aboutMail,
                                showTickOnSelected: false
                            )
                        )
                    ],
                    footer: .init(
                        text: Localized("settings.about.fotter"),
                        textAlignment: .leading
                    )
                )
            ]
        }
    }
    
    func didSelect(
        item: Setting.ItemIdentifier?,
        action: Setting.ActionIdentifier
    ) {
        
        didSelect(item: item, action: action, fireAction: true)
    }
    
    func isSelected(
        item: Setting.ItemIdentifier,
        action: Setting.ActionIdentifier
    ) -> Bool {
        
        defaults.string(forKey: item.rawValue) == action.rawValue
    }
}

private extension DefaultSettingsService {
    
    func fire(
        action: Setting.ActionIdentifier
    ) {
        
        switch action {
            
        case .debugAPIsNFTsOpenSea:
            ServiceDirectory.rebootApp()
            
        case .themeIOSLight, .themeIOSDark, .themeMiamiLight, .themeMiamiDark:
            Theme = appTheme
            
        case .improvementProposals:
            guard let deepLink = DeepLink(identifier: DeepLink.featuresList.identifier) else { return }
            let deepLinkHandler: DeepLinkHandler = ServiceDirectory.assembler.resolve()
            deepLinkHandler.handle(deepLink: deepLink)
            
        case .resetKeystore:
            guard let presentingVC = SceneDelegateHelper().rootVC else { return }
            let factory: AlertWireframeFactory = ServiceDirectory.assembler.resolve()
            factory.makeWireframe(
                presentingVC,
                context: makeResetKeystoreAlertContext()
            ).present()
            
        case .aboutWebsite:
            UIApplication.shared.open(
                "https://www.sonsofcrypto.com".url!
            )
            
        case .aboutGitHub:
            UIApplication.shared.open(
                "https://github.com/sonsofcrypto".url!
            )

        case .aboutMedium:
            UIApplication.shared.open(
                "https://medium.com/@sonsofcrypto".url!
            )
            
        case .aboutTwitter:
            UIApplication.shared.open(
                "https://twitter.com/sonsofcryptolab".url!
            )

        case .aboutDiscord:
            UIApplication.shared.open(
                "https://discord.gg/DW8kUu6Q6E".url!
            )

        case .aboutTelegram:
            UIApplication.shared.open(
                "https://t.me/+osHUInXKmwMyZjQ0".url!
            )
            
        case .aboutMail:
            UIApplication.shared.open(
                "mailto:sonsofcrypto@protonmail.com".url!
            )
        }
    }
    
    func makeResetKeystoreAlertContext() -> AlertContext {
        
        .init(
            title: Localized("alert.resetKeystore.title"),
            media: nil,
            message: Localized("alert.resetKeystore.message"),
            actions: [
                .init(
                    title: Localized("alert.resetKeystore.action.confirm"),
                    type: .destructive,
                    action: .targetAction(.init(target: self, selector: #selector(resetKeystore)))
                ),
                .init(
                    title: Localized("alert.resetKeystore.action.cancel"),
                    type: .secondary,
                    action: nil
                )
            ],
            contentHeight: 350
        )
    }
    
    @objc func resetKeystore() {
        
        keyStoreService.items().forEach {
            keyStoreService.remove(item: $0)
        }
        ServiceDirectory.rebootApp()
    }
}
