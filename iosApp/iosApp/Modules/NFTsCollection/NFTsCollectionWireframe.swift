// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct NFTsCollectionWireframeContext {
    
    let nftCollectionIdentifier: String
}

enum NFTsCollectionWireframeDestination {

    case dismiss
    case nftDetail(identifier: String)
}

protocol NFTsCollectionWireframe {
    func present()
    func navigate(to destination: NFTsCollectionWireframeDestination)
}

final class DefaultNFTsCollectionWireframe {

    private weak var parent: UIViewController!
    private let context: NFTsCollectionWireframeContext
    private let nftDetailWireframeFactory: NFTDetailWireframeFactory
    private let nftsService: NFTsService

    private weak var navigationController: NavigationController!
    
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
        
        let vc = makeViewController()
        let navigationController = NavigationController(rootViewController: vc)
        self.navigationController = navigationController
        parent.present(navigationController, animated: true)
    }

    func navigate(to destination: NFTsCollectionWireframeDestination) {
        
        switch destination {
            
        case .dismiss:
            
            parent.presentedViewController?.dismiss(animated: true)
            
        case let .nftDetail(identifier):
            
            let parent: UIViewController = parent.presentedViewController ?? parent
            let wireframe = nftDetailWireframeFactory.makeWireframe(
                parent,
                context: .init(
                    nftIdentifier: identifier,
                    nftCollectionIdentifier: context.nftCollectionIdentifier
                )
            )
            wireframe.present()
        }
    }
}

private extension DefaultNFTsCollectionWireframe {

    func makeViewController() -> UIViewController {
        
        let view = NFTsCollectionViewController()
        let interactor = DefaultNFTsCollectionInteractor(
            service: nftsService
        )
        let presenter = DefaultNFTsCollectionPresenter(
            context: context,
            view: view,
            interactor: interactor,
            wireframe: self
        )
        view.presenter = presenter
        return view
    }
}
