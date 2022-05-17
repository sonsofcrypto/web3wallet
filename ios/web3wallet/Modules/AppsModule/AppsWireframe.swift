// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum AppsWireframeDestination {
    
}

protocol AppsWireframe {
    func present()
    func navigate(to destination: AppsWireframeDestination)
}

// MARK: - DefaultAppsWireframe

final class DefaultAppsWireframe {
    
    private weak var parent: UITabBarController!
    private let appsService: AppsService
    
    private weak var navigationController: UINavigationController!
    
    init(
        parent: UITabBarController,
        appsService: AppsService
    ) {
        self.parent = parent
        self.appsService = appsService
    }
}

// MARK: - AppsWireframe

extension DefaultAppsWireframe: AppsWireframe {
    
    func present() {
        
        let vc = wireUp()
        let vcs = (parent.viewControllers ?? []) + [vc]
        parent.setViewControllers(vcs, animated: false)
    }
    
    func navigate(to destination: AppsWireframeDestination) {
        print("navigate to \(destination)")
    }
}

private extension DefaultAppsWireframe {
    
    func wireUp() -> UIViewController {
        
        let interactor = DefaultAppsInteractor(
            appsService: appsService
        )
        let vc: AppsViewController = UIStoryboard(.main).instantiate()
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
            image: UIImage(named: "tab_icon_apps"),
            tag: 3
        )

        return navigationController
    }
}
