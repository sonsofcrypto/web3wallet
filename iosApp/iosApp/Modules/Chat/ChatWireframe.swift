// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct ChatWireframeContext {
    
    let presentationStyle: PresentationStyle
}

enum ChatWireframeDestination {
    
}

protocol ChatWireframe {
    func present()
    func navigate(to destination: ChatWireframeDestination)
}

final class DefaultChatWireframe {
    
    private weak var presentingIn: UIViewController!
    private let context: ChatWireframeContext
    private let chatService: ChatService
    
    init(
        presentingIn: UIViewController,
        context: ChatWireframeContext,
        chatService: ChatService
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.chatService = chatService
    }
}

extension DefaultChatWireframe: ChatWireframe {
    
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
    
    func navigate(to destination: ChatWireframeDestination) {
        
        
    }
}

private extension DefaultChatWireframe {
    
    func wireUp() -> UIViewController {
        
        let interactor = DefaultChatInteractor(
            chatService: chatService
        )
        let vc: ChatViewController = UIStoryboard(.chat).instantiate()
        let presenter = DefaultChatPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
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
            return navigationController
        case .present, .push:
            vc.hidesBottomBarWhenPushed = true
            return vc
        }
    }
}
