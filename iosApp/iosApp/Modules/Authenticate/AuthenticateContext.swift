// Created by web3d3v on 12/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

struct AuthenticateContext {

    typealias AuthResult = Result<(String, String), Error>
    typealias Handler = (AuthResult) -> Void // password, salt

    let keyStoreItem: KeyStoreItem
    let handler: Handler?
}
