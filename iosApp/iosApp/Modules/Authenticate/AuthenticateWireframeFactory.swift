// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - AuthenticateWireframeFactory

protocol AuthenticateWireframeFactory {
    func make(
        _ parent: UIViewController?,
       context: AuthenticateWireframeContext
    ) -> AuthenticateWireframe
}

// MARK: - DefaultAuthenticateWireframeFactory

final class DefaultAuthenticateWireframeFactory {
    private let signerStoreService: SignerStoreService

    init(signerStoreService: SignerStoreService) {
        self.signerStoreService = signerStoreService
    }
}

extension DefaultAuthenticateWireframeFactory: AuthenticateWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: AuthenticateWireframeContext
    ) -> AuthenticateWireframe {
        DefaultAuthenticateWireframe(
            parent,
            context: context,
            signerStoreService: signerStoreService
        )
    }
}

// MARK: - Assembler

final class AuthenticateWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> AuthenticateWireframeFactory in
            DefaultAuthenticateWireframeFactory(
                signerStoreService: resolver.resolve()
            )
        }
    }
}
