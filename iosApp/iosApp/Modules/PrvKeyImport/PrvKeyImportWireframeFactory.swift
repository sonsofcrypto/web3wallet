// Created by web3d3v on 30/12/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol PrvKeyImportWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: PrvKeyImportWireframeContext
    ) -> PrvKeyImportWireframe
}

final class DefaultPrvKeyImportWireframeFactory {
    private let signerStoreService: SignerStoreService
    private let passwordService: PasswordService
    private let clipboardService: ClipboardService
    private let settingsService: SettingsService
    private let addressService: AddressService

    init(
        signerStoreService: SignerStoreService,
        passwordService: PasswordService,
        clipboardService: ClipboardService,
        settingsService: SettingsService,
        addressService: AddressService
    ) {
        self.signerStoreService = signerStoreService
        self.passwordService = passwordService
        self.clipboardService = clipboardService
        self.settingsService = settingsService
        self.addressService = addressService
    }
}

extension DefaultPrvKeyImportWireframeFactory: PrvKeyImportWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: PrvKeyImportWireframeContext
    ) -> PrvKeyImportWireframe {
        DefaultPrvKeyImportWireframe(
            parent,
            context: context,
            signerStoreService: signerStoreService,
            passwordService: passwordService,
            clipboardService: clipboardService,
            settingsService: settingsService,
            addressService: addressService
        )
    }
}

final class PrvKeyImportWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> PrvKeyImportWireframeFactory in
            DefaultPrvKeyImportWireframeFactory(
                signerStoreService: resolver.resolve(),
                passwordService: resolver.resolve(),
                clipboardService: resolver.resolve(),
                settingsService: resolver.resolve(),
                addressService: resolver.resolve()
            )
        }
    }
}
