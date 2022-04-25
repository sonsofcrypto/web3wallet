// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol MnemonicInteractor: AnyObject {

    /// Generates new `KeyStoreItem` but does not save it to `KeyStore`
    func generateNewKeyStoreItem() -> KeyStoreItem

    /// Updates existing one or stores new one if not present
    func update(_ keyStoreItem: KeyStoreItem) -> KeyStoreItem

    func delete(_ keyStoreItem: KeyStoreItem)
}

// MARK: - DefaultTemplateInteractor

final class DefaultMnemonicInteractor {


    private var keyStoreService: KeyStoreService

    init(_ keyStoreService: KeyStoreService) {
        self.keyStoreService = keyStoreService
    }
}

// MARK: - DefaultTemplateInteractor

extension DefaultMnemonicInteractor: MnemonicInteractor {

    func generateNewKeyStoreItem() -> KeyStoreItem {
        keyStoreService.generateNewKeyStoreItem()
    }

    func update(_ keyStoreItem: KeyStoreItem) -> KeyStoreItem {
        try? keyStoreService.delete(keyStoreItem)
        try? keyStoreService.add(keyStoreItem)
        return keyStoreItem
    }

    func delete(_ keyStoreItem: KeyStoreItem) {
        try? keyStoreService.delete(keyStoreItem)
    }
}
