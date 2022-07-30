// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum FeaturesPresenterEvent {
    
    case filterBySection(sectionType: FeaturesViewModel.Section.`Type`)
    case filterBy(text: String)
    case approve(id: String)
    case reject(id: String)
    case select(id: String)
}

protocol FeaturesPresenter {

    func present()
    func handle(_ event: FeaturesPresenterEvent)
}

final class DefaultFeaturesPresenter {

    private let interactor: FeaturesInteractor
    private let wireframe: FeaturesWireframe

    private weak var view: FeaturesView?
    
    private var allFeatures = [Web3Feature]()
    
    private var filterSectionType: FeaturesViewModel.Section.`Type` = .all
    private var filterText: String = ""

    init(
        view: FeaturesView,
        interactor: FeaturesInteractor,
        wireframe: FeaturesWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

extension DefaultFeaturesPresenter: FeaturesPresenter {

    func present() {
        
        if allFeatures.isEmpty {
            
            view?.update(with: .loading)
        }
        
        interactor.fetchAllFeatures { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case let .success(allFeatures):
                self.allFeatures = allFeatures
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

    func handle(_ event: FeaturesPresenterEvent) {
        
        switch event {
            
        case let .filterBySection(sectionType):
            
            self.filterSectionType = sectionType
            updateView()
            
        case let .filterBy(text):
            
            self.filterText = text
            updateView()

        case let .select(id):
            
            guard let feature = allFeatures.find(id: id) else { return }
                        
            wireframe.navigate(
                to: .feature(
                    feature: feature,
                    features: currentList
                )
            )
            
        case .approve, .reject:
            
            wireframe.navigate(to: .comingSoon)
        }
    }
}

private extension DefaultFeaturesPresenter {
    
    func updateView() {
        
        view?.update(
            with: viewModel()
        )
    }

    func viewModel() -> FeaturesViewModel {
        
        let featuresList = currentList.filter {
            [weak self] in
            guard let self = self else { return false }
            guard !self.filterText.isEmpty else { return true }
            return $0.title.contains(self.filterText)
        }.sorted { $0.id > $1.id }
        
        let section: FeaturesViewModel.Section = .init(
            title: filterSectionType.stringValue + " (\(featuresList.count))",
            type: filterSectionType,
            items: featuresList.compactMap { viewModel(from: $0) },
            footer: nil
        )
        return .loaded(
            sections: [section],
            selectedSectionType: filterSectionType
        )
    }

    func viewModel(from feature: Web3Feature) -> FeaturesViewModel.Item {
        
        let total = feature.approved + feature.rejeceted
        let approved = total == 0 ? 0 : feature.approved / total

        return .init(
            id: feature.id,
            title: feature.title,
            approved: .init(
                name: Localized("approved"),
                value: approved,
                total: feature.approved,
                type: .approved
            ),
            rejected: .init(
                name: Localized("rejected"),
                value: approved == 0 ? 0 : 1 - approved,
                total: feature.rejeceted,
                type: .rejected
            ),
            approveButtonTitle: Localized("approve"),
            rejectButtonTitle: Localized("reject"),
            category: filterSectionType == .all ? nil :  feature.category.stringValue
        )
    }
}

private extension DefaultFeaturesPresenter {
    
    var currentList: [Web3Feature] {
        
        switch filterSectionType {
        case .all: return allFeatures
        case .infrastructure: return allFeatures.infrastructure
        case .integrations: return allFeatures.integrations
        case .features: return allFeatures.features
        }
    }
}

extension Array where Element == Web3Feature {
    
    var integrations: [Web3Feature] {
        
        filter { $0.category == .integrations }
    }
    
    var infrastructure: [Web3Feature] {
        
        filter { $0.category == .infrastructure }
    }

    var features: [Web3Feature] {
        
        filter { $0.category == .features }
    }

    func find(id: String) -> Web3Feature? {
        
        filter { $0.id == id }.first
    }
    
    func filterTitle(by text: String) -> [Web3Feature] {
        
        filter { $0.title.contains(text) }
    }
}

extension Web3Feature.Category {
    
    var stringValue: String {
        
        switch self {
            
        case .infrastructure:
            return Localized("features.segmentedControl.infrastructure")
        case .integrations:
            return Localized("features.segmentedControl.integrations")
        case .features:
            return Localized("features.segmentedControl.infrastructure")
        }
    }
}
