// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum CultProposalsPresenterEvent {
    
    case filterBy(text: String)
    case approveProposal(id: String)
    case rejectProposal(id: String)
    case selectProposal(id: String)
}

protocol CultProposalsPresenter {

    func present()
    func handle(_ event: CultProposalsPresenterEvent)
}

final class DefaultCultProposalsPresenter {

    private let interactor: CultProposalsInteractor
    private let wireframe: CultProposalsWireframe

    private weak var view: CultProposalsView?
    
    private var pendingProposals = [CultProposal]()
    private var closedProposals = [CultProposal]()
    
    private var filterText: String = ""

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

extension DefaultCultProposalsPresenter: CultProposalsPresenter {

    func present() {
        
        pendingProposals = interactor.pendingProposals.sorted { $0.endDate < $1.endDate }
        closedProposals = interactor.closedProposals.sorted { $0.endDate > $1.endDate }
        updateView()
    }

    func handle(_ event: CultProposalsPresenterEvent) {
        
        switch event {
            
        case let .filterBy(text):
            
            self.filterText = text
            updateView()

        case let .selectProposal(id):
            
            guard let proposal = findProposal(with: id) else { return }
            
            wireframe.navigate(
                to: .proposal(
                    proposal: proposal,
                    proposals: pendingProposals + closedProposals
                )
            )
            
        case .approveProposal, .rejectProposal:
            
            wireframe.navigate(to: .comingSoon)
        }
    }
}

private extension DefaultCultProposalsPresenter {
    
    func updateView() {
        
        view?.update(
            with: viewModel()
        )
    }

    func viewModel() -> CultProposalsViewModel {
        
        let pendingProposals = interactor.pendingProposals.filter {
            [weak self] in
            guard let self = self else { return false }
            guard !self.filterText.isEmpty else { return true }
            return $0.title.contains(self.filterText)
        }.sorted { $0.endDate < $1.endDate }
        
        let closedProposals = interactor.closedProposals.filter {
            [weak self] in
            guard let self = self else { return false }
            guard !self.filterText.isEmpty else { return true }
            return $0.title.contains(self.filterText)
        }.sorted { $0.endDate > $1.endDate }
        
        return .loaded(
            sections: [
                .init(
                    title: Localized("cult.proposals.pending.title") + " (\(pendingProposals.count))",
                    type: .pending,
                    items: pendingProposals.compactMap { viewModel(from: $0) }
                ),
                .init(
                    title: Localized("cult.proposals.closed.title") + " (\(closedProposals.count))",
                    type: .closed,
                    items: closedProposals.compactMap { viewModel(from: $0) }
                )
            ]
        )
    }

    func viewModel(from cultProposal: CultProposal) -> CultProposalsViewModel.Item {
        
        let approved = cultProposal.approved / (cultProposal.approved + cultProposal.rejeceted)

        return .init(
            id: cultProposal.id.stringValue,
            title: cultProposal.title,
            approved: .init(
                name: Localized("approved"),
                value: approved,
                total: cultProposal.approved,
                type: .approved
            ),
            rejected: .init(
                name: Localized("rejected"),
                value: 1 - approved,
                total: cultProposal.rejeceted,
                type: .rejected
            ),
            approveButtonTitle: Localized("approve"),
            rejectButtonTitle: Localized("reject"),
            isNew: cultProposal.category.isNew,
            endDate: cultProposal.endDate
        )
    }
    
    func findProposal(with id: String) -> CultProposal? {
     
        if let proposal = closedProposals.first(where: { $0.id.stringValue == id }) {
            
            return proposal
        } else if let proposal = pendingProposals.first(where: { $0.id.stringValue == id }) {
            
            return proposal
        } else {
            
            return nil
        }
    }
}

private extension CultProposal.Category {
    
    var isNew: Bool {
        
        self == .new
    }
}
