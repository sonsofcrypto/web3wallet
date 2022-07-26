// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum SettingsItem {
    
    indirect case group(title: String, items: [SettingsItem])
    case setting(setting: Setting)
    case selectableOption(setting: Setting, optIdx: Int, optTitle: String, selected: Bool)
    case action(type: ActionType)
}

extension SettingsItem {

    enum ActionType: String {
        case resetKeyStore = "settings.action.resetKeyStore"
    }
}

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
        case let .group(_, items):
            return items
        default:
            return [self]
        }
    }
}

extension SettingsItem {
    
    static var themeItems: [SettingsItem] {
        
        let settingsService: SettingsService = ServiceDirectory.assembler.resolve()
        return [
            .group(
                title: Setting.theme.rawValue,
                items: Setting.ThemeTypeOptions.allCases.enumerated().compactMap {
                    SettingsItem.selectableOption(
                        setting: Setting.theme,
                        optIdx: $0.0,
                        optTitle: Localized($0.1.rawValue),
                        selected: $0.1 == settingsService.theme
                    )
                }
            )
        ]
    }
}
