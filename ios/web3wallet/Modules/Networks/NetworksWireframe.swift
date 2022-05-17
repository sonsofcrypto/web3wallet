// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum NetworksWireframeDestination {
    case dashboard
}

protocol NetworksWireframe {
    func present()
    func navigate(to destination: NetworksWireframeDestination)
}

// MARK: - DefaultNetworksWireframe

final class DefaultNetworksWireframe {

    private weak var parent: UIViewController?

    private let interactor: NetworksInteractor

    init(
        parent: UIViewController?,
        interactor: NetworksInteractor
    ) {
        self.interactor = interactor
        self.parent = parent
    }
}

// MARK: - NetworksWireframe

extension DefaultNetworksWireframe: NetworksWireframe {

    func present() {
        let vc = wireUp()
        if let parent = self.parent as? EdgeCardsController {
            parent.setTopCard(vc: vc)
        } else {
            parent?.show(vc, sender: self)
        }
    }

    func navigate(to destination: NetworksWireframeDestination) {
        if let parent = self.parent as? EdgeCardsController {
            switch destination {
            case .dashboard:
                parent.setDisplayMode(.master, animated: true)
            }
            return
        }
        print("Failed to navigate to \(destination)")
    }
}

extension DefaultNetworksWireframe {

    private func wireUp() -> UIViewController {
        let vc: NetworksViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultNetworksPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
