// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol KeyStoreInteractor: AnyObject {

    typealias KeyStoreHandler = ([KeyStoreItem]) -> Void

    var selectedKeyStoreItem: KeyStoreItem? { get set }

    var keyStoreItems: [KeyStoreItem] { get }

    /// Generates new `KeyStoreItem` but does not save it to `KeyStore`
    func generateNewKeyStoreItem() -> KeyStoreItem

    /// returns nil if items are not loaded yet
    func keyStoreItem(at idx: Int) -> KeyStoreItem?

    func index(of keyStoreItem: KeyStoreItem) -> Int?

    func add(_ keyStoreItem: KeyStoreItem) throws

    func delete(_ keyStoreItem: KeyStoreItem) throws

    func reset() throws

    /// Checks if any data is present in `KeyStore`, returns correct value
    /// event before `load(_:)` is called
    func isEmpty() -> Bool

    func load(_ handler: KeyStoreHandler)
}

// MARK: - DefaultKeyStoreInteractor

class DefaultKeyStoreInteractor {

    var selectedKeyStoreItem: KeyStoreItem? {
        get { keyStoreService.selectedKeyStoreItem }
        set { keyStoreService.selectedKeyStoreItem = newValue }
    }

    var keyStoreItems: [KeyStoreItem] {
        get { keyStoreService.latestItems() }
    }

    private var keyStoreService: KeyStoreService

    init(_ walletsService: KeyStoreService) {
        self.keyStoreService = walletsService
    }
}

// MARK: - DefaultKeyStoreInteractor

extension DefaultKeyStoreInteractor: KeyStoreInteractor {

    func generateNewKeyStoreItem() -> KeyStoreItem {
        keyStoreService.generateNewKeyStoreItem()
    }

    func keyStoreItem(at idx: Int) -> KeyStoreItem? {
        keyStoreService.keyStoreItem(at: idx)
    }

    func index(of keyStoreItem: KeyStoreItem) -> Int? {
        return keyStoreItems.firstIndex(where: { $0.uuid == keyStoreItem.uuid })
    }

    func add(_ keyStoreItem: KeyStoreItem) throws {
        try keyStoreService.add(keyStoreItem)
    }

    func delete(_ keyStoreItem: KeyStoreItem) throws {
        try keyStoreService.delete(keyStoreItem)
    }

    func reset() throws {
        try keyStoreService.reset()
    }

    func isEmpty() -> Bool {
        keyStoreService.isEmpty()
    }

    func load(_ handler: KeyStoreHandler) {
        keyStoreService.load(handler)
    }
}
