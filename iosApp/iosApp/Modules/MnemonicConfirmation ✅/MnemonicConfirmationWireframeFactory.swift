// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol MnemonicConfirmationWireframeFactory {
    func make(
        _ parent: UIViewController?
    ) -> MnemonicConfirmationWireframe
}

final class DefaultMnemonicConfirmationWireframeFactory {
    private let keyStoreService: KeyStoreService
    private let web3Service: Web3ServiceLegacy
    init(
        keyStoreService: KeyStoreService,
        web3Service: Web3ServiceLegacy
    ) {
        self.keyStoreService = keyStoreService
        self.web3Service = web3Service
    }
}

extension DefaultMnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory {
    
    func make(_ parent: UIViewController?) -> MnemonicConfirmationWireframe {
        let service = DefaultMnemonicConfirmationService(
            keyStoreService: keyStoreService,
            web3Service: web3Service
        )
        return DefaultMnemonicConfirmationWireframe(
            parent,
            service: service
        )
    }
}

final class MnemonicConfirmationWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> MnemonicConfirmationWireframeFactory in
            DefaultMnemonicConfirmationWireframeFactory(
                keyStoreService: resolver.resolve(),
                web3Service: resolver.resolve()
            )
        }
    }
}
