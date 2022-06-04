// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AccountWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
        wallet: KeyStoreItem,
        token: Token
    ) -> AccountWireframe
}

final class DefaultAccountWireframeFactory {

    private let accountService: AccountService

    init(
        accountService: AccountService
    ) {
        self.accountService = accountService
    }
}

extension DefaultAccountWireframeFactory: AccountWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
        wallet: KeyStoreItem,
        token: Token
    ) -> AccountWireframe {
        
        DefaultAccountWireframe(
            parent: parent,
            interactor: DefaultAccountInteractor(
                accountService: accountService,
                wallet: wallet,
                token: token
            )
        )
    }
}
