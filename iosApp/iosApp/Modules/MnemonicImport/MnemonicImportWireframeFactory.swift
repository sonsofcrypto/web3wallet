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
    private let signerStoreService: SignerStoreService
    private let mnemonicService: MnemonicService
    private let passwordService: PasswordService
    private let settingsService: SettingsService
    private let addressService: AddressService

    init(
        signerStoreService: SignerStoreService,
        mnemonicService: MnemonicService,
        passwordService: PasswordService,
        settingsService: SettingsService,
        addressService: AddressService
    ) {
        self.signerStoreService = signerStoreService
        self.mnemonicService = mnemonicService
        self.passwordService = passwordService
        self.settingsService = settingsService
        self.addressService = addressService
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
            signerStoreService: signerStoreService,
            mnemonicService: mnemonicService,
            passwordService: passwordService,
            settingsService: settingsService,
            addressService: addressService
        )
    }
}

final class MnemonicImportWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> MnemonicImportWireframeFactory in
            DefaultMnemonicImportWireframeFactory(
                signerStoreService: resolver.resolve(),
                mnemonicService: resolver.resolve(),
                passwordService: resolver.resolve(),
                settingsService: resolver.resolve(),
                addressService: resolver.resolve()
            )
        }
    }
}
