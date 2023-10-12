// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol MnemonicConfirmationWireframeFactory {
    func make(_ parent: UIViewController?) -> MnemonicConfirmationWireframe
}

final class DefaultMnemonicConfirmationWireframeFactory {
    private let signerStoreService: SignerStoreService
    private let actionsService: ActionsService
    private let mnemonicService: MnemonicService
    
    init(
        signerStoreService: SignerStoreService,
        actionsService: ActionsService,
        mnemonicService: MnemonicService
    ) {
        self.signerStoreService = signerStoreService
        self.actionsService = actionsService
        self.mnemonicService = mnemonicService
    }
}

extension DefaultMnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory {
    
    func make(_ parent: UIViewController?) -> MnemonicConfirmationWireframe {
        DefaultMnemonicConfirmationWireframe(
            parent,
            signerStoreService: signerStoreService,
            actionsService: actionsService,
            mnemonicService: mnemonicService
        )
    }
}

final class MnemonicConfirmationWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> MnemonicConfirmationWireframeFactory in
            DefaultMnemonicConfirmationWireframeFactory(
                signerStoreService: resolver.resolve(),
                actionsService: resolver.resolve(),
                mnemonicService: resolver.resolve()
            )
        }
    }
}
