// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol SettingsService: AnyObject {

    var onboardingMode: Setting.OnboardingModeOptions { get set }
    var theme: Setting.ThemeTypeOptions { get set }
    var createWalletTransitionType: Setting.CreateWalletTransitionTypeOptions { get set }

    func settings() -> [Setting]
}
