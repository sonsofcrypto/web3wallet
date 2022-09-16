// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

enum FeaturePresenterEvent {
    case dismiss
    case vote(id: String)
}

protocol FeaturePresenter {
    func present()
    func handle(_ event: FeaturePresenterEvent)
}

final class DefaultFeaturePresenter {
    private weak var view: FeatureView?
    private let wireframe: FeatureWireframe
    private let context: FeatureWireframeContext
    
    private var selected: Web3Feature!

    init(
        view: FeatureView,
        wireframe: FeatureWireframe,
        context: FeatureWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.context = context
        
        loadSelectedProposal()
    }
}

extension DefaultFeaturePresenter: FeaturePresenter {

    func present() {
        view?.update(with: viewModel())
    }

    func handle(_ event: FeaturePresenterEvent) {
        switch event {
        case .dismiss:
            wireframe.navigate(to: .dismiss)
        case .vote:
            wireframe.navigate(to: .vote)
        }
    }
}

private extension DefaultFeaturePresenter {
    
    func loadSelectedProposal() {
        selected = context.feature
    }

    func viewModel() -> FeatureViewModel {
        let selectedIndex = context.features.firstIndex {
            $0.id == selected.id
        } ?? 0
        return .init(
            title: Localized("feature.title"),
            details: makeDetails(),
            selectedIndex: selectedIndex
        )
    }
    
    func makeDetails() -> [FeatureViewModel.Details] {
        context.features.compactMap {
            .init(
                id: $0.id,
                name: $0.title,
                imageUrl: $0.imageUrl,
                status: .init(
                    title: $0.category.stringValue + " | " + $0.hashTag,
                    color: Theme.colour.navBarTint
                ),
                summary: .init(
                    title: Localized("feature.summary.header"),
                    summary: $0.body
                ),
                voteButton: Localized("feature.button.vote")
            )
        }
    }
}
