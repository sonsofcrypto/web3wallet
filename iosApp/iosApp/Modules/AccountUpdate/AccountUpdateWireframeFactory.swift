// Created by web3d3v on 31/12/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol AccountUpdateWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: AccountUpdateWireframeContext
    ) -> AccountUpdateWireframe
}

// MARK: - DefaultMnemonicWireframeFactory

final class DefaultAccountUpdateWireframeFactory {
    private let signerStoreService: SignerStoreService
    private let addressService: AddressService
    private let clipboardService: ClipboardService
    private let settingsService: SettingsService
    private let authenticateWireframeFactory: AuthenticateWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory

    init(
        signerStoreService: SignerStoreService,
        addressService: AddressService,
        clipboardService: ClipboardService,
        settingsService: SettingsService,
        authenticateWireframeFactory: AuthenticateWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory
    ) {
        self.signerStoreService = signerStoreService
        self.addressService = addressService
        self.clipboardService = clipboardService
        self.settingsService = settingsService
        self.authenticateWireframeFactory = authenticateWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
    }
}

// MARK: - MnemonicWireframeFactory

extension DefaultAccountUpdateWireframeFactory: AccountUpdateWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: AccountUpdateWireframeContext
    ) -> AccountUpdateWireframe {
        DefaultAccountUpdateWireframe(
            parent,
            context: context,
            signerStoreService: signerStoreService,
            addressService: addressService,
            clipboardService: clipboardService,
            settingsService: settingsService,
            authenticateWireframeFactory: authenticateWireframeFactory,
            alertWireframeFactory: alertWireframeFactory
        )
    }
}

// MARK: - Assembler

final class AccountUpdateWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> AccountUpdateWireframeFactory in
            DefaultAccountUpdateWireframeFactory(
                signerStoreService: resolver.resolve(),
                addressService: resolver.resolve(),
                clipboardService: resolver.resolve(),
                settingsService: resolver.resolve(),
                authenticateWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve()
            )
        }
    }
}
