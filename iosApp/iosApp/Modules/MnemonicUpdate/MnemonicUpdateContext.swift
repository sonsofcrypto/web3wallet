// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

struct MnemonicUpdateContext {
    typealias KeyStoreItemHandler = ((KeyStoreItem) -> Void)

    let keyStoreItem: KeyStoreItem
    let didUpdateKeyStoreItemHandler: KeyStoreItemHandler?
    let onKeyStoreItemDeleted: (() -> Void)?

    init(
        keyStoreItem: KeyStoreItem,
        updateHandler: KeyStoreItemHandler? = nil,
        onKeyStoreItemDeleted: (() -> Void)? = nil
    ) {
        self.keyStoreItem = keyStoreItem
        self.didUpdateKeyStoreItemHandler = updateHandler
        self.onKeyStoreItemDeleted = onKeyStoreItemDeleted
    }
}
