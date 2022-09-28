// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct ProposalWireframeContext {    
    let proposal: ImprovementProposal
    let proposals: [ImprovementProposal]
}

enum ProposalWireframeDestination {
    case vote
    case dismiss
}

protocol ProposalWireframe {
    func present()
    func navigate(to destination: ProposalWireframeDestination)
}

final class DefaultProposalWireframe {
    private weak var parent: UIViewController?
    private let context: ProposalWireframeContext
    
    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: ProposalWireframeContext
    ) {
        self.parent = parent
        self.context = context
    }
}

extension DefaultProposalWireframe: ProposalWireframe {

    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }

    func navigate(to destination: ProposalWireframeDestination) {
        switch destination {
        case .vote:
            FeatureShareHelper().shareVote(on: context.proposal)
        case .dismiss:
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultProposalWireframe {

    func wireUp() -> UIViewController {
        let vc: ProposalViewController = UIStoryboard(.proposal).instantiate()
        let presenter = DefaultProposalPresenter(
            view: vc,
            wireframe: self,
            context: context
        )

        vc.presenter = presenter
        self.vc = vc
        return vc
    }
}
