// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol AccountInteractor: AnyObject {

}

// MARK: - DefaultAccountInteractor

class DefaultAccountInteractor {


    private var AccountService: AccountService

    init(_ AccountService: AccountService) {
        self.AccountService = AccountService
    }
}

// MARK: - DefaultAccountInteractor

extension DefaultAccountInteractor: AccountInteractor {

}
