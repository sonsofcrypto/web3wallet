// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol SettingsInteractor: AnyObject {

    func settingsItem(for setting: Setting) -> [SettingsItem]
    func didSelectSettingOption(at idx: Int, forSetting setting: Setting)
    func handleActionIfPossible(_ action: SettingsItem.ActionType) -> Bool
}

final class DefaultSettingsInteractor {

    private let settingsService: SettingsService
    private let keyStoreService: KeyStoreService

    init(
        _ settingsService: SettingsService,
        keyStoreService: KeyStoreService
    ) {
        
        self.settingsService = settingsService
        self.keyStoreService = keyStoreService
    }
}

extension DefaultSettingsInteractor: SettingsInteractor {

    func settingsItem(for setting: Setting) -> [SettingsItem] {
        
        switch setting {
            
        case .onboardingMode:
            let idx = Setting.OnboardingModeOptions.allCases.firstIndex(
                of: settingsService.onboardingMode
            )
            return [
                .group(
                    title: setting.rawValue,
                    items: Setting.OnboardingModeOptions.allCases.enumerated().map {
                        SettingsItem.selectableOption(
                            setting: setting,
                            optIdx: $0.0,
                            optTitle: "\($0.1)",
                            selected: idx == $0.0
                        )
                    }
                )
            ]
            
        case .createWalletTransitionType:
            let idx = Setting.CreateWalletTransitionTypeOptions.allCases.firstIndex(
                of: settingsService.createWalletTransitionType
            )
            return [
                .group(
                    title: setting.rawValue,
                    items: Setting.CreateWalletTransitionTypeOptions.allCases.enumerated().map {
                        SettingsItem.selectableOption(
                            setting: setting,
                            optIdx: $0.0,
                            optTitle: "\($0.1)",
                            selected: idx == $0.0
                        )
                    }
                )
            ]
            
        case .theme:
            return SettingsItem.themeItems
        }
    }

    func didSelectSettingOption(at idx: Int, forSetting setting: Setting) {
        
        switch setting {
        case .onboardingMode:
            settingsService.onboardingMode = Setting.OnboardingModeOptions.allCases[idx]
        case .createWalletTransitionType:
            let val = Setting.CreateWalletTransitionTypeOptions.allCases[idx]
            settingsService.createWalletTransitionType = val
        case .theme:
            settingsService.theme = Setting.ThemeTypeOptions.allCases[idx]
        }
    }

    func handleActionIfPossible(_ action: SettingsItem.ActionType) -> Bool {
        
        switch action {
        case .resetKeyStore:
            keyStoreService.items().forEach {
                keyStoreService.remove(item: $0)
            }
            // fatalError("Killing app after keyStore reset")
            return true
        }
    }
}
