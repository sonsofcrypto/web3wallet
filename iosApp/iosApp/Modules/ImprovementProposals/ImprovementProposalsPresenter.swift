// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum ImprovementProposalsPresenterEvent {
    case didSelectCategory(idx: Int)
    case filterBy(text: String)
    case vote(idx: Int)
    case select(idx: Int)
    case dismiss
}

protocol ImprovementProposalsPresenter {

    func present()
    func handle(_ event: ImprovementProposalsPresenterEvent)
}

final class DefaultImprovementProposalsPresenter {
    private weak var view: ImprovementProposalsView?
    private let interactor: ImprovementProposalsInteractor
    private let wireframe: ImprovementProposalsWireframe

    private var proposals = [ImprovementProposal]()
    private var category: ImprovementProposal.Category = .infrastructure
    private var filterText: String = ""

    init(
        view: ImprovementProposalsView,
        interactor: ImprovementProposalsInteractor,
        wireframe: ImprovementProposalsWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

extension DefaultImprovementProposalsPresenter: ImprovementProposalsPresenter {

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

    func handle(_ event: ImprovementProposalsPresenterEvent) {
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

private extension DefaultImprovementProposalsPresenter {
    
    func updateView() {
        view?.update(with: viewModel())
    }

    func viewModel() -> ImprovementProposalsViewModel {
        let proposals = currentProposals()
        let sectionType: ImprovementProposalsViewModel.Section.`Type` = .from(category)
        let section: ImprovementProposalsViewModel.Section = .init(
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

    func proposalViewModel(from feature: ImprovementProposal) -> ImprovementProposalsViewModel.Item {
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

private extension DefaultImprovementProposalsPresenter {

    func currentProposals() -> [ImprovementProposal] {
        proposals.filter { $0.category == category }
    }
}
