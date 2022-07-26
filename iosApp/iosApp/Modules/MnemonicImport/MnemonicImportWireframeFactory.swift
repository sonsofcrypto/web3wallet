// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol MnemonicImportWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: MnemonicImportContext
    ) -> MnemonicImportWireframe
}

final class DefaultMnemonicImportWireframeFactory {

    private let keyStoreService: KeyStoreService

    init(
        keyStoreService: KeyStoreService
    ) {
        self.keyStoreService = keyStoreService
    }
}

extension DefaultMnemonicImportWireframeFactory: MnemonicImportWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: MnemonicImportContext
    ) -> MnemonicImportWireframe {
        
        DefaultMnemonicImportWireframe(
            parent: parent,
            context: context,
            keyStoreService: keyStoreService
        )
    }
}

