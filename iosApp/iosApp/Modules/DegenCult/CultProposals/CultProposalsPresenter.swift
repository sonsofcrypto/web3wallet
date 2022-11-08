// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

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
    private weak var view: CultProposalsView?
    private let wireframe: CultProposalsWireframe
    private let interactor: CultProposalsInteractor
    
    private var pendingProposals = [CultProposal]()
    private var closedProposals = [CultProposal]()
    private var filterSectionType: CultProposalsViewModel.Section.`Type` = .pending
    private var filterText: String = ""

    init(
        view: CultProposalsView,
        wireframe: CultProposalsWireframe,
        interactor: CultProposalsInteractor
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
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
            filterSectionType = sectionType
            updateView()
        case let .filterBy(text):
            filterText = text
            updateView()
        case let .selectProposal(id):
            guard let proposal = findProposal(with: id) else { return }
            let proposals = filterSectionType == .pending ? pendingProposals : closedProposals
            wireframe.navigate(to: .proposal(proposal: proposal, proposals: proposals))
        case let .approveProposal(id):
            castVote(proposalId: id, approve: true)
        case let .rejectProposal(id):
            castVote(proposalId: id, approve: false)
        }
    }
}

private extension DefaultCultProposalsPresenter {
    
    func prepareProposals(with proposals: CultProposalsResponse) {
        pendingProposals = proposals.pending.sorted { $0.endDate > $1.endDate }
        closedProposals = proposals.closed.sorted { $0.endDate > $1.endDate }
        updateView()
    }
    
    func updateView() {
        view?.update(with: viewModel())
    }

    func viewModel() -> CultProposalsViewModel {
        let pendingProposals = pendingProposals.filter {
            [weak self] in
            guard let self = self else { return false }
            guard !self.filterText.isEmpty else { return true }
            return $0.title.contains(self.filterText)
        }.sorted { $0.endDate > $1.endDate }
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
        let total = cultProposal.approved + cultProposal.rejected
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
                total: cultProposal.rejected,
                type: .rejected
            ),
            approveButtonTitle: Localized("approve"),
            rejectButtonTitle: Localized("reject"),
            endDate: cultProposal.endDate,
            stateName: cultProposal.stateName
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
    
    func castVote(proposalId id: String, approve: Bool) {
        guard interactor.hasCultBalance else {
            wireframe.navigate(to: .alert(context: noCultAlertContext()))
            return
        }
        guard let proposal = findProposal(with: id) else { return }
        wireframe.navigate(to: .castVote(proposal: proposal, approve: approve))
    }
    
    func noCultAlertContext() -> AlertWireframeContext {
        AlertWireframeContext(
            title: Localized("cult.proposals.alert.noCult.title"),
            media: AlertWireframeContext.MediaImage(named: "cult-dao-big-icon", width: 100, height: 100),
            message: Localized("cult.proposals.alert.noCult.message"),
            actions: [
                AlertWireframeContext.Action(
                    title: Localized("cult.proposals.alert.noCult.action.getCult"),
                    type: .primary
                ),
                AlertWireframeContext.Action(
                    title: Localized("cancel"),
                    type: .secondary
                )
            ],
            onActionTapped: { [weak self] idx in
                if (idx == 0) { self?.getCultTapped() }
            },
            contentHeight: 385
        )
    }
    
    func getCultTapped() {
        view?.dismiss(
            animated: true,
            completion: { [weak self] in
                guard let self = self else { return }
                self.wireframe.navigate(to: .getCult)
            }
        )
    }
}
