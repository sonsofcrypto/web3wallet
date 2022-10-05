// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit
import web3walletcore

enum ImprovementProposalPresenterEvent {
    case dismiss
    case vote(id: String)
}

protocol ImprovementProposalPresenter {
    func present()
    func handle(_ event: ImprovementProposalPresenterEvent)
}

final class DefaultImprovementProposalPresenter {
    private weak var view: ImprovementProposalView?
    private let wireframe: ImprovementProposalWireframe
    private let context: ImprovementProposalWireframeContext
    
    private var selected: ImprovementProposal!

    init(
        view: ImprovementProposalView,
        wireframe: ImprovementProposalWireframe,
        context: ImprovementProposalWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.context = context
        loadSelectedProposal()
    }
}

extension DefaultImprovementProposalPresenter: ImprovementProposalPresenter {

    func present() {
        view?.update(with: viewModel())
    }

    func handle(_ event: ImprovementProposalPresenterEvent) {
        switch event {
        case .dismiss: wireframe.navigate(to: .dismiss)
        case .vote: wireframe.navigate(to: .vote)
        }
    }
}

private extension DefaultImprovementProposalPresenter {
    
    func loadSelectedProposal() {
        selected = context.proposal
    }

    func viewModel() -> ImprovementProposalViewModel {
        let selectedIndex = context.proposals.firstIndex { $0.id == selected.id } ?? 0
        return .init(
            title: Localized("proposal.title"),
            details: details(),
            selectedIndex: selectedIndex
        )
    }
    
    func details() -> [ImprovementProposalViewModel.Details] {
        context.proposals.compactMap {
            .init(
                id: $0.id,
                name: $0.title,
                imageUrl: $0.imageUrl,
                status: .init(
                    title: $0.category.string
                        + " | "
                        + Localized("proposal.hashTag", arg: $0.id),
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
