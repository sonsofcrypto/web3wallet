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
    
    private weak var presentingIn: UITabBarController!
    private let chatWireframeFactory: ChatWireframeFactory
    private let appsService: AppsService
    
    private weak var navigationController: NavigationController!
    
    init(
        presentingIn: UITabBarController,
        chatWireframeFactory: ChatWireframeFactory,
        appsService: AppsService
    ) {
        self.presentingIn = presentingIn
        self.chatWireframeFactory = chatWireframeFactory
        self.appsService = appsService
    }
}

extension DefaultAppsWireframe: AppsWireframe {
    
    func present() {
        
        let vc = wireUp()
        let vcs = presentingIn.add(viewController: vc)
        presentingIn.setViewControllers(vcs, animated: false)
    }
    
    func navigate(to destination: AppsWireframeDestination) {
        
        switch destination {
        case .chat:
            let wireframe = chatWireframeFactory.makeWireframe(
                presentingIn: navigationController,
                context: .init(presentationStyle: .push)
            )
            wireframe.present()
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
            interactor: interactor,
            wireframe: self
        )
        
        vc.presenter = presenter
        
        let navigationController = NavigationController(rootViewController: vc)
        self.navigationController = navigationController
        
        navigationController.tabBarItem = UITabBarItem(
            title: Localized("apps"),
            image: "tab_icon_apps".assetImage,
            tag: 3
        )

        return navigationController
    }
}
