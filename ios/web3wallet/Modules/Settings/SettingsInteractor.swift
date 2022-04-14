// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol SettingsInteractor: AnyObject {

    var title: String { get }
    var items: [SettingsItem] { get }

    func settingsItem(for setting: Setting) -> [SettingsItem]
    func didSelectSettingOption(at idx: Int, forSetting setting: Setting)
    func handleActionIfPossible(_ action: SettingsItem.ActionType) -> Bool
}

// MARK: - DefaultSettingsInteractor

class DefaultSettingsInteractor {

    private var settingsService: SettingsService
    private var keyStoreService: KeyStoreService

    private(set) var title: String
    private(set) var items: [SettingsItem]

    init(
        _ settingsService: SettingsService,
        keyStoreService: KeyStoreService,
        title: String = "settings",
        settings: [SettingsItem] = DefaultSettingsInteractor.rootSettings()
    ) {
        self.settingsService = settingsService
        self.keyStoreService = keyStoreService
        self.title = title
        self.items = settings
    }

    static func rootSettings() -> [SettingsItem] {
        [
            .group(
                items: [
                    .setting(setting: .createWalletTransitionType),
                    .setting(setting: .theme)
                ],
                title: "settings"
            ),
            .group(
                items: [
                    .action(type: .resetKeyStore)
                ],
                title: "Actions"
            )
        ]
    }
}

// MARK: - DefaultSettingsInteractor

extension DefaultSettingsInteractor: SettingsInteractor {

    func settingsItem(for setting: Setting) -> [SettingsItem] {
        switch setting {
        case .createWalletTransitionType:
            let idx = Setting.CreateWalletTransitionTypeOptions.allCases.firstIndex(
                of: settingsService.createWalletTransitionType
            )
            return [
                .group(
                    items: Setting.CreateWalletTransitionTypeOptions.allCases.enumerated().map {
                        SettingsItem.selectableOption(
                            setting: setting,
                            optIdx: $0.0,
                            optTitle: "\($0.1)",
                            selected: idx == $0.0
                        )
                    },
                    title: setting.rawValue
                )
            ]
        case .theme:
            let idx = Setting.ThemeTypeOptions.allCases.firstIndex(of: settingsService.theme)
            return [
                .group(
                    items: Setting.ThemeTypeOptions.allCases.enumerated().map {
                        SettingsItem.selectableOption(
                            setting: setting,
                            optIdx: $0.0,
                            optTitle: Localized($0.1.rawValue),
                            selected: idx == $0.0
                        )
                    },
                    title: setting.rawValue
                )
            ]
        }
    }

    func didSelectSettingOption(at idx: Int, forSetting setting: Setting) {
        // TODO: Switch setting
    }

    func handleActionIfPossible(_ action: SettingsItem.ActionType) -> Bool {
        switch action {
        case .resetKeyStore:
            try? keyStoreService.reset()
            fatalError("Killing app after keyStore reset")
            return true
        default:
            return false
        }
    }
}
