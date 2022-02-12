// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol WalletsInteractor {

    typealias WalletsHandler = ([Wallet]) -> Void

    func loadWallets(_ handler: WalletsHandler)
    func createNewWallet(password: String, passphrase: String?)
    func importWallet(_ mnemonic: String, password: String, passphrase: String?)
    func delete(_ mnemonic: Wallet)
}

// MARK: - DefaultMnemonicsInteractor

class DefaultMnemonicsInteractor {


}

// MARK: - MnemonicsInteractor

extension DefaultMnemonicsInteractor: WalletsInteractor {

    func loadWallets(_ handler: WalletsHandler) {

    }

    func createNewWallet(password: String, passphrase: String?) {

    }

    func importWallet(_ mnemonic: String, password: String, passphrase: String?) {

    }
    func delete(_ mnemonic: Wallet) {

    }
}
