// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol MnemonicImportWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: MnemonicImportContext
    ) -> MnemonicImportWireframe
}

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

extension DefaultMnemonicImportWireframeFactory: MnemonicImportWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: MnemonicImportContext
    ) -> MnemonicImportWireframe {
        DefaultMnemonicImportWireframe(
            parent,
            context: context,
            keyStoreService: keyStoreService,
            settingsService: settingsService
        )
    }
}

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
