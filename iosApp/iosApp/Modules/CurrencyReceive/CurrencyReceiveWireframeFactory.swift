// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - CurrencyReceiveWireframeFactory

protocol CurrencyReceiveWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: CurrencyReceiveWireframeContext
    ) -> CurrencyReceiveWireframe
}

// MARK: - DefaultCurrencyReceiveWireframeFactory

final class DefaultCurrencyReceiveWireframeFactory {
    private let networksService: NetworksService

    init(networksService: NetworksService) {
        self.networksService = networksService
    }
}

extension DefaultCurrencyReceiveWireframeFactory: CurrencyReceiveWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: CurrencyReceiveWireframeContext
    ) -> CurrencyReceiveWireframe {
        DefaultCurrencyReceiveWireframe(
            parent,
            context: context,
            networksService: networksService
        )
    }
}

// MARK: - Assembler

final class CurrencyReceiveWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> CurrencyReceiveWireframeFactory in
            DefaultCurrencyReceiveWireframeFactory(
                networksService: resolver.resolve()
            )
        }
    }
}

