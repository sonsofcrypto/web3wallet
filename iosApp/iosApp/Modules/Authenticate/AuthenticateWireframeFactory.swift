// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol AuthenticateWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
       context: AuthenticateContext
    ) -> AuthenticateWireframe
}

final class DefaultAuthenticateWireframeFactory {

    private let keyStoreService: KeyStoreService

    init(keyStoreService: KeyStoreService) {
        self.keyStoreService = keyStoreService
    }
}

extension DefaultAuthenticateWireframeFactory: AuthenticateWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
        context: AuthenticateContext
    ) -> AuthenticateWireframe {
        
        DefaultAuthenticateWireframe(
            parent: parent,
            context: context,
            keyStoreService: keyStoreService
        )
    }
}
