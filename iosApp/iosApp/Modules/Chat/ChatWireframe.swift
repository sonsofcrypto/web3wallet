// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ChatWireframe {
    func present()
}

final class DefaultChatWireframe {
    private weak var parent: UIViewController?
    private let chatService: ChatService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        chatService: ChatService
    ) {
        self.parent = parent
        self.chatService = chatService
    }
}

extension DefaultChatWireframe: ChatWireframe {
    
    func present() {
        let vc = wireUp()
        if let tabVc = parent as? UITabBarController {
            let vcs = tabVc.add(viewController: vc)
            tabVc.setViewControllers(vcs, animated: false)
        } else {
            parent?.show(vc, sender: self)
        }
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
            wireframe: self,
            interactor: interactor
        )
        vc.presenter = presenter
        vc.hidesBottomBarWhenPushed = true
        self.vc = vc
        guard parent?.asNavigationController == nil else { return vc }
        let nc = NavigationController(rootViewController: vc)
        nc.tabBarItem = UITabBarItem(
            title: Localized("apps"),
            image: "tab_icon_apps".assetImage,
            tag: 3
        )
        self.vc = nc
        return nc
    }
}
