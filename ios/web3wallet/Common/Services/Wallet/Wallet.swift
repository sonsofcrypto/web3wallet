// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct Wallet {

    let id: Int
    let name: String
    let encryptedSigner: String
}

// MARK: - Codable

extension Wallet: Codable {}