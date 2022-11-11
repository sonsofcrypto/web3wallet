// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

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

extension DefaultNFTDetailWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(with destination: NFTDetailWireframeDestination) {
        if let input = destination as? NFTDetailWireframeDestination.Send {
            guard let network = networksService.network else { return }
            let context = NFTSendWireframeContext(network: network, nftItem: input.nft)
            nftSendWireframeFactory.make( vc, context: context).present()
        }
        if destination is NFTDetailWireframeDestination.Dismiss {
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultNFTDetailWireframe {
    
    func wireUp() -> UIViewController {
        let vc: NFTDetailViewController = UIStoryboard(.nftDetail).instantiate()
        let interactor = DefaultNFTDetailInteractor(nftService: nftsService)
        let presenter = DefaultNFTDetailPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.presenter = presenter
        self.vc = vc
        return vc
    }
}
