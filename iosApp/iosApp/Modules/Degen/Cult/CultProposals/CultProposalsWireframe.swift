// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum CultProposalsWireframeDestination {
    
    case proposal(proposal: CultProposal, proposals: [CultProposal])
    case castVote(proposal: CultProposal, approve: Bool)
}

protocol CultProposalsWireframe {
    func present()
    func navigate(to destination: CultProposalsWireframeDestination)
}

final class DefaultCultProposalsWireframe {

    private weak var parent: UIViewController!
    private let cultProposalWireframeFactory: CultProposalWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let cultService: CultService

    private weak var vc: UIViewController!

    init(
        parent: UIViewController,
        cultProposalWireframeFactory: CultProposalWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        cultService: CultService
    ) {
        self.parent = parent
        self.cultProposalWireframeFactory = cultProposalWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.cultService = cultService
    }
}

extension DefaultCultProposalsWireframe: CultProposalsWireframe {

    func present() {
        
        let vc = wireUp()
        self.vc = vc
        parent.show(vc, sender: self)
    }

    func navigate(to destination: CultProposalsWireframeDestination) {

        switch destination {
            
        case let .proposal(proposal, proposals):
            
            cultProposalWireframeFactory.makeWireframe(
                parent: vc,
                context: .init(proposal: proposal, proposals: proposals)
            ).present()
            
        case let .castVote(proposal, approve):
            confirmationWireframeFactory.makeWireframe(
                presentingIn: vc,
                context: .init(
                    type: .cultCastVote(
                        .init(cultProposal: proposal, approve: approve)
                    )
                )
            ).present()
        }
    }
}

extension DefaultCultProposalsWireframe {

    private func wireUp() -> UIViewController {
        
        let vc: CultProposalsViewController = UIStoryboard(
            .cultProposals
        ).instantiate()
        
        let interactor = DefaultCultProposalsInteractor(
            cultService
        )
        
        let presenter = DefaultCultProposalsPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return vc
    }
}
