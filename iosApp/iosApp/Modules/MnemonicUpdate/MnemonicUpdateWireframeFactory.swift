// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol MnemonicUpdateWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: MnemonicUpdateWireframeContext
    ) -> MnemonicUpdateWireframe
}

// MARK: - DefaultMnemonicWireframeFactory

final class DefaultMnemonicUpdateWireframeFactory {
    private let signerStoreService: SignerStoreService
    private let authenticateWireframeFactory: AuthenticateWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let settingsService: SettingsService
    
    init(
        signerStoreService: SignerStoreService,
        authenticateWireframeFactory: AuthenticateWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        settingsService: SettingsService
    ) {
        self.signerStoreService = signerStoreService
        self.authenticateWireframeFactory = authenticateWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.settingsService = settingsService
    }
}

// MARK: - MnemonicWireframeFactory

extension DefaultMnemonicUpdateWireframeFactory: MnemonicUpdateWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: MnemonicUpdateWireframeContext
    ) -> MnemonicUpdateWireframe {
        DefaultMnemonicUpdateWireframe(
            parent,
            context: context,
            signerStoreService: signerStoreService,
            authenticateWireframeFactory: authenticateWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            settingsService: settingsService
        )
    }
}

// MARK: - Assembler

final class MnemonicUpdateWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> MnemonicUpdateWireframeFactory in
            DefaultMnemonicUpdateWireframeFactory(
                signerStoreService: resolver.resolve(),
                authenticateWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                settingsService: resolver.resolve()
            )
        }
    }
}
