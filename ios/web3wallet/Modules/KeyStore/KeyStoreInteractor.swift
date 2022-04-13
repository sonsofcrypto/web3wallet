// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol KeyStoreInteractor: AnyObject {

    typealias KeyStoreItemHandler = ([KeyStoreItem]) -> Void

    var activeKeyStoreItem: KeyStoreItem? { get set }

    var isEmpty: Bool { get }

    func loadWallets(_ handler: KeyStoreItemHandler)

    func keyStoreItem(at idx: Int) -> KeyStoreItem?

    func createNewWallet(
        _ password: String,
        passphrase: String?
    ) throws -> KeyStoreItem

    func importWallet(
        _ mnemonic: String,
        password: String,
        passphrase: String?
    ) throws -> KeyStoreItem

    func delete(_ wallet: KeyStoreItem) throws
}

// MARK: - DefaultKeyStoreInteractor

class DefaultKeyStoreInteractor {

    var activeKeyStoreItem: KeyStoreItem? {
        get { keyStoreService.selectedKeyStoreItem }
        set { keyStoreService.selectedKeyStoreItem = newValue }
    }

    var isEmpty: Bool {
        keyStoreService.isEmpty()
    }

    private var keyStoreService: KeyStoreService

    init(_ walletsService: KeyStoreService) {
        self.keyStoreService = walletsService
    }
}

// MARK: - DefaultKeyStoreInteractor

extension DefaultKeyStoreInteractor: KeyStoreInteractor {

    func loadWallets(_ handler: KeyStoreItemHandler) {
        keyStoreService.load(handler)
    }

    func keyStoreItem(at idx: Int) -> KeyStoreItem? {
        keyStoreService.keyStoreItem(at: idx)
    }

    func createNewWallet(
        _ password: String,
        passphrase: String?
    ) throws -> KeyStoreItem {

        try keyStoreService.createNewItem(password, passphrase: passphrase)
    }

    func importWallet(
        _ mnemonic: String,
        password: String,
        passphrase: String?
    ) throws -> KeyStoreItem {

        try keyStoreService.importMnemonic(
            mnemonic,
            password: password,
            passphrase: passphrase
        )
    }

    func delete(_ wallet: KeyStoreItem) throws {
        try keyStoreService.delete(wallet)
    }
}
