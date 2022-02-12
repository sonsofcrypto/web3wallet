// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol WalletsInteractor {

    typealias WalletsHandler = ([Wallet]) -> Void

    var activeWallet: Wallet? { get set }

    func loadWallets(_ handler: WalletsHandler)

    func createNewWallet(
        _ password: String,
        passphrase: String?
    ) throws -> Wallet

    func importWallet(
        _ mnemonic: String,
        password: String,
        passphrase: String?
    ) throws -> Wallet

    func delete(_ wallet: Wallet) throws
}

// MARK: - DefaultMnemonicsInteractor

class DefaultMnemonicsInteractor {

    var activeWallet: Wallet? {
        get { walletsService.activeWallet }
        set { walletsService.activeWallet = newValue }
    }

    private var walletsService: WalletsService

    init(_ walletsService: WalletsService) {
        self.walletsService = walletsService
    }
}

// MARK: - MnemonicsInteractor

extension DefaultMnemonicsInteractor: WalletsInteractor {

    func loadWallets(_ handler: WalletsHandler) {
        walletsService.loadWallets(handler)
    }

    func createNewWallet(
        _ password: String,
        passphrase: String?
    ) throws -> Wallet {

        try walletsService.createNewWallet(password, passphrase: passphrase)
    }

    func importWallet(
        _ mnemonic: String,
        password: String,
        passphrase: String?
    ) throws -> Wallet {

        try walletsService.importWallet(
            mnemonic,
            password: password,
            passphrase: passphrase
        )
    }

    func delete(_ wallet: Wallet) throws {
        try walletsService.delete(wallet)
    }
}
