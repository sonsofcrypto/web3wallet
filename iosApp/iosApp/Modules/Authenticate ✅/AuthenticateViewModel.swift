// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct AuthenticateViewModel {
    let title: String
    let password: String
    let passType: PassType
    let passwordPlaceholder: String
    let salt: String
    let saltPlaceholder: String
    let needsPassword: Bool
    let needsSalt: Bool
    
    enum PassType {
        case pin
        case pass
    }
}
