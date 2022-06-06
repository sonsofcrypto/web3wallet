// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum CultProposalPresenterEvent {

}

protocol CultProposalPresenter {

    func present()
    func handle(_ event: CultProposalPresenterEvent)
}

// MARK: - DefaultCultProposalPresenter

class DefaultCultProposalPresenter {

    private let wireframe: CultProposalWireframe

    private var proposal: CultProposal

    private weak var view: CultProposalView?

    init(
        proposal: CultProposal,
        view: CultProposalView,
        wireframe: CultProposalWireframe
    ) {
        self.view = view
        self.wireframe = wireframe
        self.proposal = proposal
    }
}

// MARK: CultProposalPresenter

extension DefaultCultProposalPresenter: CultProposalPresenter {

    func present() {
        view?.update(with: viewModel(proposal))
    }

    func handle(_ event: CultProposalPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultCultProposalPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultCultProposalPresenter {

    func viewModel(_ proposal: CultProposal) -> CultProposalViewModel {
        .init(proposal)
    }
}
