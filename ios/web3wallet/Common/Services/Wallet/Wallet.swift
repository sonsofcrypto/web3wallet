//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

struct Wallet {

    let id: Int
    let name: String
    let encryptedSigner: String
}

// MARK: - Codable

extension Wallet: Codable {}
