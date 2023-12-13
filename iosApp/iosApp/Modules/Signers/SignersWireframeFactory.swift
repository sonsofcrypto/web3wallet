// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol SignersWireframeFactory {
    func make(
        _ parent: UIViewController?
    ) -> SignersWireframe
}

// MARK: - DefaultSignersWireframeFactory

final class DefaultSignersWireframeFactory {

    private let signerStoreService: SignerStoreService
    private let networksService: NetworksService
    private let clipboardService: ClipboardService
    private let newMnemonic: MnemonicNewWireframeFactory
    private let updateMnemonic: MnemonicUpdateWireframeFactory
    private let importMnemonic: MnemonicImportWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory

    init(
        signerStoreService: SignerStoreService,
        networksService: NetworksService,
        clipboardService: ClipboardService,
        newMnemonic: MnemonicNewWireframeFactory,
        updateMnemonic: MnemonicUpdateWireframeFactory,
        importMnemonic: MnemonicImportWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory
    ) {
        self.signerStoreService = signerStoreService
        self.networksService = networksService
        self.clipboardService = clipboardService
        self.newMnemonic = newMnemonic
        self.updateMnemonic = updateMnemonic
        self.importMnemonic = importMnemonic
        self.alertWireframeFactory = alertWireframeFactory
    }
}

// MARK: - SignersWireframeFactory

extension DefaultSignersWireframeFactory: SignersWireframeFactory {

    func make(
        _ parent: UIViewController?
    ) -> SignersWireframe {
        DefaultSignersWireframe(
            parent,
            signerStoreService: signerStoreService,
            networksService: networksService,
            clipboardService: clipboardService,
            newMnemonic: newMnemonic,
            updateMnemonic: updateMnemonic,
            importMnemonic: importMnemonic,
            alertWireframeFactory: alertWireframeFactory
        )
    }
}

// MARK: - Assembler

final class SignersWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> SignersWireframeFactory in
            DefaultSignersWireframeFactory(
                signerStoreService: resolver.resolve(),
                networksService: resolver.resolve(),
                clipboardService: resolver.resolve(),
                newMnemonic: resolver.resolve(),
                updateMnemonic: resolver.resolve(),
                importMnemonic: resolver.resolve(),
                alertWireframeFactory: resolver.resolve()
            )
        }
    }
}
