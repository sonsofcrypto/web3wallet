// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AccountWireframeFactory {

    func makeWireframe() -> AccountWireframe
}

// MARK: - DefaultAccountWireframeFactory

class DefaultAccountWireframeFactory {

    private let service: AccountService

    private weak var window: UIWindow?

    init(
        window: UIWindow?,
        service: AccountService
    ) {
        self.window = window
        self.service = service
    }
}

// MARK: - AccountWireframeFactory

extension DefaultAccountWireframeFactory: AccountWireframeFactory {

    func makeWireframe() -> AccountWireframe {
        DefaultAccountWireframe(
            interactor: DefaultAccountInteractor(service),
            window: window
        )
    }
}