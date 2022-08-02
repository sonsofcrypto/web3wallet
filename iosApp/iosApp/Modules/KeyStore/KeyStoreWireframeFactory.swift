// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol KeyStoreWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        window: UIWindow?
    ) -> KeyStoreWireframe
}

// MARK: - DefaultKeyStoreWireframeFactory

final class DefaultKeyStoreWireframeFactory {

    private let keyStoreService: KeyStoreService
    private let settingsService: SettingsService
    private let walletsConnectionService: WalletsConnectionService
    private let newMnemonic: MnemonicNewWireframeFactory
    private let updateMnemonic: MnemonicUpdateWireframeFactory
    private let importMnemonic: MnemonicImportWireframeFactory

    init(
        keyStoreService: KeyStoreService,
        settingsService: SettingsService,
        walletsConnectionService: WalletsConnectionService,
        newMnemonic: MnemonicNewWireframeFactory,
        updateMnemonic: MnemonicUpdateWireframeFactory,
        importMnemonic: MnemonicImportWireframeFactory
    ) {
        self.keyStoreService = keyStoreService
        self.settingsService = settingsService
        self.walletsConnectionService = walletsConnectionService
        self.newMnemonic = newMnemonic
        self.updateMnemonic = updateMnemonic
        self.importMnemonic = importMnemonic
    }
}

// MARK: - WalletsWireframeFactory

extension DefaultKeyStoreWireframeFactory: KeyStoreWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        window: UIWindow?
    ) -> KeyStoreWireframe {
        DefaultKeyStoreWireframe(
            parent: parent,
            window: window,
            keyStoreService: keyStoreService,
            walletsConnectionService: walletsConnectionService,
            newMnemonic: newMnemonic,
            updateMnemonic: updateMnemonic,
            importMnemonic: importMnemonic,
            settingsService: settingsService
        )
    }
}

final class KeyStoreWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> KeyStoreWireframeFactory in
            DefaultKeyStoreWireframeFactory(
                keyStoreService: resolver.resolve(),
                settingsService: resolver.resolve(),
                walletsConnectionService: resolver.resolve(),
                newMnemonic: resolver.resolve(),
                updateMnemonic: resolver.resolve(),
                importMnemonic: resolver.resolve()
            )
        }
    }
}