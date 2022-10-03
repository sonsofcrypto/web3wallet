// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

enum KeyStoreWireframeDestination {

    typealias KeyStoreItemHandler = (KeyStoreItem)->Void

    case hideNetworksAndDashboard
    case networks
    case dashBoard
    case dashBoardOnboarding
    case keyStoreItem(item: KeyStoreItem, handler: KeyStoreItemHandler, onDeleted: ()->Void)
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
    private let keyStoreService: KeyStoreService
    private let networksService: NetworksService
    private let newMnemonic: MnemonicNewWireframeFactory
    private let updateMnemonic: MnemonicUpdateWireframeFactory
    private let importMnemonic: MnemonicImportWireframeFactory
    private let settingsService: SettingsService
    private let alertWireframeFactory: AlertWireframeFactory

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        keyStoreService: KeyStoreService,
        networksService: NetworksService,
        newMnemonic: MnemonicNewWireframeFactory,
        updateMnemonic: MnemonicUpdateWireframeFactory,
        importMnemonic: MnemonicImportWireframeFactory,
        settingsService: SettingsService,
        alertWireframeFactory: AlertWireframeFactory
    ) {
        self.parent = parent
        self.keyStoreService = keyStoreService
        self.networksService = networksService
        self.newMnemonic = newMnemonic
        self.updateMnemonic = updateMnemonic
        self.importMnemonic = importMnemonic
        self.settingsService = settingsService
        self.alertWireframeFactory = alertWireframeFactory
    }
}

// MARK: - KeyStoreWireframe

extension DefaultKeyStoreWireframe: KeyStoreWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc
        parent?.asEdgeCardsController?.setBottomCard(vc: vc) ?? parent?.show(vc, sender: self)
    }

    func navigate(to destination: KeyStoreWireframeDestination) {
        let edgeVc = parent as? EdgeCardsController
        switch destination {
        case .hideNetworksAndDashboard:
            edgeVc?.setDisplayMode(.bottomCard)
        case .networks:
            edgeVc?.setDisplayMode(.overviewTopCard, animated: true)
        case .dashBoard:
            edgeVc?.setDisplayMode(.master, animated: true)
        case .dashBoardOnboarding:
            edgeVc?.setDisplayMode(.masterOnboardAnim, animated: true)
        case let .newMnemonic(handler):
            let context = MnemonicNewContext(createHandler: handler)
            newMnemonic.make(vc, context: context).present()
        case let .importMnemonic(handler):
            let context = MnemonicImportContext(createHandler: handler)
            importMnemonic.make(vc, context: context).present()
        case let .keyStoreItem(keyStoreItem, handler, onDeleted):
            let context = MnemonicUpdateContext(
                keyStoreItem: keyStoreItem,
                updateHandler: handler,
                onKeyStoreItemDeleted: onDeleted
            )
            updateMnemonic.make(vc, context: context).present()
        default:
            guard let vc = vc else { return }
            alertWireframeFactory.make(
                vc,
                context: .underConstructionAlert()
            ).present()
        }
    }
}

private extension DefaultKeyStoreWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultKeyStoreInteractor(
            keyStoreService,
            networksService: networksService
        )
        let vc: KeyStoreViewController = UIStoryboard(.keyStore).instantiate()
        let presenter = DefaultKeyStorePresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
            settingsService: settingsService
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
