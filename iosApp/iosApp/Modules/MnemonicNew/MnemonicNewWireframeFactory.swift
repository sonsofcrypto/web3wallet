// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol MnemonicNewWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: MnemonicNewContext
    ) -> MnemonicNewWireframe
}

final class DefaultMnemonicNewWireframeFactory {

    private let keyStoreService: KeyStoreService
    
    init(
        keyStoreService: KeyStoreService
    ) {
        self.keyStoreService = keyStoreService
    }
}

extension DefaultMnemonicNewWireframeFactory: MnemonicNewWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: MnemonicNewContext
    ) -> MnemonicNewWireframe {
        
        DefaultMnemonicNewWireframe(
            parent: parent,
            context: context,
            keyStoreService: keyStoreService
        )
    }
}
