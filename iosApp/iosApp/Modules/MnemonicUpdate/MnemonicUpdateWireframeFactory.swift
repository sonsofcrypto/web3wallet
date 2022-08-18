// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol MnemonicUpdateWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: MnemonicUpdateContext
    ) -> MnemonicUpdateWireframe
}

// MARK: - DefaultMnemonicWireframeFactory

final class DefaultMnemonicUpdateWireframeFactory {

    private let keyStoreService: KeyStoreService
    private let authenticateWireframeFactory: AuthenticateWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    
    init(
        keyStoreService: KeyStoreService,
        authenticateWireframeFactory: AuthenticateWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory
    ) {
        self.keyStoreService = keyStoreService
        self.authenticateWireframeFactory = authenticateWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
    }
}

// MARK: - MnemonicWireframeFactory

extension DefaultMnemonicUpdateWireframeFactory: MnemonicUpdateWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: MnemonicUpdateContext
    ) -> MnemonicUpdateWireframe {
        DefaultMnemonicUpdateWireframe(
            parent: parent,
            context: context,
            keyStoreService: keyStoreService,
            authenticateWireframeFactory: authenticateWireframeFactory,
            alertWireframeFactory: alertWireframeFactory
        )
    }
}
