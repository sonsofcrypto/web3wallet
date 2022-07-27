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
        
        case debug = "debug"
        case debugAPIs = "debug.apis"
        case debugAPIsNFTs = "debug.apis.nfts"
        
    }

    enum ActionIdentifier: String {
        
        case themeMiami = "theme.miami"
        case themeIOS = "theme.ios"

        case debugAPIsNFTsOpenSea = "providers.nfts.opensea"
        case debugAPIsNFTsMock = "providers.nfts.mock"

        case resetKeystore = "reset.keystore"
    }
}
