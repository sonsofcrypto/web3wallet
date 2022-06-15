// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct TokenDetailsWireframeContext {
    
    let presentationStyle: PresentationStyle
    let web3Token: Web3Token
}

enum TokenDetailsWireframeDestination {
    
}

protocol TokenDetailsWireframe {
    func present()
    func navigate(to destination: TokenDetailsWireframeDestination)
    func dismiss()
}

final class DefaultTokenDetailsWireframe {
    
    private weak var presentingIn: UIViewController!
    private let context: TokenDetailsWireframeContext
    private let web3Service: Web3Service
    
    private weak var navigationController: NavigationController!
    
    init(
        presentingIn: UIViewController,
        context: TokenDetailsWireframeContext,
        web3Service: Web3Service
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.web3Service = web3Service
    }
}

extension DefaultTokenDetailsWireframe: TokenDetailsWireframe {
    
    func present() {
        
        let vc = wireUp()
        
        switch context.presentationStyle {
            
        case .embed:
            guard let tabBarController = presentingIn as? TabBarController else {
                return
            }
            let vcs = tabBarController.add(viewController: vc)
            tabBarController.setViewControllers(vcs, animated: false)
            
        case .present:
            presentingIn.present(vc, animated: true)
            
        case .push:
            guard let presentingIn = presentingIn as? NavigationController else { return }
            presentingIn.pushViewController(vc, animated: true)
        }
    }
    
    func navigate(to destination: TokenDetailsWireframeDestination) {
        
        
    }
    
    func dismiss() {
        
        navigationController.popViewController(animated: true)
    }
}

private extension DefaultTokenDetailsWireframe {
    
    func wireUp() -> UIViewController {
        
        let interactor = DefaultTokenDetailsInteractor(
            web3Service: web3Service
        )
        let vc: TokenDetailsViewController = UIStoryboard(.tokenDetails).instantiate()
        let presenter = DefaultTokenDetailsPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )
        
        vc.presenter = presenter
        
        switch context.presentationStyle {
        case .embed:
            
            let navigationController = NavigationController(rootViewController: vc)
            navigationController.tabBarItem = UITabBarItem(
                title: Localized("apps"),
                image: UIImage(named: "tab_icon_apps"),
                tag: 3
            )
            self.navigationController = navigationController
            return navigationController
        case .present, .push:
            
            vc.hidesBottomBarWhenPushed = true
            
            if let navigationController = presentingIn as? NavigationController {
                
                self.navigationController = navigationController
                return vc
            }
            
            let navigationController = NavigationController(rootViewController: vc)
            self.navigationController = navigationController
            return navigationController
        }
    }
}
