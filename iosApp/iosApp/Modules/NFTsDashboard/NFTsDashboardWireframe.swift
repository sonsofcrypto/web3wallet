// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

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

extension DefaultNFTsDashboardWireframe {

    func present() {
        let vc = wireUp()
        if let tabVc = parent as? UITabBarController {
            let vcs = (tabVc.viewControllers ?? []) + [vc]
            tabVc.setViewControllers(vcs, animated: false)
        } else {
            parent?.show(vc, sender: self)
        }
    }

    func navigate(with destination: NFTsDashboardWireframeDestination) {
        if let input = destination as? NFTsDashboardWireframeDestination.ViewNFT {
            let context = NFTDetailWireframeContext(
                nftId: input.nftItem.identifier,
                collectionId: input.nftItem.collectionIdentifier
            )
            nftDetailWireframeFactory.make(vc, context: context).present()
        }
        if let input = destination as? NFTsDashboardWireframeDestination.ViewCollectionNFTs {
            let context = NFTsCollectionWireframeContext(collectionId: input.collectionId)
            nftsCollectionWireframeFactory.make(vc, context: context).present()
        }
        if let input = destination as? NFTsDashboardWireframeDestination.SendError {
            mailService.sendMail(context: .init(subject: .app, body: input.msg))
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
            nftsService: nftsService
        )
        let presenter = DefaultNFTsDashboardPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor
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
