// Created by web3d3v on 18/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol OnboardingService: AnyObject {

    func shouldCreateWalletAtFirstLaunch() -> Bool
    func shouldShowOnboardingButton() -> Bool
    func markDidInteractCardSwitcher()
}

// MARK: - DefaultOnboardingService

class DefaultOnboardingService {

    let settings: SettingsService
    let defaults: UserDefaults

    init(
        _ settings: SettingsService,
        defaults: UserDefaults
    ) {
        self.settings = settings
        self.defaults = defaults
    }
}

// MARK: - OnboardingService

extension DefaultOnboardingService: OnboardingService {

    func shouldCreateWalletAtFirstLaunch() -> Bool {
        return settings.onboardingMode == .oneTap
    }

    func shouldShowOnboardingButton() -> Bool {
        let didInteract = defaults.bool(forKey: Constant.didInteractCardSwitcher)
        return settings.onboardingMode == .oneTap && !didInteract
    }

    func markDidInteractCardSwitcher() {
        guard settings.onboardingMode == .oneTap else {
            return
        }

        defaults.set(true, forKey: Constant.didInteractCardSwitcher)
    }
}

// MARK: - Constant

private extension DefaultOnboardingService {

    enum Constant {
        static let didInteractCardSwitcher = "didInteractCardSwitcherKey"
    }
}