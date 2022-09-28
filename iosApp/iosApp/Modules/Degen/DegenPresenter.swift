// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit
import web3lib

enum DegenPresenterEvent {
    case didSelectCategory(idx: Int)
    case comingSoon
}

protocol DegenPresenter {
    func present()
    func handle(_ event: DegenPresenterEvent)
}

final class DefaultDegenPresenter {
    private weak var view: DegenView?
    private let interactor: DegenInteractor
    private let wireframe: DegenWireframe

    init(
        view: DegenView,
        interactor: DegenInteractor,
        wireframe: DegenWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        interactor.addListener(self)
    }
    
    deinit {
        print("[DEBUG][Presenter] deinit \(String(describing: self))")
        interactor.removeListener(self)
    }
}

extension DefaultDegenPresenter: DegenPresenter {

    func present() {
        view?.update(with: viewModel())
    }

    func handle(_ event: DegenPresenterEvent) {
        switch event {
        case let .didSelectCategory(idx):
            handleDidSelectCategory(at: idx)
        case .comingSoon:
            wireframe.navigate(to: .comingSoon)
        }
    }
}

extension DefaultDegenPresenter: DegenInteractorLister {

    func handle(networkEvent event: NetworksEvent) {
        guard event is NetworksEvent.NetworkDidChange else { return }
        view?.popToRootAndRefresh()
    }
}


private extension DefaultDegenPresenter {

    func handleDidSelectCategory(at idx: Int) {
        switch idx {
        case 0: wireframe.navigate(to: .swap)
        case 1: wireframe.navigate(to: .cult)
        default: print("DefaultDegenPresenter unknown category index", idx)
        }
    }
}

private extension DefaultDegenPresenter {

    func viewModel() -> DegenViewModel {
        .init(
            sections: [
                .header(
                    header: .init(
                        title: Localized("degen.section.title"),
                        isEnabled: true
                    )
                ),
                .group(
                    items: itemsViewModel(
                        from: interactor.categoriesActive,
                        isEnabled: true
                    )
                ),
                .header(
                    header: .init(
                        title: Localized("comingSoon"),
                        isEnabled: false
                    )
                ),
                .group(
                    items: itemsViewModel(
                        from: interactor.categoriesInactive,
                        isEnabled: false
                    )
                )
            ]
        )
    }
    
    func itemsViewModel(
        from categories: [DAppCategory],
        isEnabled: Bool
    ) -> [DegenViewModel.Item] {
        categories.compactMap {
            .init(
                iconName: iconViewModel(from: $0),
                title: $0.title,
                subtitle: $0.subTitle,
                isEnabled: isEnabled
            )
        }
    }
    
    func iconViewModel(from category: DAppCategory) -> String {
        // TODO: Review this images...
        switch category {
        case .swap: return "degen-trade-icon"
        case .cult: return "degen-cult-icon"
        case .stakeYield: return "s.circle.fill"
        case .landBorrow: return "l.circle.fill"
        case .derivative: return "d.circle.fill"
        case .bridge: return "b.circle.fill"
        case .mixer: return "m.circle.fill"
        case .governance: return "g.circle.fill"
        }
    }
}
