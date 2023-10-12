// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

class DefaultSettingsWireframe {
    private weak var parent: UIViewController?
    private let screenId: SettingsScreenId
    private let webViewWireframeFactory: WebViewWireframeFactory
    private let improvementProposalsWireframeFactory: ImprovementProposalsWireframeFactory
    private let mailWireframeFactory: MailService
    private let settingsService: SettingsService
    private let signerStoreService: SignerStoreService

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        screenId: SettingsScreenId,
        webViewWireframeFactory: WebViewWireframeFactory,
        improvementProposalsWireframeFactory: ImprovementProposalsWireframeFactory,
        mailWireframeFactory: MailService,
        settingsService: SettingsService,
        signerStoreService: SignerStoreService
    ) {
        self.parent = parent
        self.screenId = screenId
        self.webViewWireframeFactory = webViewWireframeFactory
        self.improvementProposalsWireframeFactory = improvementProposalsWireframeFactory
        self.mailWireframeFactory = mailWireframeFactory
        self.settingsService = settingsService
        self.signerStoreService = signerStoreService
    }
}

// MARK: - TemplateWireframe

extension DefaultSettingsWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc

        if let tabVc = parent as? UITabBarController {
            let nc = NavigationController(rootViewController: vc)
            nc.tabBarItem = UITabBarItem(
                title: Localized("settings"),
                image: "tab_icon_settings".assetImage,
                tag: 3
            )
            let vcs = (tabVc.viewControllers ?? []) + [nc]
            tabVc.setViewControllers(vcs, animated: false)
        } else {
            parent?.show(vc, sender: self)
        }
    }

    func navigate(to destination: SettingsWireframeDestination) {
        if destination is SettingsWireframeDestination.Mail {
            mailWireframeFactory.sendMail(context: .init(subject: .beta))
        }
        if destination is SettingsWireframeDestination.Improvements {
            improvementProposalsWireframeFactory.make(vc).present()
        }
        if let website = destination as? SettingsWireframeDestination.Website {
            let url = URL(string: website.url)!
            webViewWireframeFactory.make(vc, context: .init(url: url)).present()
        }
        if destination is SettingsWireframeDestination.KeyStore {
            vc?.navigationController?.popToRootViewController(animated: true)
            vc?.tabBarController?.selectedIndex = 0
            vc?.tabBarController?.edgeCardsController?.setDisplayMode(
                .bottomCard,
                animated: true
            )
        }
        if let settings = destination as? SettingsWireframeDestination.Settings {
            DefaultSettingsWireframe(
                vc,
                screenId: settings.id,
                webViewWireframeFactory: webViewWireframeFactory,
                improvementProposalsWireframeFactory: improvementProposalsWireframeFactory,
                mailWireframeFactory: mailWireframeFactory,
                settingsService: settingsService,
                signerStoreService: signerStoreService
            ).present()
        }
    }
}

extension DefaultSettingsWireframe {

    private func wireUp() -> UIViewController {
        let vc: SettingsViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultSettingsPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: DefaultSettingsInteractor(
                settingsService: settingsService,
                signerStoreService: signerStoreService
            ),
            screenId: screenId
        )
        vc.presenter = presenter
        return vc
    }
}
