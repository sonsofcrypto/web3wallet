// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct ImprovementProposalWireframeContext {
    let proposal: ImprovementProposal
    let proposals: [ImprovementProposal]
}

enum ImprovementProposalWireframeDestination {
    case vote
    case dismiss
}

protocol ImprovementProposalWireframe {
    func present()
    func navigate(to destination: ImprovementProposalWireframeDestination)
}

final class DefaultImprovementProposalWireframe {
    private weak var parent: UIViewController?
    private let context: ImprovementProposalWireframeContext
    
    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: ImprovementProposalWireframeContext
    ) {
        self.parent = parent
        self.context = context
    }
}

extension DefaultImprovementProposalWireframe: ImprovementProposalWireframe {

    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }

    func navigate(to destination: ImprovementProposalWireframeDestination) {
        switch destination {
        case .vote:
            FeatureShareHelper().shareVote(on: context.proposal)
        case .dismiss:
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultImprovementProposalWireframe {

    func wireUp() -> UIViewController {
        let vc: ImprovementProposalViewController = UIStoryboard(.improvementProposal).instantiate()
        let presenter = DefaultImprovementProposalPresenter(
            view: vc,
            wireframe: self,
            context: context
        )

        vc.presenter = presenter
        self.vc = vc
        return vc
    }
}
