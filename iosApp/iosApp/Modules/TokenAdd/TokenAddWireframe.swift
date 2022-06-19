// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct TokenAddWireframeContext {
    
    let presentationStyle: PresentationStyle
}

enum TokenAddWireframeDestination {
    
}

protocol TokenAddWireframe {
    func present()
    func navigate(to destination: TokenAddWireframeDestination)
    func dismiss()
}

final class DefaultTokenAddWireframe {
    
    private weak var presentingIn: UIViewController!
    private let context: TokenAddWireframeContext
    private let web3Service: Web3Service
    
    private weak var navigationController: NavigationController!
    
    init(
        presentingIn: UIViewController,
        context: TokenAddWireframeContext,
        web3Service: Web3Service
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.web3Service = web3Service
    }
}

extension DefaultTokenAddWireframe: TokenAddWireframe {
    
    func present() {
        
        let vc = wireUp()
        
        switch context.presentationStyle {
            
        case .embed:
            fatalError("This module should never be embeded")
            
        case .present:
            presentingIn.present(vc, animated: true)
            
        case .push:
            guard let navigationController = presentingIn as? NavigationController else { return }
            self.navigationController = navigationController
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func navigate(to destination: TokenAddWireframeDestination) {
        
    }
    
    func dismiss() {
        
        if navigationController.viewControllers.count == 1 {
            
            navigationController.dismiss(animated: true)
        } else {
            navigationController.popViewController(animated: true)
        }
    }
}

private extension DefaultTokenAddWireframe {
    
    func wireUp() -> UIViewController {
        
        let interactor = DefaultTokenAddInteractor(
            web3Service: web3Service
        )
        let vc: TokenAddViewController = UIStoryboard(.tokenAdd).instantiate()
        let presenter = DefaultTokenAddPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )
        
        vc.presenter = presenter
        
        switch context.presentationStyle {
        case .embed:
            
            fatalError("This module should never be embeded")
        case .present:

            vc.hidesBottomBarWhenPushed = true
            
            let navigationController = NavigationController(rootViewController: vc)
            self.navigationController = navigationController
            return navigationController

        case .push:
            
            vc.hidesBottomBarWhenPushed = true
            return vc
        }
    }
}
