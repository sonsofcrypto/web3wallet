// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum AppsWireframeDestination {
    case chat
}

protocol AppsWireframe {
    func present()
    func navigate(to destination: AppsWireframeDestination)
}

final class DefaultAppsWireframe {
    private weak var parent: UIViewController?
    private let chatWireframeFactory: ChatWireframeFactory
    private let appsService: AppsService
    
    private weak var vc: UIViewController!
    
    init(
        _ parent: UIViewController?,
        chatWireframeFactory: ChatWireframeFactory,
        appsService: AppsService
    ) {
        self.parent = parent
        self.chatWireframeFactory = chatWireframeFactory
        self.appsService = appsService
    }
}

extension DefaultAppsWireframe: AppsWireframe {
    
    func present() {
        let vc = wireUp()
        if let tabVc = parent as? UITabBarController {
            let vcs = tabVc.add(viewController: vc)
            tabVc.setViewControllers(vcs, animated: false)
        } else {
            parent?.show(vc, sender: self)
        }
    }
    
    func navigate(to destination: AppsWireframeDestination) {
        switch destination {
        case .chat:
            chatWireframeFactory.make(vc).present()
        }
    }
}

private extension DefaultAppsWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultAppsInteractor(
            appsService: appsService
        )
        let vc: AppsViewController = UIStoryboard(.apps).instantiate()
        let presenter = DefaultAppsPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor
        )
        vc.presenter = presenter
        
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        nc.tabBarItem = UITabBarItem(
            title: Localized("apps"),
            image: "tab_icon_apps".assetImage,
            tag: 3
        )
        return nc
    }
}
