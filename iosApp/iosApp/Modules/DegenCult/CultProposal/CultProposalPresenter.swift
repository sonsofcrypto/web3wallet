// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit
import web3walletcore

enum CultProposalPresenterEvent {
    case dismiss
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
        switch event {
        case .dismiss:
            wireframe.navigate(to: .dismiss)
        }
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
                status: .init(
                    title: $0.stateName.uppercased(),
                    color: statusColor(from: $0)
                ),
                guardianInfo: guardianInfo(from: $0),
                summary: .init(
                    title: Localized("cult.proposal.summary.header"),
                    summary: $0.projectSummary
                ),
                documentsInfo: .init(
                    title: Localized("cult.proposal.docs.header"),
                    documents: documents(from: $0.projectDocuments)
                ),
                tokenomics: .init(
                    title: Localized("cult.proposal.tokenomics.header"),
                    rewardAllocation: Localized("cult.proposal.tokenomics.rewardAllocation"),
                    rewardAllocationValue: $0.cultReward,
                    rewardDistribution: Localized("cult.proposal.tokenomics.rewardDistribution"),
                    rewardDistributionValue: $0.rewardDistributions,
                    projectETHWallet: Localized("cult.proposal.tokenomics.projectEthWallet"),
                    projectETHWalletValue: $0.wallet
                )
            )
        }
    }
    
    func statusColor(from proposal: CultProposal) -> UIColor {
        switch proposal.status {
        case .pending: return Theme.colour.navBarTint
        case .closed: return Theme.colour.separator
        default: return Theme.colour.separator
        }
    }
    
    func guardianInfo(from proposal: CultProposal) -> CultProposalViewModel.ProposalDetails.GuardianInfo? {
        guard let guardianInfo = proposal.guardianInfo else { return nil }
        return .init(
            title: Localized("cult.proposal.guardian.header"),
            name: Localized("cult.proposal.guardian.name"),
            nameValue: guardianInfo.proposal,
            socialHandle: Localized("cult.proposal.guardian.discordHandle"),
            socialHandleValue: guardianInfo.discord,
            wallet: Localized("cult.proposal.guardian.wallet"),
            walletValue: guardianInfo.address
        )
    }
    
    func documents(
        from projectDocuments: [CultProposal.ProjectDocuments]
    ) -> [CultProposalViewModel.ProposalDetails.DocumentsInfo.Document] {
        projectDocuments.compactMap {
            .init(
                title: $0.name,
                items: $0.documents.compactMap {documentItem(from: $0)}
            )
        }
    }
    
    func documentItem(
        from document: CultProposal.ProjectDocumentsDocument
    ) -> CultProposalViewModel.ProposalDetails.DocumentsInfo.Document.Item {
        if let link = document as? CultProposal.ProjectDocumentsDocumentLink {
            return .link(displayName: link.displayName, url: link.url)
        }
        if let note = document as? CultProposal.ProjectDocumentsDocumentNote {
            return .note(note.note)
        }
        fatalError("Type not handled.")
    }
}
