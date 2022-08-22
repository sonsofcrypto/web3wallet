// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct Setting: Equatable {

    let title: String
    let type: `Type`
    
    enum `Type`: Equatable {
        
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
        case debug = "debug"
        
        case about = "about"
        
        case debugAPIs = "debug.apis"
        case debugAPIsNFTs = "debug.apis.nfts"
        
    }

    enum ActionIdentifier: String {
        
        case themeMiamiLight = "theme.miami.light"
        case themeMiamiDark = "theme.miami.dark"
        case themeIOSLight = "theme.ios.light"
        case themeIOSDark = "theme.ios.dark"

        case debugAPIsNFTsOpenSea = "providers.nfts.opensea"

        case resetKeystore = "reset.keystore"
        
        case aboutWebsite = "about.website"
        case aboutGitHub = "about.github"
        case aboutMedium = "about.medium"
        case aboutTelegram = "about.telegram"
        case aboutTwitter = "about.twitter"
        case aboutDiscord = "about.discord"
        case aboutMail = "about.mail"
    }
}
