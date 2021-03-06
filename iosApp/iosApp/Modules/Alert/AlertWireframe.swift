// Created by web3dgn on 02/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AlertWireframe {
    
    func present()
    func navigate(to destination: AlertWireframeDestination)
}

enum AlertWireframeDestination {
    
    case dismiss
}

final class DefaultAlertWireframe {

    private weak var parent: UIViewController!
    private let context: AlertContext
    
    private weak var vc: UIViewController!

    init(
        parent: UIViewController,
        context: AlertContext
    ) {
        self.parent = parent
        self.context = context
    }
}

extension DefaultAlertWireframe: AlertWireframe {

    func present() {
        
        let vc = makeViewController()
        self.vc = vc

        vc.modalPresentationStyle = .overCurrentContext
//        view.transitioningDelegate = CardFlipAnimatedTransitioning() as! UIViewControllerTransitioningDelegate

        parent.present(vc, animated: true)
    }
    
    func navigate(to destination: AlertWireframeDestination) {
        
        switch destination {
            
        case .dismiss:
            
            vc.navigationController?.dismiss(animated: true) ?? vc.dismiss(animated: true)
        }
    }
}

private extension DefaultAlertWireframe {

    func makeViewController() -> UIViewController {
        
        let presenter = DefaultAlertPresenter(
            context: context,
            wireframe: self
        )
        let view = DefaultAlertView(
            presenter: presenter
        )
        presenter.view = view
        return view
    }
}
