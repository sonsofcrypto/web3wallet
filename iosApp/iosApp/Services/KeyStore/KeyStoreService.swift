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
