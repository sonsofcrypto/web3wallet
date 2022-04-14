// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct SettingsViewModel {
    let title: String
    let sections: [SettingsViewModel.Section]
}

// MARK: - Section

extension SettingsViewModel {

    struct Section {
        let title: String?
        let items: [Item]
    }
}

// MARK: - Item

extension SettingsViewModel {

    enum Item {
        case setting(title: String)
        case selectableOption(title: String, selected: Bool)
        case action(title: String)
    }
}

// MARK: - Item type

extension SettingsViewModel.Item {

    func title() -> String {
        switch self {
        case let .setting(title):
            return title
        case let .selectableOption(title, _):
            return title
        case let .action(title):
            return title
        }
    }
}

// MARK: - Utilities

extension SettingsViewModel {

    func item(at idxPath: IndexPath) -> SettingsViewModel.Item {
        sections[idxPath.section].items[idxPath.item]
    }
}