// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

enum NFTsDashboardWireframeDestination {
    case viewCollectionNFTs(collectionId: String)
    case viewNFT(nftItem: NFTItem)
    case sendError(msg: String)
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
    private let networksService: NetworksService
    private let mailService: MailService

    private weak var navigationController: NavigationController!
    
    init(
        parent: TabBarController,
        nftsCollectionWireframeFactory: NFTsCollectionWireframeFactory,
        nftDetailWireframeFactory: NFTDetailWireframeFactory,
        nftsService: NFTsService,
        networksService: NetworksService,
        mailService: MailService
    ) {
        self.parent = parent
        self.nftsCollectionWireframeFactory = nftsCollectionWireframeFactory
        self.nftDetailWireframeFactory = nftDetailWireframeFactory
        self.nftsService = nftsService
        self.networksService = networksService
        self.mailService = mailService
    }
}

extension DefaultNFTsDashboardWireframe: NFTsDashboardWireframe {

    func present() {
        
        let viewController = makeViewController()
        
        let navigationController = NavigationController(rootViewController: viewController)
        self.navigationController = navigationController
        
        navigationController.tabBarItem = UITabBarItem(
            title: Localized("nfts"),
            image: "tab_icon_nfts".assetImage,
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
                    nftCollectionIdentifier: nftItem.collectionIdentifier,
                    presentationStyle: .push
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

        case let .sendError(msg):
            mailService.sendMail(
                context: .init(
                    subject: .app,
                    body: msg
                )
            )
        }
    }
}

private extension DefaultNFTsDashboardWireframe {

    func makeViewController() -> UIViewController {
        
        let view: NFTsDashboardViewController = UIStoryboard(
            .nftsDashboard
        ).instantiate()
        let interactor = DefaultNFTsDashboardInteractor(
            networksService: networksService,
            service: nftsService
        )
        let presenter = DefaultNFTsDashboardPresenter(
            view: view,
            interactor: interactor,
            wireframe: self,
            nftsService: nftsService
        )
        view.presenter = presenter
        return view
    }
}
