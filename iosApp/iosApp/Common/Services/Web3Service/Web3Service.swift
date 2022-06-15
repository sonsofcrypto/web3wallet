// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol Web3Service: AnyObject {

    var allNetworks: [Web3Network] { get }
    var allTokens: [Web3Token] { get }
    var myTokens: [Web3Token] { get }
}

//All | Ethereum | Solana
//
//Address | ETH DNS

struct Web3Network {
    
    let icon: Data
    let name: String
    let hasDns: Bool
}

struct Web3Token {
    
    /** Image in png format */
    let image: Data?
    let symbol: String
    let name: String
    let address: String
    let type: `Type`
    let network: Web3Network
}

extension Web3Token {
    
    enum `Type` {
        
        case normal
        case featured
        case popular
    }
}
