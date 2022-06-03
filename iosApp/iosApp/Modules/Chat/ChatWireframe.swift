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
    
    private weak var presentingIn: NavigationController!
    private let context: ChatWireframeContext
    private let chatService: ChatService
    
    init(
        presentingIn: NavigationController,
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
            
        case .present:
            presentingIn.present(vc, animated: true)
            
        case .push:
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
        vc.hidesBottomBarWhenPushed = true
        let presenter = DefaultChatPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )
        
        vc.presenter = presenter
        return vc
    }
}
