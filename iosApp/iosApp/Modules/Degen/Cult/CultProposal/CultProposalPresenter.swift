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

final class DefaultCultProposalPresenter {

    private weak var view: CultProposalView?
    private let wireframe: CultProposalWireframe
    private let context: CultProposalWireframeContext
    
    private var selectedProposal: CultProposal!

    init(
        view: CultProposalView,
        wireframe: CultProposalWireframe,
        context: CultProposalWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.context = context
        
        loadSelectedProposal()
    }
}

extension DefaultCultProposalPresenter: CultProposalPresenter {

    func present() {
        
        view?.update(with: viewModel())
    }

    func handle(_ event: CultProposalPresenterEvent) {

    }
}

private extension DefaultCultProposalPresenter {
    
    func loadSelectedProposal() {
        
        selectedProposal = context.proposal
    }

    func viewModel() -> CultProposalViewModel {
        
        let selectedIndex = context.proposals.firstIndex {
            $0.id == selectedProposal.id
        } ?? 0
        
        return .init(
            title: Localized("cult.proposal.title"),
            proposals: makeProposals(),
            selectedIndex: selectedIndex
        )
    }
    
    func makeProposals() -> [CultProposalViewModel.ProposalDetails] {
        
        context.proposals.compactMap {
            
            .init(
                name: $0.title,
                guardianInfo: .init(
                    name: $0.guardianName,
                    socialHandle: $0.guardianSocial,
                    wallet: $0.guardianWallet
                ),
                summary: $0.projectSummary,
                documents: makeDocuments(
                    from: $0.projectDocuments
                ),
                rewardAllocation: $0.cultReward,
                rewardDistribution: $0.rewardDistributions,
                projectETHWallet: $0.wallet
            )
        }
    }
    
    func makeDocuments(
        from projectDocuments: [CultProposal.ProjectDocuments]
    ) -> [CultProposalViewModel.ProposalDetails.DocumentsInfo] {
        
        projectDocuments.compactMap {
            .init(
                name: $0.name,
                note: $0.note,
                documents: $0.documents.compactMap {
                    .init(displayName: $0.displayName, url: $0.url)
                }
            )
        }
    }
}
