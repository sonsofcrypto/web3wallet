// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

enum KeyStoreWireframeDestination {

    typealias KeyStoreItemHandler = (KeyStoreItem)->Void

    case networks
    case dashBoard
    case dashBoardOnboarding
    case keyStoreItem(item: KeyStoreItem, handler: KeyStoreItemHandler)
    case newMnemonic(handler: KeyStoreItemHandler)
    case importMnemonic(handler: KeyStoreItemHandler)
    case connectHardwareWaller
    case importPrivateKey
    case createMultisig
}

protocol KeyStoreWireframe {
    func present()
    func navigate(to destination: KeyStoreWireframeDestination)
}

// MARK: - DefaultKeyStoreWireframe

final class DefaultKeyStoreWireframe {

    private weak var parent: UIViewController?
    private weak var window: UIWindow?
    private let keyStoreService: KeyStoreService
    private let newMnemonic: MnemonicNewWireframeFactory
    private let updateMnemonic: MnemonicUpdateWireframeFactory
    private let importMnemonic: MnemonicImportWireframeFactory
    private let settingsService: SettingsService

    private weak var vc: UIViewController?

    init(
        parent: UIViewController?,
        window: UIWindow?,
        keyStoreService: KeyStoreService,
        newMnemonic: MnemonicNewWireframeFactory,
        updateMnemonic: MnemonicUpdateWireframeFactory,
        importMnemonic: MnemonicImportWireframeFactory,
        settingsService: SettingsService
    ) {
        self.parent = parent
        self.window = window
        self.keyStoreService = keyStoreService
        self.newMnemonic = newMnemonic
        self.updateMnemonic = updateMnemonic
        self.importMnemonic = importMnemonic
        self.settingsService = settingsService
    }
}

// MARK: - KeyStoreWireframe

extension DefaultKeyStoreWireframe: KeyStoreWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc

        if let window = self.window {
            window.rootViewController = vc
            window.makeKeyAndVisible()
            return
        }

        if let parent = self.parent as? EdgeCardsController {
            parent.setBottomCard(vc: vc)
        } else {
            parent?.show(vc, sender: self)
        }
    }

    func navigate(to destination: KeyStoreWireframeDestination) {
        let edgeVc = parent as? EdgeCardsController
        switch destination {
        case .networks:
            edgeVc?.setDisplayMode(.overviewTopCard, animated: true)
        case .dashBoard:
            edgeVc?.setDisplayMode(.master, animated: true)
        case .dashBoardOnboarding:
            edgeVc?.setDisplayMode(.masterOnboardAnim, animated: true)
        case let .newMnemonic(handler):
            let context = MnemonicNewContext(createHandler: handler)
            newMnemonic.makeWireframe(vc, context: context).present()
        case let .importMnemonic(handler):
            let context = MnemonicImportContext(createHandler: handler)
            importMnemonic.makeWireframe(vc, context: context).present()
        case let .keyStoreItem(keyStoreItem, handler):
            let context = MnemonicUpdateContext(
                keyStoreItem: keyStoreItem,
                updateHandler: handler
            )
            updateMnemonic.makeWireframe(vc, context: context).present()
        default:
            print("Navigate to", destination)

        }
    }
}

private extension DefaultKeyStoreWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultKeyStoreInteractor(keyStoreService)
        let vc: KeyStoreViewController = UIStoryboard(.keyStore).instantiate()
        let presenter = DefaultKeyStorePresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            settingsService: settingsService
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
