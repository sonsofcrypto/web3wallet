// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol AccountInteractor: AnyObject {

    var wallet: KeyStoreItem { get }
}

// MARK: - DefaultAccountInteractor

class DefaultAccountInteractor {

    private(set) var wallet: KeyStoreItem
    private var accountService: AccountService

    init(_ accountService: AccountService, wallet: KeyStoreItem) {
        self.accountService = accountService
        self.wallet = wallet
    }
}

// MARK: - DefaultAccountInteractor

extension DefaultAccountInteractor: AccountInteractor {

}
