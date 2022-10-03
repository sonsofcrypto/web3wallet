// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol MnemonicUpdateWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: MnemonicUpdateContext
    ) -> MnemonicUpdateWireframe
}

// MARK: - DefaultMnemonicWireframeFactory

final class DefaultMnemonicUpdateWireframeFactory {
    private let keyStoreService: KeyStoreService
    private let authenticateWireframeFactory: AuthenticateWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let settingsService: SettingsService
    
    init(
        keyStoreService: KeyStoreService,
        authenticateWireframeFactory: AuthenticateWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        settingsService: SettingsService
    ) {
        self.keyStoreService = keyStoreService
        self.authenticateWireframeFactory = authenticateWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.settingsService = settingsService
    }
}

// MARK: - MnemonicWireframeFactory

extension DefaultMnemonicUpdateWireframeFactory: MnemonicUpdateWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: MnemonicUpdateContext
    ) -> MnemonicUpdateWireframe {
        DefaultMnemonicUpdateWireframe(
            parent,
            context: context,
            keyStoreService: keyStoreService,
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
                keyStoreService: resolver.resolve(),
                authenticateWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                settingsService: resolver.resolve()
            )
        }
    }
}
