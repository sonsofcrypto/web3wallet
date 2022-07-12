// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol AuthenticateInteractor: AnyObject {

}

// MARK: - DefaultAuthenticateInteractor

class DefaultAuthenticateInteractor {

    private var keyStoreService: KeyStoreService
    private var keyChainService: KeyChainService

    init(
        keyStoreService: KeyStoreService,
        keyChainService: KeyChainService
    ) {
        self.keyStoreService = keyStoreService
        self.keyChainService = keyChainService
    }
}

// MARK: - DefaultAuthenticateInteractor

extension DefaultAuthenticateInteractor: AuthenticateInteractor {

}
