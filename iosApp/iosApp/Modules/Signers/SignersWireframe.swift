// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - DefaultSignersWireframe

final class DefaultSignersWireframe {
    private weak var parent: UIViewController?
    private let keyStoreService: KeyStoreService
    private let networksService: NetworksService
    private let newMnemonic: MnemonicNewWireframeFactory
    private let updateMnemonic: MnemonicUpdateWireframeFactory
    private let importMnemonic: MnemonicImportWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        keyStoreService: KeyStoreService,
        networksService: NetworksService,
        newMnemonic: MnemonicNewWireframeFactory,
        updateMnemonic: MnemonicUpdateWireframeFactory,
        importMnemonic: MnemonicImportWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory
    ) {
        self.parent = parent
        self.keyStoreService = keyStoreService
        self.networksService = networksService
        self.newMnemonic = newMnemonic
        self.updateMnemonic = updateMnemonic
        self.importMnemonic = importMnemonic
        self.alertWireframeFactory = alertWireframeFactory
    }
}

// MARK: - SignersWireframe

extension DefaultSignersWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc
        parent?.asEdgeCardsController?.setBottomCard(vc: vc) ?? parent?.show(vc, sender: self)
    }

    func navigate(to destination: SignersWireframeDestination) {
        let edgeVc = parent as? EdgeCardsController
        if destination is SignersWireframeDestination.SignersFullscreen {
            edgeVc?.setDisplayMode(.bottomCard)
        }
        if destination is SignersWireframeDestination.Networks {
            edgeVc?.setDisplayMode(.overviewTopCard, animated: true)
        }
        if destination is SignersWireframeDestination.Dashboard {
            edgeVc?.setDisplayMode(.master, animated: true)
        }
        if destination is SignersWireframeDestination.DashboardOnboarding {
            edgeVc?.setDisplayMode(.masterOnboardAnim, animated: true)
        }
        if let input = destination as? SignersWireframeDestination.NewMnemonic {
            let context = MnemonicNewWireframeContext(handler: input.handler)
            newMnemonic.make(vc, context: context).present()
        }
        if let input = destination as? SignersWireframeDestination.ImportMnemonic {
            let context = MnemonicImportWireframeContext(handler: input.handler)
            importMnemonic.make(vc, context: context).present()
        }
        if let input = destination as? SignersWireframeDestination.EditSignersItem {
            let context = MnemonicUpdateWireframeContext(
                keyStoreItem: input.item,
                onUpdateHandler: input.handler,
                onDeleteHandler: input.deleteHandler
            )
            updateMnemonic.make(vc, context: context).present()
        }
        if destination is SignersWireframeDestination.ConnectHardwareWallet {
            alertWireframeFactory.make(vc, context: .underConstructionAlert()).present()
        }
        if destination is SignersWireframeDestination.ImportPrivateKey {
            alertWireframeFactory.make(vc, context: .underConstructionAlert()).present()
        }
        if destination is SignersWireframeDestination.CreateMultisig {
            alertWireframeFactory.make(vc, context: .underConstructionAlert()).present()
        }
    }
}

private extension DefaultSignersWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultSignersInteractor(
            keyStoreService: keyStoreService,
            networksService: networksService
        )
        let vc: SignersViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultSignersPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
