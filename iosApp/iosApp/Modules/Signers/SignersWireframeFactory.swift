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
    private let updatePrvKey: PrvKeyUpdateWireframeFactory
    private let importMnemonic: MnemonicImportWireframeFactory
    private let importPrvKey: AccountImportWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let authenticateWireframeFactory: AuthenticateWireframeFactory

    init(
        signerStoreService: SignerStoreService,
        networksService: NetworksService,
        clipboardService: ClipboardService,
        newMnemonic: MnemonicNewWireframeFactory,
        updateMnemonic: MnemonicUpdateWireframeFactory,
        updatePrvKey: PrvKeyUpdateWireframeFactory,
        importMnemonic: MnemonicImportWireframeFactory,
        importPrvKey: AccountImportWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        authenticateWireframeFactory: AuthenticateWireframeFactory
    ) {
        self.signerStoreService = signerStoreService
        self.networksService = networksService
        self.clipboardService = clipboardService
        self.newMnemonic = newMnemonic
        self.updateMnemonic = updateMnemonic
        self.updatePrvKey = updatePrvKey
        self.importMnemonic = importMnemonic
        self.importPrvKey = importPrvKey
        self.alertWireframeFactory = alertWireframeFactory
        self.authenticateWireframeFactory = authenticateWireframeFactory
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
            updatePrvKey: updatePrvKey,
            importMnemonic: importMnemonic,
            importPrivKey: importPrvKey,
            alertWireframeFactory: alertWireframeFactory,
            authenticateWireframeFactory: authenticateWireframeFactory
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
                updatePrvKey: resolver.resolve(),
                importMnemonic: resolver.resolve(),
                importPrvKey: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                authenticateWireframeFactory: resolver.resolve()
            )
        }
    }
}
