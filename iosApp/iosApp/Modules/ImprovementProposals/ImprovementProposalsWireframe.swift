// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum ImprovementProposalsWireframeDestination {
    case vote(proposal: ImprovementProposal)
    case proposal(proposal: ImprovementProposal, proposals: [ImprovementProposal])
    case dismiss
}

protocol ImprovementProposalsWireframe {
    func present()
    func navigate(to destination: ImprovementProposalsWireframeDestination)
}

final class DefaultImprovementProposalsWireframe {

    private weak var parent: UIViewController?
    private let featureWireframeFactory: ImprovementProposalWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let improvementProposalsService: ImprovementProposalsService

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        featureWireframeFactory: ImprovementProposalWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        improvementProposalsService: ImprovementProposalsService
    ) {
        self.parent = parent
        self.featureWireframeFactory = featureWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.improvementProposalsService = improvementProposalsService
    }
}

extension DefaultImprovementProposalsWireframe: ImprovementProposalsWireframe {

    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }

    func navigate(to destination: ImprovementProposalsWireframeDestination) {
        switch destination {
        case let .vote(proposal):
            FeatureShareHelper().shareVote(on: proposal)
        case let .proposal(proposal, proposals):
            featureWireframeFactory.make(
                vc,
                context: .init(proposal: proposal, proposals: proposals)
            ).present()
        case .dismiss:
            vc?.popOrDismiss()
        }
    }
}

extension DefaultImprovementProposalsWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultImprovementProposalsInteractor(
            improvementProposalsService: improvementProposalsService
        )
        let vc: ImprovementProposalsViewController = UIStoryboard(.improvementProposals).instantiate()
        let presenter = DefaultImprovementProposalsPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )
        vc.presenter = presenter
        self.vc = vc
        guard parent?.asNavigationController == nil else { return vc }
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
}
