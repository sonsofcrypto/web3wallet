// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum CultProposalsPresenterEvent {
    
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
        
        view?.update(
            with: viewModel()
        )
    }

    func handle(_ event: CultProposalsPresenterEvent) {
        
        switch event {

        case let .selectProposal(id):
            
            guard let proposal = findProposal(with: id) else { return }
            
            wireframe.navigate(to: .proposal(proposal: proposal))
            
        case .approveProposal, .rejectProposal:
            
            wireframe.navigate(to: .comingSoon)
        }
    }
}

private extension DefaultCultProposalsPresenter {

    func viewModel() -> CultProposalsViewModel {
        
        pendingProposals = interactor.pendingProposals
        closedProposals = interactor.closedProposals
        
        return .loaded(
            sections: [
                .init(
                    title: "(\(pendingProposals.count)) " + Localized("cult.proposals.pending.title"),
                    horizontalScrolling: true,
                    items: pendingProposals.compactMap { viewModel(from: $0) }
                ),
                .init(
                    title: "(\(closedProposals.count)) " + Localized("cult.proposals.closed.title"),
                    horizontalScrolling: false,
                    items: closedProposals.compactMap { viewModel(from: $0) }
                )
            ]
        )
    }

    func viewModel(from cultProposal: CultProposal) -> CultProposalsViewModel.Item {
        
        let approved = Float.random(in: 0.0...100.0) / 100.0

        return .init(
            id: cultProposal.id.stringValue,
            title: String(format: "Proposal: %d %@", cultProposal.id, cultProposal.title),
            approved: .init(
                name: Localized("approved"),
                value: approved
            ),
            rejected: .init(
                name: Localized("rejected"),
                value: 1 - approved
            ),
            approveButtonTitle: Localized("approve"),
            rejectButtonTitle: Localized("reject"),
            isNew: cultProposal.isNew,
            date: cultProposal.endDate
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
