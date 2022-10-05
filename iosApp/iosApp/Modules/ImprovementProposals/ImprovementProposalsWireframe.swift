// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultImprovementProposalsWireframe {
    private weak var parent: UIViewController?
    private let improvementProposalWireframeFactory: ImprovementProposalWireframeFactory
    private let improvementProposalsService: ImprovementProposalsService
    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        improvementProposalWireframeFactory: ImprovementProposalWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        improvementProposalsService: ImprovementProposalsService
    ) {
        self.parent = parent
        self.improvementProposalWireframeFactory = improvementProposalWireframeFactory
        self.improvementProposalsService = improvementProposalsService
    }
}

extension DefaultImprovementProposalsWireframe: ImprovementProposalsWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc
        parent?.show(vc, sender: self)
    }

    func navigate(destination: ImprovementProposalsWireframeDestination) {
//         TODO(PROPOSALS)
//        switch destination {
//        case let .vote(proposal):
//            FeatureShareHelper().shareVote(on: proposal)
//        case let .proposal(proposal, proposals):
//            improvementWireframeFactory.make(
//                vc,
//                context: .init(proposal: proposal, proposals: proposals)
//            ).present()
//        case .dismiss:
//            vc?.popOrDismiss()
//        }
    }
}

extension DefaultImprovementProposalsWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultImprovementProposalsInteractor(
            improvementProposalsService: improvementProposalsService
        )
        let vc: ImprovementProposalsViewController = UIStoryboard(.improvementProposals).instantiate()
        let presenter = DefaultImprovementProposalsPresenter(
            view: WeakRef(referred: vc),
            interactor: interactor,
            wireframe: self
        )
        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
