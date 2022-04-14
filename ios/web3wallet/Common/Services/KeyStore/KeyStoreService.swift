// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol KeyStoreService: AnyObject {

    typealias KeyStoreHandler = ([KeyStoreItem]) -> Void

    var selectedKeyStoreItem: KeyStoreItem? { get set }

    func isEmpty() -> Bool

    func load(_ handler: KeyStoreHandler)

    /// returns nil if items are not loaded yet
    func keyStoreItem(at idx: Int) -> KeyStoreItem?

    func createNewItem(
        _ password: String,
        passphrase: String?
    ) throws -> KeyStoreItem

    func importMnemonic(
        _ mnemonic: String,
        password: String,
        passphrase: String?
    ) throws -> KeyStoreItem

    func delete(_ wallet: KeyStoreItem) throws

    func reset() throws
}

// MARK: - DefaultKeyStoreService

class DefaultKeyStoreService {

    var selectedKeyStoreItem: KeyStoreItem? {
        get { store.get(Constant.activeWallet) }
        set { try? store.set(newValue, key: Constant.activeWallet) }
    }

    private var store: Store
    private var keyStoreItems: [KeyStoreItem]

    init(store: Store) {
        self.store = store
        self.keyStoreItems = []
        load { items in () }
    }
}

// MARK: - KeyStoreService

extension DefaultKeyStoreService: KeyStoreService {

    func isEmpty() -> Bool {
        keyStoreItems.isEmpty
    }

    func keyStoreItem(at idx: Int) -> KeyStoreItem? {
        keyStoreItems[safe: idx]
    }

    func load(_ handler: KeyStoreHandler) {
        guard keyStoreItems.isEmpty else {
            handler(keyStoreItems)
            return
        }

        keyStoreItems = (store.get(Constant.wallets) ?? [])
            .sorted(by: { $0.sortOrder < $1.sortOrder })
        handler(keyStoreItems)
    }

    func createNewItem(
        _ password: String,
        passphrase: String?
    ) throws -> KeyStoreItem {

        let keyStoreItem = KeyStoreItem(
            uuid: UUID(),
            name: "Default Wallet",
            sortOrder: (keyStoreItems.last?.sortOrder ?? -1) + 1,
            iCouldBackup: true,
            saltMnemonic: false,
            mnemonicSalt: "",
            passwordType: .pin,
            password: "",
            allowPswdUnlockWithFaceId: true,
            creationDate: Date(),
            modification: Date(),
            encryptedSigner: "This will be mnemonic or private key or HD connection",
            mnemonic: "strategy edge trash series dad tiny couch since witness box unveil timber"
        )

        keyStoreItems.append(keyStoreItem)
        try store.set(keyStoreItem, key: Constant.wallets)
        return keyStoreItem
    }

    func importMnemonic(
        _ mnemonic: String,
        password: String,
        passphrase: String?
    ) throws-> KeyStoreItem {

        let wallet = KeyStoreItem(
            uuid: UUID(),
            name: "Imported wallet",
            sortOrder: (keyStoreItems.last?.sortOrder ?? -1) + 1,
            iCouldBackup: true,
            saltMnemonic: false,
            mnemonicSalt: "",
            passwordType: .pin,
            password: "",
            allowPswdUnlockWithFaceId: true,
            creationDate: Date(),
            modification: Date(),
            encryptedSigner: mnemonic,
            mnemonic: mnemonic
        )
        
        keyStoreItems.append(wallet)
        try store.set(keyStoreItems, key: Constant.wallets)
        return wallet
    }

    func delete(_ keyStoreItem: KeyStoreItem) throws {
        keyStoreItems.removeAll(where: { $0.uuid == keyStoreItem.uuid })
        try store.set(keyStoreItems, key: Constant.wallets)
    }

    func reset() throws {
        keyStoreItems.forEach { try? delete($0)  }
    }
}

// MARK: - Constant

private extension DefaultKeyStoreService {

    enum Constant {
        static let wallets = "walletsKey"
        static let activeWallet = "activeWalletKey"
    }
}
