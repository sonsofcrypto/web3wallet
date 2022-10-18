// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

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

    func navigate(destination_: ImprovementProposalWireframeDestination) {
        if let vote = destination_ as? ImprovementProposalWireframeDestination.Vote {
            FeatureShareHelper().shareVote(on: vote.proposal)
        }
        if (destination_ as? ImprovementProposalWireframeDestination.Dismiss) != nil {
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultImprovementProposalWireframe {

    func wireUp() -> UIViewController {
        let vc: ImprovementProposalViewController = UIStoryboard(.improvementProposal).instantiate()
        let presenter = DefaultImprovementProposalPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            proposal: context.proposal
        )

        vc.presenter = presenter
        self.vc = vc
        return vc
    }
}
