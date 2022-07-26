// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum NFTsDashboardWireframeDestination {

    case viewCollectionNFTs(collectionId: String)
    case viewNFT(nftItem: NFTItem)
}

protocol NFTsDashboardWireframe {
    func present()
    func navigate(to destination: NFTsDashboardWireframeDestination)
}

final class DefaultNFTsDashboardWireframe {

    private weak var parent: TabBarController!
    private let nftsCollectionWireframeFactory: NFTsCollectionWireframeFactory
    private let nftDetailWireframeFactory: NFTDetailWireframeFactory
    private let nftsService: NFTsService

    private weak var navigationController: NavigationController!
    
    init(
        parent: TabBarController,
        nftsCollectionWireframeFactory: NFTsCollectionWireframeFactory,
        nftDetailWireframeFactory: NFTDetailWireframeFactory,
        nftsService: NFTsService
    ) {
        self.parent = parent
        self.nftsCollectionWireframeFactory = nftsCollectionWireframeFactory
        self.nftDetailWireframeFactory = nftDetailWireframeFactory
        self.nftsService = nftsService
    }
}

extension DefaultNFTsDashboardWireframe: NFTsDashboardWireframe {

    func present() {
        
        let viewController = makeViewController()
        
        let navigationController = NavigationController(rootViewController: viewController)
        self.navigationController = navigationController
        
        navigationController.tabBarItem = UITabBarItem(
            title: Localized("nfts"),
            image: UIImage(named: "tab_icon_nfts"),
            tag: 2
        )

        let vcs = (parent.viewControllers ?? []) + [navigationController]
        parent.setViewControllers(vcs, animated: false)
    }

    func navigate(to destination: NFTsDashboardWireframeDestination) {
        
        switch destination {
            
        case let .viewNFT(nftItem):
            
            let wireframe = nftDetailWireframeFactory.makeWireframe(
                navigationController,
                context: .init(
                    nftIdentifier: nftItem.identifier,
                    nftCollectionIdentifier: nftItem.collectionIdentifier
                )
            )
            wireframe.present()
            
        case let .viewCollectionNFTs(collectionId):
            
            let wireframe = nftsCollectionWireframeFactory.makeWireframe(
                navigationController,
                context: .init(
                    nftCollectionIdentifier: collectionId,
                    presentationStyle: .push
                )
            )
            wireframe.present()
        }
    }
}

private extension DefaultNFTsDashboardWireframe {

    func makeViewController() -> UIViewController {
        
        let view: NFTsDashboardViewController = UIStoryboard(
            .nftsDashboard
        ).instantiate()
        let interactor = DefaultNFTsDashboardInteractor(
            service: nftsService
        )
        let presenter = DefaultNFTsDashboardPresenter(
            view: view,
            interactor: interactor,
            wireframe: self
        )
        view.presenter = presenter
        return view
    }
}
