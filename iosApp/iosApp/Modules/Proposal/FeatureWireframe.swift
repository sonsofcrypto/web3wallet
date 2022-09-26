// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct FeatureWireframeContext {    
    let feature: ImprovementProposal
    let features: [ImprovementProposal]
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
    private weak var parent: UIViewController?
    private let context: FeatureWireframeContext
    
    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: FeatureWireframeContext
    ) {
        self.parent = parent
        self.context = context
    }
}

extension DefaultFeatureWireframe: FeatureWireframe {

    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }

    func navigate(to destination: FeatureWireframeDestination) {
        switch destination {
        case .vote:
            FeatureShareHelper().shareVote(on: context.feature)
        case .dismiss:
            vc?.popOrDismiss()
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
        self.vc = vc
        return vc
    }
}
