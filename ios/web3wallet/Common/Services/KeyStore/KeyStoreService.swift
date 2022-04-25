// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol KeyStoreService: AnyObject {

    typealias KeyStoreHandler = ([KeyStoreItem]) -> Void

    var selectedKeyStoreItem: KeyStoreItem? { get set }

    func latestItems() -> [KeyStoreItem]

    /// Generates new `KeyStoreItem` but does not save it to `KeyStore`
    func generateNewKeyStoreItem() -> KeyStoreItem

    /// returns nil if items are not loaded yet
    func keyStoreItem(at idx: Int) -> KeyStoreItem?

    func add(_ keyStoreItem: KeyStoreItem) throws

    func delete(_ keyStoreItem: KeyStoreItem) throws

    func reset() throws

    /// Checks if any data is present in `KeyStore`, returns correct value
    /// event before `load(_:)` is called
    func isEmpty() -> Bool

    func load(_ handler: KeyStoreHandler)

    func createDefaultKeyStoreItem()
}

// MARK: - DefaultKeyStoreService

class DefaultKeyStoreService {

    var selectedKeyStoreItem: KeyStoreItem? {
        get { store.get(Constant.activeKeyStoreItem) }
        set { try? store.set(newValue, key: Constant.activeKeyStoreItem) }
    }

    private let store: Store
    private let keyChainService: KeyChainService
    private var keyStoreItems: [KeyStoreItem]

    init(
        store: Store,
        keyChainService: KeyChainService
    ) {
        self.store = store
        self.keyChainService = keyChainService
        self.keyStoreItems = []
        load { items in () }
    }
}

// MARK: - KeyStoreService

extension DefaultKeyStoreService: KeyStoreService {

    func latestItems() -> [KeyStoreItem] {
        return keyStoreItems
    }

    func generateNewKeyStoreItem() -> KeyStoreItem {
        KeyStoreItem.rand()
    }

    func keyStoreItem(at idx: Int) -> KeyStoreItem? {
        keyStoreItems[safe: idx]
    }

    func add(_ keyStoreItem: KeyStoreItem) throws {
        // TODO: Refactor entire logic here
        let id = keyStoreItem.id
        var keyStoreItem = keyStoreItem
        var password = keyStoreItem.password
        if password.isEmpty {
            password = (try? keyChainService.password(for: keyStoreItem.id))
                ?? randomPassword()
        }

        // TODO: Add / sync based on prefs
        keyChainService.removePassword(id: id)
        try keyChainService.addPassword(password, id: id, sync: true)

        try keyStoreItem.updateSecretStorage(password)

        keyChainService.removeItem(keyStoreItem)
        try keyChainService.addItem(keyStoreItem)
        keyStoreItems.append(keyStoreItem)
    }

    func delete(_ keyStoreItem: KeyStoreItem) throws {
        keyStoreItems.removeAll(where: { $0.uuid == keyStoreItem.uuid })
        keyChainService.removeItem(keyStoreItem)
    }

    func reset() throws {
        keyStoreItems.forEach { try? delete($0)  }
    }

    func isEmpty() -> Bool {
        keyChainItems().isEmpty
    }

    func load(_ handler: KeyStoreHandler) {
        keyStoreItems = keyChainItems()
        handler(keyStoreItems)
    }

    func createDefaultKeyStoreItem() {
        var item = generateNewKeyStoreItem()
        item.name = "web3wallet"
        try? add(item)
    }

    func keyChainItems() -> [KeyStoreItem] {
        let decoder = JSONDecoder()
        do {
            let dataItems = try keyChainService.allKeyStoreItems()
            var items = [KeyStoreItem]()
            for data in dataItems {
                let secureStorage = try decoder.decode(SecretStorage.self, from: data)
                let password = try keyChainService.password(for: secureStorage.id)
                let item = KeyStoreItem.from(secureStorage, password: password)
                items.append(item)
            }
            return items
        } catch {
            print("Failed to decode keyStoreItem", error)
            return []
        }

    }
}

// MARK: - Utilities

private extension DefaultKeyStoreService {

    func randomPassword() -> String {
        var retryCnt = 0
        while retryCnt < 5 {
            if let data = try? Data.secRandom(16){
                return data.hexString()
            }
            retryCnt += 1
            usleep(useconds_t(100000))
        }
        fatalError("Failed to generate randomPassword")
    }
}

// MARK: - Constant

private extension DefaultKeyStoreService {

    enum Constant {
        static let keyStoreItems = "keyStoreItemsKey"
        static let activeKeyStoreItem = "activeKeyStoreItemKey"
    }
}
