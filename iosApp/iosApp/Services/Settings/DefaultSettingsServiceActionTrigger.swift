// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

final class DefaultSettingsServiceActionTrigger {
    let keyStoreService: KeyStoreService

    init(keyStoreService: KeyStoreService) {
        self.keyStoreService = keyStoreService
    }
}

extension DefaultSettingsServiceActionTrigger: SettingsServiceActionTrigger {
    
    func trigger(action: Setting.Action) {
        switch action {
        case .themeMiamiLight:
            AppDelegate.setUserInterfaceStyle(.light)
            Theme = ThemeMiamiSunrise()
        case .themeMiamiDark:
            AppDelegate.setUserInterfaceStyle(.dark)
            Theme = ThemeMiamiSunrise()
        case .themeIosLight:
            AppDelegate.setUserInterfaceStyle(.light)
            Theme = ThemeVanilla()
        case .themeIosDark:
            AppDelegate.setUserInterfaceStyle(.dark)
            Theme = ThemeVanilla()
        case .improvementProposals:
            guard let deepLink = DeepLink(identifier: DeepLink.improvementProposalsList.identifier) else { return }
            let deepLinkHandler: DeepLinkHandler = AppAssembler.resolve()
            deepLinkHandler.handle(deepLink: deepLink)
        case .developerApisNftsOpenSea:
            AppDelegate.rebootApp()
        case .developerTransitionsSheet, .developerTransitionsCardFlip:
            break
        case .developerResetKeystore:
            guard let vc = UIApplication.shared.rootVc else { return }
            let factory: AlertWireframeFactory = AppAssembler.resolve()
            factory.make(vc, context: resetKeystoreAlertContext()).present()
        case .aboutWebsite:
            UIApplication.shared.open("https://www.sonsofcrypto.com".url!)
        case .aboutGitHub:
            UIApplication.shared.open("https://github.com/sonsofcrypto".url!)
        case .aboutTwitter:
            UIApplication.shared.open("https://twitter.com/sonsofcryptolab".url!)
        case .aboutTelegram:
            UIApplication.shared.open("https://t.me/+osHUInXKmwMyZjQ0".url!)
        case .aboutDiscord:
            UIApplication.shared.open("https://discord.gg/DW8kUu6Q6E".url!)
        case .aboutMedium:
            UIApplication.shared.open("https://medium.com/@sonsofcrypto".url!)
        case .aboutMail:
            UIApplication.shared.open("mailto:sonsofcrypto@protonmail.com".url!)
        case .feedbackReport:
            let mailService: MailService = AppAssembler.resolve()
            mailService.sendMail(context: .init(subject: .beta))
        default:
            fatalError("Action not handled")
        }
    }
}

private extension DefaultSettingsServiceActionTrigger {
    
    func resetKeystoreAlertContext() -> AlertWireframeContext {
        AlertWireframeContext(
            title: Localized("alert.resetKeystore.title"),
            media: nil,
            message: Localized("alert.resetKeystore.message"),
            actions: [
                AlertWireframeContext.Action(
                    title: Localized("alert.resetKeystore.action.confirm"),
                    type: .destructive
                ),
                AlertWireframeContext.Action(
                    title: Localized("cancel"),
                    type: .secondary
                )
            ],
            onActionTapped: { [weak self] idx in
                if idx == 0 { self?.resetKeystore() }
            },
            contentHeight: 350
        )
    }
    
    @objc func resetKeystore() {
        keyStoreService.items().forEach { keyStoreService.remove(item: $0) }
        AppDelegate.rebootApp()
    }
}
