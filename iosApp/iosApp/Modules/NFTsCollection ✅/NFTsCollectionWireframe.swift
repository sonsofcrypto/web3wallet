// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct NFTsCollectionWireframeContext {
    let nftCollectionIdentifier: String
    let presentationStyle: PresentationStyle
}

enum NFTsCollectionWireframeDestination {
    case nftDetail(identifier: String)
    case dismiss
}

protocol NFTsCollectionWireframe {
    func present()
    func navigate(to destination: NFTsCollectionWireframeDestination)
}

final class DefaultNFTsCollectionWireframe {
    private weak var parent: UIViewController?
    private let context: NFTsCollectionWireframeContext
    private let nftDetailWireframeFactory: NFTDetailWireframeFactory
    private let nftsService: NFTsService

    private weak var vc: UIViewController?
    
    init(
        parent: UIViewController,
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

    func navigate(to destination: NFTsCollectionWireframeDestination) {
        switch destination {
        case let .nftDetail(identifier):
            nftDetailWireframeFactory.makeWireframe(
                vc,
                context: .init(
                    nftIdentifier: identifier,
                    nftCollectionIdentifier: context.nftCollectionIdentifier,
                    presentationStyle: .push
                )
            ).present()
        case .dismiss:
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultNFTsCollectionWireframe {

    func wireUp() -> UIViewController {
        let vc: NFTsCollectionViewController = UIStoryboard(
            .nftsCollection
        ).instantiate()
        let interactor = DefaultNFTsCollectionInteractor(
            service: nftsService
        )
        let presenter = DefaultNFTsCollectionPresenter(
            context: context,
            view: vc,
            interactor: interactor,
            wireframe: self
        )
        vc.presenter = presenter
        self.vc = vc
        guard parent?.asNavigationController == nil else { return vc }
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
}
