//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

protocol AccountInteractor: AnyObject {

    var wallet: Wallet { get }
}

// MARK: - DefaultAccountInteractor

class DefaultAccountInteractor {

    private(set) var wallet: Wallet
    private var accountService: AccountService

    init(_ accountService: AccountService, wallet: Wallet) {
        self.accountService = accountService
        self.wallet = wallet
    }
}

// MARK: - DefaultAccountInteractor

extension DefaultAccountInteractor: AccountInteractor {

}
