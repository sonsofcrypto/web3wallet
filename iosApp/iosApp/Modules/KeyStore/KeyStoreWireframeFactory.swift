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
    private let newMnemonic: MnemonicNewWireframeFactory

    init(
        keyStoreService: KeyStoreService,
        settingsService: SettingsService,
        newMnemonic: MnemonicNewWireframeFactory
    ) {
        self.keyStoreService = keyStoreService
        self.settingsService = settingsService
        self.newMnemonic = newMnemonic
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
            newMnemonic: newMnemonic,
            settingsService: settingsService
        )
    }
}

// MARK: - KeyStoreWireframeFactoryAssembler

final class KeyStoreWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> KeyStoreWireframeFactory in
            DefaultKeyStoreWireframeFactory(
                keyStoreService: resolver.resolve(),
                settingsService: resolver.resolve(),
                newMnemonic: resolver.resolve()
            )
        }
    }
}