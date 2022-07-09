// Created by web3d3v on 18/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

final class DefaultOnboardingService {

    let settings: SettingsService
    let defaults: UserDefaults
    let keyStoreService: KeyStoreService

    init(
        settings: SettingsService,
        defaults: UserDefaults,
        keyStoreService: KeyStoreService
    ) {
        self.settings = settings
        self.defaults = defaults
        self.keyStoreService = keyStoreService
        
        if shouldCreateWalletAtFirstLaunch() && keyStoreService.isEmpty() {
            keyStoreService.createDefaultKeyStoreItem()
        }
    }
}

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

private extension DefaultOnboardingService {

    enum Constant {
        static let didInteractCardSwitcher = "didInteractCardSwitcherKey"
    }
}
