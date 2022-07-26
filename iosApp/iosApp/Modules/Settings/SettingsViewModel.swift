// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct SettingsViewModel {
    
    let title: String
    let sections: [SettingsViewModel.Section]
}

extension SettingsViewModel {

    struct Section {
        
        let title: String?
        let items: [Item]
    }
    
    struct Item {
        
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
