//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

enum AppsWireframeDestination {

}

protocol AppsWireframe {
    func present()
    func navigate(to destination: AppsWireframeDestination)
}

// MARK: - DefaultAppsWireframe

class DefaultAppsWireframe {

    private weak var parent: UIViewController?

    private let interactor: AppsInteractor

    init(
        parent: UIViewController,
        interactor: AppsInteractor
    ) {
        self.parent = parent
        self.interactor = interactor
    }
}

// MARK: - AppsWireframe

extension DefaultAppsWireframe: AppsWireframe {

    func present() {
        let vc = wireUp()

        if let tabVc = self.parent as? UITabBarController {
            let vcs = (tabVc.viewControllers ?? []) + [vc]
            tabVc.setViewControllers(vcs, animated: false)
            return
        }

        vc.show(vc, sender: self)
    }

    func navigate(to destination: AppsWireframeDestination) {
        print("navigate to \(destination)")
    }
}

extension DefaultAppsWireframe {

    private func wireUp() -> UIViewController {
        let vc: AppsViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultAppsPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
