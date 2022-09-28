// Created by web3d4v on 15/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

extension Network {
    
    var iconName: String {
        // TODO: Review this logic when supporting other networks
        "token_eth_icon"
    }
    
    // TODO: Check with @Annon validation rules for each network type
    func isValid(address: String) -> Bool {
        address.hasPrefix("0x") && address.count == 42
    }
    
    // TODO: Check with @Annon formatting rules for each network type
    func formatAddressShort(_ address: String) -> String {
        let total = 8
        switch name.lowercased() {
        case "ethereum":
            return address.prefix(2 + total) + "..." + address.suffix(total)
        default:
            return address.prefix(total) + "..." + address.suffix(total)
        }
    }
}
