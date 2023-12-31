// Created by web3d3v on 31/12/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol PrvKeyUpdateWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: PrvKeyUpdateWireframeContext
    ) -> PrvKeyUpdateWireframe
}

// MARK: - DefaultMnemonicWireframeFactory

final class DefaultPrvKeyUpdateWireframeFactory {
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

extension DefaultPrvKeyUpdateWireframeFactory: PrvKeyUpdateWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: PrvKeyUpdateWireframeContext
    ) -> PrvKeyUpdateWireframe {
        DefaultPrvKeyUpdateWireframe(
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

final class PrvKeyUpdateWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> PrvKeyUpdateWireframeFactory in
            DefaultPrvKeyUpdateWireframeFactory(
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
