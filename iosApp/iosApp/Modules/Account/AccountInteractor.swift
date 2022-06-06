// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol AccountInteractor: AnyObject {

    var wallet: KeyStoreItem { get }
    var token: Token { get }
}

final class DefaultAccountInteractor {

    private(set) var wallet: KeyStoreItem
    private(set) var token: Token

    private var accountService: AccountService

    init(
        accountService: AccountService,
        wallet: KeyStoreItem,
        token: Token
    ) {
        self.accountService = accountService
        self.wallet = wallet
        self.token = token
    }
}

extension DefaultAccountInteractor: AccountInteractor {

}
