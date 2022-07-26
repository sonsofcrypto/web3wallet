// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct NFTDetailWireframeContext {
    
    let nftIdentifier: String
    let nftCollectionIdentifier: String
    let presentationStyle: PresentationStyle
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
        
        switch context.presentationStyle {
            
        case .embed:
            fatalError()
            
        case .present:
            
            let navigationController = NavigationController(rootViewController: vc)
            self.navigationController = navigationController
            parent.present(navigationController, animated: true)

        case .push:
            
            guard let navigationController = parent as? NavigationController else {
                
                return
            }
            self.navigationController = navigationController
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func navigate(to destination: NFTDetailWireframeDestination) {
        
        switch destination {
            
        case .dismiss:
            
            switch context.presentationStyle {
                
            case .embed:
                fatalError()
                
            case .present:
                parent.presentedViewController?.dismiss(animated: true)
                
            case .push:
                navigationController.popViewController(animated: true)
            }
        }
    }
}

private extension DefaultNFTDetailWireframe {
    
    func makeViewController() -> UIViewController {
        
        let view: NFTDetailViewController = UIStoryboard(
            .nftDetail
        ).instantiate()
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
