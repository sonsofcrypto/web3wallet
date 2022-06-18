// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol Web3Service: AnyObject {

    var allNetworks: [Web3Network] { get }
    var allTokens: [Web3Token] { get }
    
    var myTokens: [Web3Token] { get }
    func storeMyTokens(to tokens: [Web3Token])
    
    func networkIcon(for network: Web3Network) -> Data
    func tokenIcon(for token: Web3Token) -> Data
}

struct Web3Network: Codable, Equatable, Hashable {
    
    let name: String
    let hasDns: Bool
}

struct Web3Token: Codable {
    
    let symbol: String
    let name: String
    let address: String
    let type: `Type`
    let network: Web3Network
    let balance: Double
}

extension Web3Token {
    
    enum `Type`: Codable {
        
        case normal
        case featured
        case popular
    }
}
