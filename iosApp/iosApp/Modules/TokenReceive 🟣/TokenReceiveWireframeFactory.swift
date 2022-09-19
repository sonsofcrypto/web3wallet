// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

// MARK: - TokenReceiveWireframeFactory

protocol TokenReceiveWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: TokenReceiveWireframeContext
    ) -> TokenReceiveWireframe
}

// MARK: - DefaultTokenReceiveWireframeFactory

final class DefaultTokenReceiveWireframeFactory {
    private let networksService: NetworksService

    init(networksService: NetworksService) {
        self.networksService = networksService
    }
}

extension DefaultTokenReceiveWireframeFactory: TokenReceiveWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: TokenReceiveWireframeContext
    ) -> TokenReceiveWireframe {
        DefaultTokenReceiveWireframe(
            parent,
            context: context,
            networksService: networksService
        )
    }
}

// MARK: - Assembler

final class TokenReceiveWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> TokenReceiveWireframeFactory in
            DefaultTokenReceiveWireframeFactory(
                networksService: resolver.resolve()
            )
        }
    }
}

