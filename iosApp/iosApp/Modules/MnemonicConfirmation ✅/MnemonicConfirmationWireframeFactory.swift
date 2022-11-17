// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol MnemonicConfirmationWireframeFactory {
    func make(_ parent: UIViewController?) -> MnemonicConfirmationWireframe
}

final class DefaultMnemonicConfirmationWireframeFactory {
    private let keyStoreService: KeyStoreService
    private let actionsService: ActionsService
    private let networksService: NetworksService
    init(
        keyStoreService: KeyStoreService,
        actionsService: ActionsService,
        networksService: NetworksService
    ) {
        self.keyStoreService = keyStoreService
        self.actionsService = actionsService
        self.networksService = networksService
    }
}

extension DefaultMnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory {
    
    func make(_ parent: UIViewController?) -> MnemonicConfirmationWireframe {
        DefaultMnemonicConfirmationWireframe(
            parent,
            keyStoreService: keyStoreService,
            actionsService: actionsService,
            networksService: networksService
        )
    }
}

final class MnemonicConfirmationWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> MnemonicConfirmationWireframeFactory in
            DefaultMnemonicConfirmationWireframeFactory(
                keyStoreService: resolver.resolve(),
                actionsService: resolver.resolve(),
                networksService: resolver.resolve()
            )
        }
    }
}
