// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum KeyStoreWireframeDestination {
    case networks
}

protocol KeyStoreWireframe {
    func present()
    func navigate(to destination: KeyStoreWireframeDestination)
}

// MARK: - DefaultKeyStoreWireframe

class DefaultKeyStoreWireframe {

    private weak var parent: UIViewController?
    private weak var window: UIWindow?

    private let interactor: KeyStoreInteractor

    init(
        parent: UIViewController?,
        window: UIWindow?,
        interactor: KeyStoreInteractor
    ) {
        self.parent = parent
        self.window = window
        self.interactor = interactor
    }
}

// MARK: - KeyStoreWireframe

extension DefaultKeyStoreWireframe: KeyStoreWireframe {

    func present() {
        let vc = wireUp()

        if let window = self.window {
            window.rootViewController = vc
            window.makeKeyAndVisible()
            return
        }

        if let parent = self.parent as? EdgeCardsController {
            parent.setBottomCard(vc: vc)
        } else {
            parent?.show(vc, sender: self)
        }
    }

    func navigate(to destination: KeyStoreWireframeDestination) {
        if let parent = self.parent as? EdgeCardsController {
            switch destination {
            case .networks:
                parent.setDisplayMode(.overviewTopCard, animated: true)
            }
        }
        print("Failed to navigate to \(destination)")
    }
}

extension DefaultKeyStoreWireframe {

    private func wireUp() -> UIViewController {
        let vc: KeyStoreViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultKeyStorePresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
