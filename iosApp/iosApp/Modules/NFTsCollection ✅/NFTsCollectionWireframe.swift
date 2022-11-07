// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultNFTsCollectionWireframe {
    private weak var parent: UIViewController?
    private let context: NFTsCollectionWireframeContext
    private let nftDetailWireframeFactory: NFTDetailWireframeFactory
    private let nftsService: NFTsService

    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: NFTsCollectionWireframeContext,
        nftDetailWireframeFactory: NFTDetailWireframeFactory,
        nftsService: NFTsService
    ) {
        self.parent = parent
        self.context = context
        self.nftDetailWireframeFactory = nftDetailWireframeFactory
        self.nftsService = nftsService
    }
}

extension DefaultNFTsCollectionWireframe: NFTsCollectionWireframe {

    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }

    func navigate(destination: NFTsCollectionWireframeDestination) {
        if let input = destination as? NFTsCollectionWireframeDestination.NFTDetail {
            let context = NFTDetailWireframeContext(
                nftId: input.identifier,
                collectionId: context.collectionId
            )
            nftDetailWireframeFactory.make(vc, context: context).present()
        }
        if destination is NFTsCollectionWireframeDestination.Dismiss {
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultNFTsCollectionWireframe {

    func wireUp() -> UIViewController {
        let vc: NFTsCollectionViewController = UIStoryboard(.nftsCollection).instantiate()
        let interactor = DefaultNFTsCollectionInteractor(nftsService: nftsService)
        let presenter = DefaultNFTsCollectionPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.presenter = presenter
        self.vc = vc
        guard parent?.asNavVc == nil else { return vc }
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
}
