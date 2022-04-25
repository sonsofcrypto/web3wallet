// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

final class DefaultSettingsService {

    let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }
}

extension DefaultSettingsService: SettingsService {

    func settings() -> [Setting] {
        Setting.allCases
    }

    var onboardingMode: Setting.OnboardingModeOptions {
        get {
            let key = "\(Setting.onboardingMode.self)"
            return .init(rawValue: defaults.integer(forKey: "\(key)")) ?? .twoTap

        }
        set {
            let key = "\(Setting.onboardingMode.self)"
            defaults.set(newValue.rawValue, forKey: key)
            defaults.synchronize()
        }
    }

    var createWalletTransitionType: Setting.CreateWalletTransitionTypeOptions {
        get {
            let key = "\(Setting.createWalletTransitionType.self)"
            return .init(rawValue: defaults.integer(forKey: "\(key)")) ?? .cardFlip

        }
        set {
            let key = "\(Setting.createWalletTransitionType.self)"
            defaults.set(newValue.rawValue, forKey: key)
            defaults.synchronize()
        }
    }

    var theme: Setting.ThemeTypeOptions {
        get {
            let val = defaults.string(forKey: "\(Setting.theme.self)")
            return .init(rawValue: val ?? "") ?? .primary
        }
        set {
            defaults.set(newValue.rawValue, forKey: "\(Setting.theme.self)")
            defaults.synchronize()
        }
    }
}
