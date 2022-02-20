// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct DegenViewModel {
    let sectionTitle: String
    let items: [Item]
}

// MARK - Item

extension DegenViewModel {

    struct Item {
        let title: String
        let subtitle: String
    }
}

// MARK: - DAppCategory

extension DAppCategory {

    var title: String {
        switch self {
        case .amm:
            return Localized("degen.dappCategory.title.amm")
        case .stakeYield:
            return Localized("degen.dappCategory.title.stakeYield")
        case .landBorrow:
            return Localized("degen.dappCategory.title.landBorrow")
        case .derivative:
            return Localized("degen.dappCategory.title.derivative")
        case .bridge:
            return Localized("degen.dappCategory.title.bridge")
        case .mixer:
            return Localized("degen.dappCategory.title.mixer")
        case .governance:
            return Localized("degen.dappCategory.title.governance")
        }
    }

    var subTitle: String {

        switch self {
        case .amm:
            return Localized("degen.dappCategory.subTitle.amm")
        case .stakeYield:
            return Localized("degen.dappCategory.subTitle.stakeYield")
        case .landBorrow:
            return Localized("degen.dappCategory.subTitle.landBorrow")
        case .derivative:
            return Localized("degen.dappCategory.subTitle.derivative")
        case .bridge:
            return Localized("degen.dappCategory.subTitle.bridge")
        case .mixer:
            return Localized("degen.dappCategory.subTitle.mixer")
        case .governance:
            return Localized("degen.dappCategory.subTitle.governance")
        }
    }

}