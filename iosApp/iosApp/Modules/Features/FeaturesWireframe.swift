// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum FeaturesWireframeDestination {
    
    case comingSoon
    case proposal(proposal: CultProposal, proposals: [CultProposal])
}

protocol FeaturesWireframe {
    func present()
    func navigate(to destination: FeaturesWireframeDestination)
}

final class DefaultFeaturesWireframe {

    private weak var parent: UIViewController!
    private let cultProposalWireframeFactory: CultProposalWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let cultService: CultService

    private weak var vc: UIViewController!

    init(
        parent: UIViewController,
        cultProposalWireframeFactory: CultProposalWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        cultService: CultService
    ) {
        self.parent = parent
        self.cultProposalWireframeFactory = cultProposalWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.cultService = cultService
    }
}

extension DefaultFeaturesWireframe: FeaturesWireframe {

    func present() {
        
        let vc = wireUp()
        self.vc = vc
        parent.show(vc, sender: self)
    }

    func navigate(to destination: FeaturesWireframeDestination) {

        switch destination {
            
        case let .proposal(proposal, proposals):
            
            cultProposalWireframeFactory.makeWireframe(
                parent: vc,
                context: .init(proposal: proposal, proposals: proposals)
            ).present()
            
        case .comingSoon:
            
            alertWireframeFactory.makeWireframe(
                vc,
                context: .underConstructionAlert()
            ).present()
        }
    }
}

extension DefaultFeaturesWireframe {

    private func wireUp() -> UIViewController {
        
        let vc: FeaturesViewController = UIStoryboard(
            .features
        ).instantiate()
        
        let interactor = DefaultFeaturesInteractor(
            cultService
        )
        
        let presenter = DefaultFeaturesPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return vc
    }
}
