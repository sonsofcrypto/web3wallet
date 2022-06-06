// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum CultProposalsPresenterEvent {

}

protocol CultProposalsPresenter {

    func present()
    func handle(_ event: CultProposalsPresenterEvent)
}

// MARK: - DefaultCultProposalsPresenter

class DefaultCultProposalsPresenter {

    private let interactor: CultProposalsInteractor
    private let wireframe: CultProposalsWireframe

    private weak var view: CultProposalsView?

    init(
        view: CultProposalsView,
        interactor: CultProposalsInteractor,
        wireframe: CultProposalsWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

// MARK: TemplatePresenter

extension DefaultCultProposalsPresenter: CultProposalsPresenter {

    func present() {
        view?.update(
            with: viewModel(from: interactor.closedProposals())
        )
    }

    func handle(_ event: CultProposalsPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultCultProposalsPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultCultProposalsPresenter {

    func viewModel(from cultProposals: [CultProposal]) -> CultProposalsViewModel {
        .loaded(
            items: cultProposals.map { viewModel(from: $0) },
            selectedIdx: 0
        )
    }

    func viewModel(from cultProposal: CultProposal) -> CultProposalsViewModel.Item {
        let approved = Float.random(in: 0.0...100.0) / 100.0

        return CultProposalsViewModel.Item(
            title: String(format: "Proposal: %d %@", cultProposal.id, cultProposal.title),
            approved: approved,
            rejected: 1 - approved,
            date: cultProposal.endDate
        )
    }
}
