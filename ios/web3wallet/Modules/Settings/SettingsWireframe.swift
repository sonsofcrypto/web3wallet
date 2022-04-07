//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

enum SettingsWireframeDestination {

}

protocol SettingsWireframe {
    func present()
    func navigate(to destination: SettingsWireframeDestination)
}

// MARK: - DefaultSettingsWireframe

class DefaultSettingsWireframe {

    private weak var parent: UIViewController?

    private let interactor: SettingsInteractor

    init(
        parent: UIViewController,
        interactor: SettingsInteractor
    ) {
        self.parent = parent
        self.interactor = interactor
    }
}

// MARK: - SettingsWireframe

extension DefaultSettingsWireframe: SettingsWireframe {

    func present() {
        let vc = wireUp()

        if let tabVc = self.parent as? UITabBarController {
            let vcs = (tabVc.viewControllers ?? []) + [vc]
            tabVc.setViewControllers(vcs, animated: false)
            return
        }

        vc.show(vc, sender: self)
    }

    func navigate(to destination: SettingsWireframeDestination) {
        print("navigate to \(destination)")
    }
}

extension DefaultSettingsWireframe {

    private func wireUp() -> UIViewController {
        let vc: SettingsViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultSettingsPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
