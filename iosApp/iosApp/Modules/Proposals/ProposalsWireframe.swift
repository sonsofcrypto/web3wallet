// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum ProposalsWireframeDestination {
    case vote(proposal: ImprovementProposal)
    case proposal(proposal: ImprovementProposal, proposals: [ImprovementProposal])
    case dismiss
}

protocol ProposalsWireframe {
    func present()
    func navigate(to destination: ProposalsWireframeDestination)
}

final class DefaultProposalsWireframe {

    private weak var parent: UIViewController?
    private let featureWireframeFactory: FeatureWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let improvementProposalsService: ImprovementProposalsService

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        featureWireframeFactory: FeatureWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        improvementProposalsService: ImprovementProposalsService
    ) {
        self.parent = parent
        self.featureWireframeFactory = featureWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.improvementProposalsService = improvementProposalsService
    }
}

extension DefaultProposalsWireframe: ProposalsWireframe {

    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }

    func navigate(to destination: ProposalsWireframeDestination) {
        switch destination {
        case let .vote(proposal):
            FeatureShareHelper().shareVote(on: proposal)
        case let .proposal(proposal, proposals):
            featureWireframeFactory.make(
                vc,
                context: .init(feature: proposal, features: proposals)
            ).present()
        case .dismiss:
            vc?.popOrDismiss()
        }
    }
}

extension DefaultProposalsWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultProposalsInteractor(
            improvementProposalsService: improvementProposalsService
        )
        let vc: ProposalsViewController = UIStoryboard(.proposals).instantiate()
        let presenter = DefaultProposalsPresenter(
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
