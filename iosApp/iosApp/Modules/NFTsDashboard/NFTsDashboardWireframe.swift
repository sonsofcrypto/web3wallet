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
    private weak var parent: UIViewController?
    private let nftsCollectionWireframeFactory: NFTsCollectionWireframeFactory
    private let nftDetailWireframeFactory: NFTDetailWireframeFactory
    private let nftsService: NFTsService
    private let networksService: NetworksService
    private let mailService: MailService

    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
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
        let vc = wireUp()
        if let tabVc = parent as? UITabBarController {
            let vcs = tabVc.add(viewController: vc)
            tabVc.setViewControllers(vcs, animated: false)
        } else {
            parent?.show(vc, sender: self)
        }
    }

    func navigate(to destination: NFTsDashboardWireframeDestination) {
        switch destination {
        case let .viewNFT(nftItem):
            nftDetailWireframeFactory.make(
                vc,
                context: .init(
                    nftIdentifier: nftItem.identifier,
                    nftCollectionIdentifier: nftItem.collectionIdentifier
                )
            ).present()
        case let .viewCollectionNFTs(collectionId):
            nftsCollectionWireframeFactory.make(
                vc,
                context: .init(
                    nftCollectionIdentifier: collectionId,
                    presentationStyle: .push
                )
            ).present()
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

    func wireUp() -> UIViewController {
        let vc: NFTsDashboardViewController = UIStoryboard(
            .nftsDashboard
        ).instantiate()
        let interactor = DefaultNFTsDashboardInteractor(
            networksService: networksService,
            service: nftsService
        )
        let presenter = DefaultNFTsDashboardPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
            nftsService: nftsService
        )
        vc.presenter = presenter
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        nc.tabBarItem = UITabBarItem(
            title: Localized("nfts"),
            image: "tab_icon_nfts".assetImage,
            tag: 2
        )
        return nc
    }
}
