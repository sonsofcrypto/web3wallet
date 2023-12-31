// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - DefaultSignersWireframe

final class DefaultSignersWireframe {
    private weak var parent: UIViewController?
    private let signerStoreService: SignerStoreService
    private let networksService: NetworksService
    private let clipboardService: ClipboardService
    private let newMnemonic: MnemonicNewWireframeFactory
    private let updateMnemonic: MnemonicUpdateWireframeFactory
    private let updatePrvKey: PrvKeyUpdateWireframeFactory
    private let importMnemonic: MnemonicImportWireframeFactory
    private let importPrvKey: PrvKeyImportWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let authenticateWireframeFactory: AuthenticateWireframeFactory

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        signerStoreService: SignerStoreService,
        networksService: NetworksService,
        clipboardService: ClipboardService,
        newMnemonic: MnemonicNewWireframeFactory,
        updateMnemonic: MnemonicUpdateWireframeFactory,
        updatePrvKey: PrvKeyUpdateWireframeFactory,
        importMnemonic: MnemonicImportWireframeFactory,
        importPrivKey: PrvKeyImportWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        authenticateWireframeFactory: AuthenticateWireframeFactory
    ) {
        self.parent = parent
        self.signerStoreService = signerStoreService
        self.networksService = networksService
        self.clipboardService =  clipboardService
        self.newMnemonic = newMnemonic
        self.updateMnemonic = updateMnemonic
        self.updatePrvKey = updatePrvKey
        self.importMnemonic = importMnemonic
        self.importPrvKey = importPrivKey
        self.alertWireframeFactory = alertWireframeFactory
        self.authenticateWireframeFactory = authenticateWireframeFactory
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
        if let input =  destination as? SignersWireframeDestination.ImportPrvKey {
            let context = PrvKeyImportWireframeContext(handler: input.handler)
            importPrvKey.make(vc, context: context).present()
        }
        if let input = destination as? SignersWireframeDestination.EditSignersItem {
            if input.item.type == .prvkey {
                let context = PrvKeyUpdateWireframeContext(
                    signerStoreItem: input.item,
                    updateHandler: input.updateHandler,
                    deleteHandler: input.deleteHandler
                )
                updatePrvKey.make(vc, context: context).present()
                return;
            }
            let context = MnemonicUpdateWireframeContext(
                signerStoreItem: input.item,
                updateHandler: input.updateHandler,
                addAccountHandler: input.addAccountHandler,
                deleteHandler: input.deleteHandler
            )
            updateMnemonic.make(vc, context: context).present()
        }
        if destination is SignersWireframeDestination.ConnectHardwareWallet {
            alertWireframeFactory.make(vc, context: .underConstructionAlert()).present()
        }
        if destination is SignersWireframeDestination.CreateMultisig {
            alertWireframeFactory.make(vc, context: .underConstructionAlert()).present()
        }
        if let d = destination as? SignersWireframeDestination.Authenticate {
            authenticateWireframeFactory.make(vc,context: d.context).present()
        }
    }
}

private extension DefaultSignersWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultSignersInteractor(
            signerStoreService: signerStoreService,
            networksService: networksService,
            clipboardService: clipboardService
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
