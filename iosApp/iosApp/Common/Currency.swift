// Created by web3d3v on 04/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum CryptoNetwork {
    case ethereum
    case solana
}

struct Token {
    let name: String
    let ticker: String
    let address: String?
    let network: CryptoNetwork
    let iconName: String
}
