//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

protocol WalletsService: AnyObject {

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

final class DefaultWalletsService {

    var activeWallet: Wallet? {
        get { store.get(Constant.activeWallet) }
        set { try? store.set(newValue, key: Constant.activeWallet) }
    }

    private var store: Store
    private var wallets: [Wallet]

    init(store: Store) {
        self.store = store
        self.wallets = []
    }
}

extension DefaultWalletsService: WalletsService {

    func loadWallets(_ handler: WalletsHandler) {
        guard wallets.isEmpty else {
            handler(wallets)
            return
        }

        wallets = (store.get(Constant.wallets) ?? [])
                .sorted(by: { $0.id < $1.id  })
        handler(wallets)
    }

    func createNewWallet(
        _ password: String,
        passphrase: String?
    ) throws -> Wallet {

        let wallet = Wallet(
            id: (wallets.last?.id ?? -1) + 1,
            name: "Default Wallet",
            encryptedSigner: "This will be mnemonic or private key or HD connection"
        )
        
        wallets.append(wallet)
        try store.set(wallet, key: Constant.wallets)
        return wallet
    }

    func importWallet(
        _ mnemonic: String,
        password: String,
        passphrase: String?
    ) throws-> Wallet {

        let wallet = Wallet(
            id: (wallets.last?.id ?? -1) + 1,
            name: "Imported wallet",
            encryptedSigner: mnemonic
        )
        
        wallets.append(wallet)
        try store.set(wallets, key: Constant.wallets)
        return wallet
    }

    func delete(_ wallet: Wallet) throws {
        wallets.removeAll(where: { $0.id == wallet.id })
        try store.set(wallets, key: Constant.wallets)
    }
}

private extension DefaultWalletsService {

    enum Constant {
        static let wallets = "walletsKey"
        static let activeWallet = "activeWalletKey"
    }
}
