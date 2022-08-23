// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum CultProposalsPresenterEvent {
    
    case filterBySection(sectionType: CultProposalsViewModel.Section.`Type`)
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
    
    private var filterSectionType: CultProposalsViewModel.Section.`Type` = .pending
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
        
        if pendingProposals.isEmpty && closedProposals.isEmpty {
            
            view?.update(with: .loading)
        }
        
        interactor.fetchProposals { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case let .success(proposals):
                self.prepareProposals(with: proposals)
                self.updateView()
                
            case let .failure(error):
                self.view?.update(
                    with: .error(
                        error: .init(
                            title: Localized("Error"),
                            body: error.localizedDescription,
                            actions: [
                                Localized("ok")
                            ]
                        )
                    )
                )
            }
        }
    }

    func handle(_ event: CultProposalsPresenterEvent) {
        
        switch event {
            
        case let .filterBySection(sectionType):
            
            self.filterSectionType = sectionType
            updateView()
            
        case let .filterBy(text):
            
            self.filterText = text
            updateView()

        case let .selectProposal(id):
            
            guard let proposal = findProposal(with: id) else { return }
            
            let proposals = filterSectionType == .pending ? pendingProposals : closedProposals
            
            wireframe.navigate(
                to: .proposal(
                    proposal: proposal,
                    proposals: proposals
                )
            )
            
        case let .approveProposal(id):
            interactor.castVote(id, support: true) { [weak self] result in
                // TODO(Sancho): Do nothing
            }
        case let .rejectProposal(id):
            interactor.castVote(id, support: false) { [weak self] result in
                // TODO(Sancho): error
            }
        }
    }
}

private extension DefaultCultProposalsPresenter {
    
    func prepareProposals(
        with proposals: [CultProposal]
    ) {
        
        pendingProposals = proposals.filter {
            $0.status == .pending
        }.sorted {
            $0.endDate < $1.endDate
        }
        closedProposals = proposals.filter {
            $0.status == .closed
        }.sorted {
            $0.endDate > $1.endDate
        }
        updateView()
    }
    
    func updateView() {
        
        view?.update(
            with: viewModel()
        )
    }

    func viewModel() -> CultProposalsViewModel {
        
        let pendingProposals = pendingProposals.filter {
            [weak self] in
            guard let self = self else { return false }
            guard !self.filterText.isEmpty else { return true }
            return $0.title.contains(self.filterText)
        }.sorted { $0.endDate < $1.endDate }
        
        let closedProposals = closedProposals.filter {
            [weak self] in
            guard let self = self else { return false }
            guard !self.filterText.isEmpty else { return true }
            return $0.title.contains(self.filterText)
        }.sorted { $0.endDate > $1.endDate }
        
        let pendingSection: CultProposalsViewModel.Section = .init(
            title: Localized("pending") + " (\(pendingProposals.count))",
            type: .pending,
            items: pendingProposals.compactMap { viewModel(from: $0) },
            footer: .init(
                imageName: "cult-dao-big-icon",
                text: Localized("cult.proposals.footer.text")
            )
        )
        let closedSection: CultProposalsViewModel.Section = .init(
            title: Localized("closed") + " (\(closedProposals.count))",
            type: .closed,
            items: closedProposals.compactMap { viewModel(from: $0) },
            footer: .init(
                imageName: "cult-dao-big-icon",
                text: Localized("cult.proposals.footer.text")
            )
        )
        
        let section: CultProposalsViewModel.Section
        switch filterSectionType {
        case .pending:
            section = pendingSection
        case .closed:
            section = closedSection
        }
        
        return .loaded(
            sections: [section],
            selectedSectionType: filterSectionType
        )
    }

    func viewModel(from cultProposal: CultProposal) -> CultProposalsViewModel.Item {
        
        let total = cultProposal.approved + cultProposal.rejeceted
        let approved = total == 0 ? 0 : cultProposal.approved / total

        return .init(
            id: cultProposal.id,
            title: cultProposal.title,
            approved: .init(
                name: Localized("approved"),
                value: approved,
                total: cultProposal.approved,
                type: .approved
            ),
            rejected: .init(
                name: Localized("rejected"),
                value: approved == 0 ? 0 : 1 - approved,
                total: cultProposal.rejeceted,
                type: .rejected
            ),
            approveButtonTitle: Localized("approve"),
            rejectButtonTitle: Localized("reject"),
            endDate: cultProposal.endDate
        )
    }
    
    func findProposal(with id: String) -> CultProposal? {
        if let proposal = closedProposals.first(where: { $0.id == id }) {
            return proposal
        } else if let proposal = pendingProposals.first(where: { $0.id == id }) {
            return proposal
        } else {
            return nil
        }
    }
}
