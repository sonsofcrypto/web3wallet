// Created by web3d3v on 12/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

struct AuthenticateContext {
    typealias AuthResult = Result<(String, String), Error>
    typealias Handler = (AuthResult) -> Void // password, salt
    // TODO(web3dgn): Title should for context dependent ie unlock, sign ...
    let title: String
    let keyStoreItem: KeyStoreItem?
    let handler: Handler
}
