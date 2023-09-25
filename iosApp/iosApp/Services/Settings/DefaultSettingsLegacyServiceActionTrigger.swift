// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

final class DefaultSettingsLegacyServiceActionTrigger {
    let keyStoreService: KeyStoreService

    init(keyStoreService: KeyStoreService) {
        self.keyStoreService = keyStoreService
    }
}


extension DefaultSettingsLegacyServiceActionTrigger: SettingsServiceActionTrigger {
    
    func trigger(action: SettingLegacy.Action) {
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
            guard let vc = rootVc() else { return }
            let factory: AlertWireframeFactory = AppAssembler.resolve()
            factory.make(vc, context: resetKeystoreAlertContext()).present()
        case .aboutWebsite:
            UIApplication.shared.open(URL(string: "https://www.sonsofcrypto.com")!)
        case .aboutGitHub:
            UIApplication.shared.open(URL(string: "https://github.com/sonsofcrypto")!)
        case .aboutTwitter:
            UIApplication.shared.open(URL(string: "https://twitter.com/sonsofcryptolab")!)
        case .aboutTelegram:
            UIApplication.shared.open(URL(string: "https://t.me/+osHUInXKmwMyZjQ0")!)
        case .aboutDiscord:
            UIApplication.shared.open(URL(string: "https://discord.gg/DW8kUu6Q6E")!)
        case .aboutMedium:
            UIApplication.shared.open(URL(string: "https://medium.com/@sonsofcrypto")!)
        case .aboutMail:
            UIApplication.shared.open(URL(string: "mailto:sonsofcrypto@protonmail.com")!)
        case .feedbackReport:
            let mailService: MailService = AppAssembler.resolve()
            mailService.sendMail(context: .init(subject: .beta))
        default:
            fatalError("Action not handled")
        }
    }

    private func rootVc() -> UIViewController? {
        UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .compactMap { $0 }
                .first?
                .keyWindow?
                .rootViewController
    }
}

private extension DefaultSettingsLegacyServiceActionTrigger {
    
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
