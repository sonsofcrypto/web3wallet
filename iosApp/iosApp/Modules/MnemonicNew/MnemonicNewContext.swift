// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

struct MnemonicNewContext {
    typealias KeyStoreItemHandler = ((KeyStoreItem) -> Void)

    let didCreteKeyStoreItemHandler: KeyStoreItemHandler?

    init(createHandler: KeyStoreItemHandler? = nil) {
        self.didCreteKeyStoreItemHandler = createHandler
    }
}
