// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol MnemonicUpdateWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: MnemonicUpdateContext
    ) -> MnemonicUpdateWireframe
}

// MARK: - DefaultMnemonicWireframeFactory

final class DefaultMnemonicUpdateWireframeFactory {

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

// MARK: - MnemonicWireframeFactory

extension DefaultMnemonicUpdateWireframeFactory: MnemonicUpdateWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: MnemonicUpdateContext
    ) -> MnemonicUpdateWireframe {
        
        DefaultMnemonicUpdateWireframe(
            parent: parent,
            context: context,
            keyStoreService: keyStoreService,
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
                settingsService: resolver.resolve()
            )
        }
    }
}