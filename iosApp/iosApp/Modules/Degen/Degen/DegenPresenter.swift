// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

enum DegenPresenterEvent {
    case didSelectCategory(idx: Int)
    case comingSoon
}

protocol DegenPresenter {

    func present()
    func handle(_ event: DegenPresenterEvent)
}

final class DefaultDegenPresenter {

    private let interactor: DegenInteractor
    private let wireframe: DegenWireframe

    private weak var view: DegenView?

    init(
        view: DegenView,
        interactor: DegenInteractor,
        wireframe: DegenWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

extension DefaultDegenPresenter: DegenPresenter {

    func present() {
        
        view?.update(
            with: viewModel()
        )
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

private extension DefaultDegenPresenter {

    func handleDidSelectCategory(at idx: Int) {
        switch idx {
        case 0:
            wireframe.navigate(to: .swap)
        case 1:
            wireframe.navigate(to: .cult)
        default:
            print("DefaultDegenPresenter unknown category index", idx)
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
                    items: makeItems(
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
                    items: makeItems(
                        from: interactor.categoriesInactive,
                        isEnabled: false
                    )
                )
            ]
        )
    }
    
    func makeItems(
        from categories: [DAppCategory],
        isEnabled: Bool
    ) -> [DegenViewModel.Item] {
        
        categories.compactMap {
            
            .init(
                icon: makeIcon(from: $0),
                title: $0.title,
                subtitle: $0.subTitle,
                isEnabled: isEnabled
            )
        }
    }
    
    func makeIcon(from category: DAppCategory) -> Data {
        
        let config = UIImage.SymbolConfiguration(
            paletteColors: [
                Theme.colour.labelPrimary,
                .clear
            ]
        )

        switch category {
        case .swap:
            return UIImage(named: "degen-trade-icon")!.pngData()!
        case .cult:
            return UIImage(named: "degen-cult-icon")!.pngData()!
        case .stakeYield:
            return UIImage(systemName: "s.circle.fill")!
                .applyingSymbolConfiguration(config)!
                .pngData()!
        case .landBorrow:
            return UIImage(systemName: "l.circle.fill")!
                .applyingSymbolConfiguration(config)!
                .pngData()!

        case .derivative:
            return UIImage(systemName: "d.circle.fill")!
                .applyingSymbolConfiguration(config)!
                .pngData()!

        case .bridge:
            return UIImage(systemName: "b.circle.fill")!
                .applyingSymbolConfiguration(config)!
                .pngData()!

        case .mixer:
            return UIImage(systemName: "m.circle.fill")!
                .applyingSymbolConfiguration(config)!
                .pngData()!

        case .governance:
            return UIImage(systemName: "g.circle.fill")!
                .applyingSymbolConfiguration(config)!
                .pngData()!

        }
    }
}
