// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum Setting: String, CaseIterable {

    case onboardingMode = "settings.onboardingMode"
    case createWalletTransitionType = "settings.newSeedTransitionType"
    case theme = "settings.theme"
}

extension Setting {

    enum OnboardingModeOptions: Int, CaseIterable, Codable, Equatable {
        case twoTap
        case oneTap
    }
}

extension Setting {

    enum CreateWalletTransitionTypeOptions: Int, CaseIterable, Codable, Equatable {
        case cardFlip
        case sheet
    }
}

extension Setting {

    enum ThemeTypeOptions: String, CaseIterable, Codable, Equatable {
        
        case themeMiami = "settings.theme.miami"
        case themeIOS = "settings.theme.ios"
    }
}
