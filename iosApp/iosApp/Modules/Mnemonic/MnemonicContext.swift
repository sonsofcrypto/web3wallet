// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct MnemonicContext {

    typealias KeyStoreItemHandler = ((KeyStoreItem) -> Void)

    var mode: Mode
    var didCreteKeyStoreItemHandler: KeyStoreItemHandler?
    var didUpdateKeyStoreItemHandler: KeyStoreItemHandler?

    init(
        mode: Mode,
        createHandler: KeyStoreItemHandler? = nil,
        updateHandler: KeyStoreItemHandler? = nil
    ) {
        self.mode = mode
        self.didCreteKeyStoreItemHandler = createHandler
        self.didUpdateKeyStoreItemHandler = updateHandler
    }
}

// MARK: - Mode

extension MnemonicContext {

    enum Mode {
        case new
        case update(keyStoreItem: KeyStoreItem)
        case restore

        func isUpdate() -> Bool {
            switch self {
            case .update:
                return true
            default:
                return false
            }
        }
    }
}
