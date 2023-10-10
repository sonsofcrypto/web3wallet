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

    private let keyStoreService: KeyStoreService
    private let networksService: NetworksService
    private let newMnemonic: MnemonicNewWireframeFactory
    private let updateMnemonic: MnemonicUpdateWireframeFactory
    private let importMnemonic: MnemonicImportWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory

    init(
        keyStoreService: KeyStoreService,
        networksService: NetworksService,
        newMnemonic: MnemonicNewWireframeFactory,
        updateMnemonic: MnemonicUpdateWireframeFactory,
        importMnemonic: MnemonicImportWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory
    ) {
        self.keyStoreService = keyStoreService
        self.networksService = networksService
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
            keyStoreService: keyStoreService,
            networksService: networksService,
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
                keyStoreService: resolver.resolve(),
                networksService: resolver.resolve(),
                newMnemonic: resolver.resolve(),
                updateMnemonic: resolver.resolve(),
                importMnemonic: resolver.resolve(),
                alertWireframeFactory: resolver.resolve()
            )
        }
    }
}
