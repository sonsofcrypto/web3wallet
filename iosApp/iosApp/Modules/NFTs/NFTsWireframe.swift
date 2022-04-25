// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum NFTsWireframeDestination {

}

protocol NFTsWireframe {
    func present()
    func navigate(to destination: NFTsWireframeDestination)
}

final class DefaultNFTsWireframe {

    private weak var parent: TabBarController!
    private let nftsService: NFTsService

    private weak var navigationController: NavigationController!
    
    init(
        parent: TabBarController,
        nftsService: NFTsService
    ) {
        self.parent = parent
        self.nftsService = nftsService
    }
}

extension DefaultNFTsWireframe: NFTsWireframe {

    func present() {
        
        let vc = wireUp()
        let vcs = (parent.viewControllers ?? []) + [vc]
        parent.setViewControllers(vcs, animated: false)
    }

    func navigate(to destination: NFTsWireframeDestination) {
        print("navigate to \(destination)")
    }
}

extension DefaultNFTsWireframe {

    private func wireUp() -> UIViewController {
        
        let interactor = DefaultNFTsInteractor(nftsService)
        let vc: NFTsViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultNFTsPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        let navigationController = NavigationController(rootViewController: vc)
        self.navigationController = navigationController
        
        navigationController.tabBarItem = UITabBarItem(
            title: Localized("nfts"),
            image: UIImage(named: "tab_icon_nfts"),
            tag: 2
        )

        return navigationController
    }
}
