//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

protocol AccountInteractor: AnyObject {

    var wallet: Wallet { get }
}

final class DefaultAccountInteractor {

    private(set) var wallet: Wallet
    private var accountService: AccountService

    init(
        _ accountService: AccountService,
        wallet: Wallet
    ) {
        self.accountService = accountService
        self.wallet = wallet
    }
}

extension DefaultAccountInteractor: AccountInteractor {

}
