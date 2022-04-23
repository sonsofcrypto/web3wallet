// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

// MARK: - Hex string

extension Data {
    
    func hexString() -> String {
        reduce("") { $0 + String(format: "%02x", $1) }
    }
}
