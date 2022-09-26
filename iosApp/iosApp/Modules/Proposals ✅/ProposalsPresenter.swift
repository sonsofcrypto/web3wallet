// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum ProposalsPresenterEvent {
    case didSelectCategory(idx: Int)
    case filterBy(text: String)
    case vote(idx: Int)
    case select(idx: Int)
    case dismiss
}

protocol ProposalsPresenter {

    func present()
    func handle(_ event: ProposalsPresenterEvent)
}

final class DefaultProposalsPresenter {
    private weak var view: ProposalsView?
    private let interactor: ProposalsInteractor
    private let wireframe: ProposalsWireframe

    private var proposals = [ImprovementProposal]()
    private var category: ImprovementProposal.Category = .infrastructure
    private var filterText: String = ""

    init(
        view: ProposalsView,
        interactor: ProposalsInteractor,
        wireframe: ProposalsWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

extension DefaultProposalsPresenter: ProposalsPresenter {

    func present() {
        if proposals.isEmpty { view?.update(with: .loading) }
        interactor.fetchAllFeatures { [weak self] result in
            switch result {
            case let .success(proposals):
                self?.proposals = proposals
                self?.updateView()
            case let .failure(error):
                // TODO: Error to be property and just call update view
                self?.view?.update(
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

    func handle(_ event: ProposalsPresenterEvent) {
        switch event {
        case let .didSelectCategory(idx):
            category = ImprovementProposal.Category.allCases[idx]
            updateView()
        case let .filterBy(text):
            filterText = text
            updateView()
        case let .select(idx):
            let proposals = currentProposals()
            wireframe.navigate(
                to: .proposal(proposal: proposals[idx], proposals: proposals)
            )
        case let .vote(idx):
            wireframe.navigate(to: .vote(proposal: currentProposals()[idx]))
        case .dismiss:
            wireframe.navigate(to: .dismiss)
        }
    }
}

private extension DefaultProposalsPresenter {
    
    func updateView() {
        view?.update(with: viewModel())
    }

    func viewModel() -> ProposalsViewModel {
        let proposals = currentProposals()
        let sectionType: ProposalsViewModel.Section.`Type` = .from(category)
        let section: ProposalsViewModel.Section = .init(
            title: sectionType.stringValue + " (\(proposals))",
            description: sectionType.descriptionValue,
            type: sectionType,
            items: proposals.compactMap { proposalViewModel(from: $0) },
            footer: nil
        )

        return .loaded(
            sections: [section],
            selectedSectionType: sectionType
        )
    }

    func proposalViewModel(from feature: ImprovementProposal) -> ProposalsViewModel.Item {
        .init(
            id: feature.id,
            title: feature.title,
            subtitle: proposalSubtitle(for: feature),
            buttonTitle: Localized("proposals.cell.button.vote")
        )
    }

    func proposalSubtitle(for feature: ImprovementProposal) -> String {
        feature.hashTag
            + "  |  "
            + Localized("proposals.cell.votes", arg: feature.votes.stringValue)
    }
}

private extension DefaultProposalsPresenter {

    func currentProposals() -> [ImprovementProposal] {
        proposals.filter { $0.category == category }
    }
}
