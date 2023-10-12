// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - MnemonicNewWireframeFactory

protocol MnemonicNewWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: MnemonicNewWireframeContext
    ) -> MnemonicNewWireframe
}

// MARK: - DefaultMnemonicNewWireframeFactory

final class DefaultMnemonicNewWireframeFactory {
    private let signerStoreService: SignerStoreService
    private let passwordService: PasswordService
    private let settingsService: SettingsService
    
    init(
        signerStoreService: SignerStoreService,
        passwordService: PasswordService,
        settingsService: SettingsService
    ) {
        self.signerStoreService = signerStoreService
        self.passwordService = passwordService
        self.settingsService = settingsService
    }
}

extension DefaultMnemonicNewWireframeFactory: MnemonicNewWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: MnemonicNewWireframeContext
    ) -> MnemonicNewWireframe {
        DefaultMnemonicNewWireframe(
            parent,
            context: context,
            signerStoreService: signerStoreService,
            passwordService: passwordService,
            settingsService: settingsService
        )
    }
}

// MARK: - Assembler

final class MnemonicNewWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> MnemonicNewWireframeFactory in
            DefaultMnemonicNewWireframeFactory(
                signerStoreService: resolver.resolve(),
                passwordService: resolver.resolve(),
                settingsService: resolver.resolve()
            )
        }
    }
}
