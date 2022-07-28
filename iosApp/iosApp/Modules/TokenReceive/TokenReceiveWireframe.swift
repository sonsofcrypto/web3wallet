// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct TokenReceiveWireframeContext {
    
    let presentationStyle: PresentationStyle
    let web3Token: Web3Token
}

enum TokenReceiveWireframeDestination {
    
}

protocol TokenReceiveWireframe {
    func present()
    func navigate(to destination: TokenReceiveWireframeDestination)
    func dismiss()
}

final class DefaultTokenReceiveWireframe {
    
    private weak var presentingIn: UIViewController!
    private let context: TokenReceiveWireframeContext
    private let web3Service: Web3Service
    
    private weak var navigationController: NavigationController!
    
    init(
        presentingIn: UIViewController,
        context: TokenReceiveWireframeContext,
        web3Service: Web3Service
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.web3Service = web3Service
    }
}

extension DefaultTokenReceiveWireframe: TokenReceiveWireframe {
    
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
    
    func navigate(to destination: TokenReceiveWireframeDestination) {
        
        
    }
    
    func dismiss() {
        
        if navigationController.viewControllers.count == 1 {
            
            navigationController.dismiss(animated: true)
        } else {
            navigationController.popViewController(animated: true)
        }
    }
}

private extension DefaultTokenReceiveWireframe {
    
    func wireUp() -> UIViewController {
        
        let interactor = DefaultTokenReceiveInteractor(
            web3Service: web3Service
        )
        let vc: TokenReceiveViewController = UIStoryboard(.tokenReceive).instantiate()
        let presenter = DefaultTokenReceivePresenter(
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
                image: "tab_icon_apps".assetImage,
                tag: 3
            )
            self.navigationController = navigationController
            return navigationController
        case .present:

            vc.hidesBottomBarWhenPushed = true
            
            let navigationController = NavigationController(rootViewController: vc)
            self.navigationController = navigationController
            return navigationController

        case .push:
            
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
