// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultImprovementProposalWireframe {
    private weak var parent: UIViewController?
    private let context: ImprovementProposalContext
    
    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: ImprovementProposalContext
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
        if let vote = destination_ as? ImprovementProposalsWireframeDestination.Vote {
            FeatureShareHelper().shareVote(on: vote.proposal)
        }
    }
    
    func dismiss() {
        vc?.popOrDismiss()
    }
}

private extension DefaultImprovementProposalWireframe {

    func wireUp() -> UIViewController {
        let vc: ImprovementProposalViewController = UIStoryboard(.improvementProposal).instantiate()
        let presenter = DefaultImprovementProposalPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            context: context
        )

        vc.presenter = presenter
        self.vc = vc
        return vc
    }
}
