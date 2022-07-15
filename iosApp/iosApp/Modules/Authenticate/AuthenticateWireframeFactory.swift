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

// MARK: - DefaultAuthenticateWireframeFactory

class DefaultAuthenticateWireframeFactory {

    private let keyStoreService: KeyStoreService

    init(keyStoreService: KeyStoreService) {
        self.keyStoreService = keyStoreService
    }
}

// MARK: - AuthenticateWireframeFactory

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

// MARK: - Assembler

final class AuthenticateWireframeFactoryAssembler: AssemblerComponent {
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> AuthenticateWireframeFactory in
            DefaultAuthenticateWireframeFactory(
                keyStoreService: resolver.resolve()
            )
        }
    }
}