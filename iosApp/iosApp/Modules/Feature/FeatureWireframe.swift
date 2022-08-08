// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct FeatureWireframeContext {
    
    let feature: Web3Feature
    let features: [Web3Feature]
}

enum FeatureWireframeDestination {

    case vote
    case dismiss
}

protocol FeatureWireframe {
    func present()
    func navigate(to destination: FeatureWireframeDestination)
}

final class DefaultFeatureWireframe {

    private weak var parent: UIViewController!
    private let context: FeatureWireframeContext

    init(
        parent: UIViewController,
        context: FeatureWireframeContext
    ) {
        self.parent = parent
        self.context = context
    }
}

extension DefaultFeatureWireframe: FeatureWireframe {

    func present() {
        
        let vc = wireUp()
        parent.show(vc, sender: self)
    }

    func navigate(to destination: FeatureWireframeDestination) {

        switch destination {
            
        case .vote:
            
            FeatureShareHelper().shareVote(on: context.feature, presentingIn: parent)
            
        case .dismiss:
            
            if let navigationController = parent as? NavigationController {
                
                navigationController.popViewController(animated: true)
            } else {
            
                parent.navigationController?.popViewController(animated: true)
            }
        }
    }
}

private extension DefaultFeatureWireframe {

    func wireUp() -> UIViewController {
        
        let vc: FeatureViewController = UIStoryboard(.feature).instantiate()
        let presenter = DefaultFeaturePresenter(
            view: vc,
            wireframe: self,
            context: context
        )

        vc.presenter = presenter
        return vc
    }
}
