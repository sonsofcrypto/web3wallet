// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct DegenViewModel {
    
    let sections: [Section]
}

extension DegenViewModel {
    
    enum Section {
        
        case header(header: Header)
        case group(items: [Item])
    }
    
    struct Header {
        
        let title: String
        let isEnabled: Bool
    }

    struct Item {
        
        let icon: Data
        let title: String
        let subtitle: String
        let isEnabled: Bool
    }
}

extension DAppCategory {

    var title: String {
        
        switch self {
        case .swap:
            return Localized("degen.dappCategory.title.swap")
        case .cult:
            return Localized("degen.dappCategory.title.cult")
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
        case .swap:
            return Localized("degen.dappCategory.subTitle.swap")
        case .cult:
            return Localized("degen.dappCategory.subTitle.cult")
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
