// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct SettingsViewModel {
    let items: [SettingsViewModel.Item]
}

// MARK - Item

extension SettingsViewModel {

    struct Item {
        let title: String
        let type: ItemType
        let selectedValue: String?
    }
}

// MARK: - Item type

extension SettingsViewModel.Item {

    enum ItemType {
        case setting
        case action
    }
}

// MARK: - Action type

extension SettingsViewModel.Item.ItemType {

    enum ItemType {
        case resetStore
    }
}