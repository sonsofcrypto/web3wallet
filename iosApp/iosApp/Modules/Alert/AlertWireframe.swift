// Created by web3dgn on 02/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultAlertWireframe {
    private weak var parent: UIViewController?
    private let context: AlertWireframeContext
    
    private weak var vc: UIViewController?

    init(
        parent: UIViewController?,
        context: AlertWireframeContext
    ) {
        self.parent = parent
        self.context = context
    }
}

extension DefaultAlertWireframe {

    func present() {
        let vc = makeViewController()
        parent?.present(vc, animated: true)
    }
    
    func navigate(to destination: AlertWireframeDestination) {
        if destination is AlertWireframeDestination.Dismiss {
            vc?.navigationController?.dismiss(animated: true) ?? vc?.dismiss(animated: true)
        }
    }
}

private extension DefaultAlertWireframe {

    func makeViewController() -> UIViewController {
        let vc: AlertViewController = UIStoryboard(.alert).instantiate()
        let presenter = DefaultAlertPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            context: context
        )
        vc.presenter = presenter
        vc.contentHeight = context.contentHeight
        let nc = NavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .custom
        nc.transitioningDelegate = vc
        self.vc = nc
        return nc
    }
}
