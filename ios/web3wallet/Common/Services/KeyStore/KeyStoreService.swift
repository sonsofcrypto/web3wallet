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
        keyStoreItems.append(keyStoreItem)
        try store.set(keyStoreItems, key: Constant.keyStoreItems)
    }

    func delete(_ keyStoreItem: KeyStoreItem) throws {
        keyStoreItems.removeAll(where: { $0.uuid == keyStoreItem.uuid })
        try store.set(keyStoreItems, key: Constant.keyStoreItems)
    }

    func reset() throws {
        keyStoreItems.forEach { try? delete($0)  }
    }

    func isEmpty() -> Bool {
        keyStoreItems.isEmpty
    }

    func load(_ handler: KeyStoreHandler) {
        guard keyStoreItems.isEmpty else {
            handler(keyStoreItems)
            return
        }

        keyStoreItems = (store.get(Constant.keyStoreItems) ?? [])
            .sorted(by: { $0.sortOrder < $1.sortOrder })
        handler(keyStoreItems)
    }

    func createDefaultKeyStoreItem() {
        var item = generateNewKeyStoreItem()
        item.name = "web3wallet"
        try? add(item)
    }
}

// MARK: - Constant

private extension DefaultKeyStoreService {

    enum Constant {
        static let keyStoreItems = "keyStoreItemsKey"
        static let activeKeyStoreItem = "activeKeyStoreItemKey"
    }
}
