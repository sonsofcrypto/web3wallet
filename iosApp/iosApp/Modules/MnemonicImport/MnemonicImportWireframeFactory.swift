// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol MnemonicImportWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: MnemonicImportContext
    ) -> MnemonicImportWireframe
}

// MARK: - DefaultMnemonicWireframeFactory

final class DefaultMnemonicImportWireframeFactory {

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

extension DefaultMnemonicImportWireframeFactory: MnemonicImportWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: MnemonicImportContext
    ) -> MnemonicImportWireframe {
        
        DefaultMnemonicImportWireframe(
            parent: parent,
            context: context,
            keyStoreService: keyStoreService,
            settingsService: settingsService
        )
    }
}

// MARK: - Assembler

final class MnemonicImportWireframeFactoryAssembler: AssemblerComponent {
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> MnemonicImportWireframeFactory in
            DefaultMnemonicImportWireframeFactory(
                keyStoreService: resolver.resolve(),
                settingsService: resolver.resolve()
            )
        }
    }
}