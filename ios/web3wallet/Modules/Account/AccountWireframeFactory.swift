// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AccountWireframeFactory {

    func makeWireframe(_ parent: UIViewController, wallet: Wallet) -> AccountWireframe
}

// MARK: - DefaultAccountWireframeFactory

class DefaultAccountWireframeFactory {

    private let service: AccountService

    init(
        _ service: AccountService
    ) {
        self.service = service
    }
}

// MARK: - AccountWireframeFactory

extension DefaultAccountWireframeFactory: AccountWireframeFactory {

    func makeWireframe(_ parent: UIViewController, wallet: Wallet) -> AccountWireframe {
        DefaultAccountWireframe(
            parent: parent,
            interactor: DefaultAccountInteractor(service, wallet: wallet)
        )
    }
}