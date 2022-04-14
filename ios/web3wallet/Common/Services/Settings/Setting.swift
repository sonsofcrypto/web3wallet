// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum Setting: String, CaseIterable {

    case createWalletTransitionType = "New seed transition type"
    case theme = "Theme"
}

// MARK: - createWalletTransitionType

extension Setting {

    enum CreateWalletTransitionTypeOptions: Int, CaseIterable, Codable, Equatable {
        case cardFlip
        case dismissCardFlip
        case dismissMorph
    }
}

// MARK: - theme

extension Setting {

    enum ThemeTypeOptions: String, CaseIterable, Codable, Equatable {
        case primary = "Default"
        case alternative = "Alternative"
    }
}
