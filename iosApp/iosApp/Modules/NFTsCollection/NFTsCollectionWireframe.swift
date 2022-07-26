// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct NFTsCollectionWireframeContext {
    
    let nftCollectionIdentifier: String
    let presentationStyle: PresentationStyle
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

    func navigate(to destination: NFTsCollectionWireframeDestination) {
        
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
            
            
        case let .nftDetail(identifier):
            
            let wireframe = nftDetailWireframeFactory.makeWireframe(
                navigationController,
                context: .init(
                    nftIdentifier: identifier,
                    nftCollectionIdentifier: context.nftCollectionIdentifier,
                    presentationStyle: .push
                )
            )
            wireframe.present()
        }
    }
}

private extension DefaultNFTsCollectionWireframe {

    func makeViewController() -> UIViewController {
        
        let view: NFTsCollectionViewController = UIStoryboard(
            .nftsCollection
        ).instantiate()
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
