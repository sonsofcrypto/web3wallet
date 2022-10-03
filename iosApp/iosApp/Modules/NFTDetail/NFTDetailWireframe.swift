// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

struct NFTDetailWireframeContext {
    let nftIdentifier: String
    let nftCollectionIdentifier: String
}

enum NFTDetailWireframeDestination {
    case underConstruction
    case send(NFTItem)
    case dismiss
}

protocol NFTDetailWireframe {
    func present()
    func navigate(to destination: NFTDetailWireframeDestination)
}

final class DefaultNFTDetailWireframe {
    private weak var parent: UIViewController?
    private let context: NFTDetailWireframeContext
    private let nftSendWireframeFactory: NFTSendWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let nftsService: NFTsService
    private let networksService: NetworksService

    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: NFTDetailWireframeContext,
        nftSendWireframeFactory: NFTSendWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        nftsService: NFTsService,
        networksService: NetworksService
    ) {
        self.parent = parent
        self.context = context
        self.nftSendWireframeFactory = nftSendWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.nftsService = nftsService
        self.networksService = networksService
    }
}

extension DefaultNFTDetailWireframe: NFTDetailWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(to destination: NFTDetailWireframeDestination) {
        switch destination {
        case .underConstruction:
            alertWireframeFactory.make(
                vc,
                context: .underConstructionAlert()
            ).present()
        case let .send(nftItem):
            guard let network = networksService.network else { return }
            nftSendWireframeFactory.make(
                vc,
                context: .init(network: network, nftItem: nftItem)
            ).present()
        case .dismiss:
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultNFTDetailWireframe {
    
    func wireUp() -> UIViewController {
        let vc: NFTDetailViewController = UIStoryboard(
            .nftDetail
        ).instantiate()
        let interactor = DefaultNFTDetailInteractor(
            service: nftsService
        )
        let presenter = DefaultNFTDetailPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.presenter = presenter
        self.vc = vc
        return vc
    }
}
