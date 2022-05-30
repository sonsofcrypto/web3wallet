// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct NFTDetailWireframeContext {
    
    let nftIdentifier: String
    let nftCollectionIdentifier: String
}

enum NFTDetailWireframeDestination {
    
    case dismiss
}

protocol NFTDetailWireframe {
    func present()
    func navigate(to destination: NFTDetailWireframeDestination)
}

final class DefaultNFTDetailWireframe {
    
    private weak var parent: UIViewController!
    private let context: NFTDetailWireframeContext
    private let nftsService: NFTsService
    
    private weak var navigationController: NavigationController!
    
    init(
        parent: UIViewController,
        context: NFTDetailWireframeContext,
        nftsService: NFTsService
    ) {
        self.parent = parent
        self.context = context
        self.nftsService = nftsService
    }
}

extension DefaultNFTDetailWireframe: NFTDetailWireframe {
    
    func present() {
        
        let vc = makeViewController()
        
        //        if let navigationController = parent as? NavigationController {
        //
        //            self.navigationController = navigationController
        //
        //            navigationController.pushViewController(vc, animated: true)
        //        } else {
        //
        let navigationController = NavigationController(rootViewController: vc)
        self.navigationController = navigationController
        parent.present(navigationController, animated: true)
        //        }
    }
    
    func navigate(to destination: NFTDetailWireframeDestination) {
        
        switch destination {
            
        case .dismiss:
            parent.presentedViewController?.dismiss(animated: true)
        }
    }
}

private extension DefaultNFTDetailWireframe {
    
    func makeViewController() -> UIViewController {
        
        let view = NFTDetailViewController()
        let interactor = DefaultNFTDetailInteractor(
            service: nftsService
        )
        let presenter = DefaultNFTDetailPresenter(
            context: context,
            view: view,
            interactor: interactor,
            wireframe: self
        )
        view.presenter = presenter
        return view
    }
}
