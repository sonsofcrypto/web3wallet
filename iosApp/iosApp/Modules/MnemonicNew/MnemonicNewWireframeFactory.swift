// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

// MARK: - MnemonicNewWireframeFactory

protocol MnemonicNewWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: MnemonicNewContext
    ) -> MnemonicNewWireframe
}

// MARK: - DefaultMnemonicNewWireframeFactory

final class DefaultMnemonicNewWireframeFactory {
    private let keyStoreService: KeyStoreService
    private let settingsService: SettingsService
    
    init(
        keyStoreService: KeyStoreService,
        settingsService: SettingsService
    ) {
        self.keyStoreService = keyStoreService
        self.settingsService = settingsService
    }
}

extension DefaultMnemonicNewWireframeFactory: MnemonicNewWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: MnemonicNewContext
    ) -> MnemonicNewWireframe {
        DefaultMnemonicNewWireframe(
            parent,
            context: context,
            keyStoreService: keyStoreService,
            settingsService: settingsService
        )
    }
}

// MARK: - Assembler

final class MnemonicNewWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> MnemonicNewWireframeFactory in
            DefaultMnemonicNewWireframeFactory(
                keyStoreService: resolver.resolve(),
                settingsService: resolver.resolve()
            )
        }
    }
}
