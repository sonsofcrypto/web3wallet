// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct SettingsViewModel {
    
    let title: String
    let sections: [SettingsViewModel.Section]
}

extension SettingsViewModel {

    enum Section {
        
        case header(header: Header)
        case group(items: [Item])
        
        struct Header {
            
            let title: String
        }
        
        var items: [Item] {
            
            switch self {
            case .header:
                return []
            case let .group(items):
                return items
            }
        }
    }
        
    struct Item: Equatable {
        
        let title: String
        let setting: Setting
        let isSelected: Bool?
    }
}

extension SettingsViewModel {

    func item(at idxPath: IndexPath) -> SettingsViewModel.Item {
        
        sections[idxPath.section].items[idxPath.item]
    }
}
