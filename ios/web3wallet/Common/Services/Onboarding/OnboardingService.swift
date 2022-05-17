// Created by web3d3v on 18/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol OnboardingService: AnyObject {

    func shouldCreateWalletAtFirstLaunch() -> Bool
    func shouldShowOnboardingButton() -> Bool
    func markDidInteractCardSwitcher()
}
