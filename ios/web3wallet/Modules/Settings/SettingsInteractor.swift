// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol SettingsInteractor: AnyObject {

    var createWalletTransitionType: Setting.CreateWalletTransitionTypeOptions { get set }
    var theme: Setting.ThemeTypeOptions { get set }

    func currentValue(for setting: Setting) -> String
    func settings() -> [Setting]

    func resetKeyStore()
}

// MARK: - DefaultSettingsInteractor

class DefaultSettingsInteractor {

    private var settingsService: SettingsService
    private var keyStoreService: KeyStoreService

    init(
        _ settingsService: SettingsService,
        keyStoreService: KeyStoreService
    ) {
        self.settingsService = settingsService
        self.keyStoreService = keyStoreService
    }
}

// MARK: - DefaultSettingsInteractor

extension DefaultSettingsInteractor: SettingsInteractor {

    var createWalletTransitionType: Setting.CreateWalletTransitionTypeOptions {
        get { settingsService.createWalletTransitionType }
        set { settingsService.createWalletTransitionType = newValue }
    }

    var theme: Setting.ThemeTypeOptions {
        get { settingsService.theme }
        set { settingsService.theme = newValue }
    }

    func currentValue(for setting: Setting) -> String {
        switch setting {
        case .createWalletTransitionType:
            return "\(createWalletTransitionType)"
        case .theme:
            return theme.rawValue
        }
    }

    func settings() -> [Setting] {
        settingsService.settings()
    }

    func resetKeyStore() {
        try? keyStoreService.reset()
    }
}
