// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct Setting {

    let title: String
    let type: `Type`
    
    enum `Type` {
        
        case item(
            ItemIdentifier
        )
        case action(
            item: ItemIdentifier?,
            action: ActionIdentifier,
            showTickOnSelected: Bool
        )
    }
}

extension Setting {
    
    enum ItemIdentifier: String {
        
        case theme = "theme"
        
        case providers = "providers"
        case providersNFTs = "providers.nfts"
        
    }

    enum ActionIdentifier: String {
        
        case themeMiami = "theme.miami"
        case themeIOS = "theme.ios"

        case providersNFTsOpenSea = "providers.nfts.opensea"
        case providersNFTsMock = "providers.nfts.mock"

        case resetKeystore = "reset.keystore"
    }
}

//enum Setting: String, CaseIterable {
//
//    case onboardingMode = "settings.onboardingMode"
//    case createWalletTransitionType = "settings.newSeedTransitionType"
//    case theme = "settings.theme"
//    case providers = "settings.providers"
//}
//
//extension Setting {
//
//    enum OnboardingModeOptions: Int, CaseIterable, Codable, Equatable {
//        case twoTap
//        case oneTap
//    }
//}
//
//extension Setting {
//
//    enum CreateWalletTransitionTypeOptions: Int, CaseIterable, Codable, Equatable {
//        case cardFlip
//        case sheet
//    }
//}
//
//extension Setting {
//
//    enum ThemeTypeOptions: String, CaseIterable, Codable, Equatable {
//
//        case themeMiami = "settings.theme.miami"
//        case themeIOS = "settings.theme.ios"
//    }
//}
//
//extension Setting {
//
//    enum ProviderTypeOptions: String, CaseIterable, Codable, Equatable {
//
//        case nfts = "settings.providers.nfts"
//    }
//}
//
//extension Setting {
//
//    enum ProviderNFTsTypeOptions: String, CaseIterable, Codable, Equatable {
//
//        case openSea = "settings.providers.nfts.openSea"
//        case dummyData = "settings.providers.nfts.mock"
//    }
//}
