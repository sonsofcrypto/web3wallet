// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol MnemonicImportWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: MnemonicImportWireframeContext
    ) -> MnemonicImportWireframe
}

final class DefaultMnemonicImportWireframeFactory {
    private let keyStoreService: KeyStoreService
    private let mnemonicService: MnemonicService
    private let passwordService: PasswordService
    private let settingsService: SettingsLegacyService

    init(
        keyStoreService: KeyStoreService,
        mnemonicService: MnemonicService,
        passwordService: PasswordService,
        settingsService: SettingsLegacyService
    ) {
        self.keyStoreService = keyStoreService
        self.mnemonicService = mnemonicService
        self.passwordService = passwordService
        self.settingsService = settingsService
    }
}

extension DefaultMnemonicImportWireframeFactory: MnemonicImportWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: MnemonicImportWireframeContext
    ) -> MnemonicImportWireframe {
        DefaultMnemonicImportWireframe(
            parent,
            context: context,
            keyStoreService: keyStoreService,
            mnemonicService: mnemonicService,
            passwordService: passwordService,
            settingsService: settingsService
        )
    }
}

final class MnemonicImportWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> MnemonicImportWireframeFactory in
            DefaultMnemonicImportWireframeFactory(
                keyStoreService: resolver.resolve(),
                mnemonicService: resolver.resolve(),
                passwordService: resolver.resolve(),
                settingsService: resolver.resolve()
            )
        }
    }
}
