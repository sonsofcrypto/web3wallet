// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

enum ProposalPresenterEvent {
    case dismiss
    case vote(id: String)
}

protocol ProposalPresenter {
    func present()
    func handle(_ event: ProposalPresenterEvent)
}

final class DefaultProposalPresenter {
    private weak var view: ProposalView?
    private let wireframe: ProposalWireframe
    private let context: ProposalWireframeContext
    
    private var selected: ImprovementProposal!

    init(
        view: ProposalView,
        wireframe: ProposalWireframe,
        context: ProposalWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.context = context
        loadSelectedProposal()
    }
}

extension DefaultProposalPresenter: ProposalPresenter {

    func present() {
        view?.update(with: viewModel())
    }

    func handle(_ event: ProposalPresenterEvent) {
        switch event {
        case .dismiss: wireframe.navigate(to: .dismiss)
        case .vote: wireframe.navigate(to: .vote)
        }
    }
}

private extension DefaultProposalPresenter {
    
    func loadSelectedProposal() {
        selected = context.proposal
    }

    func viewModel() -> ProposalViewModel {
        let selectedIndex = context.proposals.firstIndex { $0.id == selected.id } ?? 0
        return .init(
            title: Localized("proposal.title"),
            details: details(),
            selectedIndex: selectedIndex
        )
    }
    
    func details() -> [ProposalViewModel.Details] {
        context.proposals.compactMap {
            .init(
                id: $0.id,
                name: $0.title,
                imageUrl: $0.imageUrl,
                status: .init(
                    title: $0.category.stringValue + " | " + $0.hashTag,
                    color: Theme.colour.navBarTint
                ),
                summary: .init(
                    title: Localized("proposal.summary.header"),
                    summary: $0.body
                ),
                voteButton: Localized("proposal.button.vote")
            )
        }
    }
}
