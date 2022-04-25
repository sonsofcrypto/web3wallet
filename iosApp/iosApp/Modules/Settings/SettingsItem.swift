// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum SettingsItem {
    indirect case group(items: [SettingsItem], title: String)
    case setting(setting: Setting)
    case selectableOption(setting: Setting, optIdx: Int, optTitle: String, selected: Bool)
    case action(type: ActionType)
}

// MARK: - SettingsItem.ActionType

extension SettingsItem {

    enum ActionType: String {
        case resetKeyStore = "setting.action.resetKeyStore"
    }
}

// MARK: - Utilities

extension SettingsItem {

    func isGroup() -> Bool {
        switch self{
        case .group:
             return true
        default:
            return false
        }
    }

    func items() -> [SettingsItem] {
        switch self{
        case let .group(items, _):
            return items
        default:
            return [self]
        }
    }
}
