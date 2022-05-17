// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol MnemonicWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: MnemonicContext
    ) -> MnemonicWireframe
}

// MARK: - DefaultMnemonicWireframeFactory

final class DefaultMnemonicWireframeFactory {

    private let keyStoreService: KeyStoreService
    private let settingsService: SettingsService

    init(
        keyStoreService: KeyStoreService,
        settingsService: SettingsService
    ) {
        self.keyStoreService = keyStoreService
        self.settingsService = settingsService
    }
}

// MARK: - MnemonicWireframeFactory

extension DefaultMnemonicWireframeFactory: MnemonicWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: MnemonicContext
    ) -> MnemonicWireframe {
        
        DefaultMnemonicWireframe(
            parent: parent,
            context: context,
            keyStoreService: keyStoreService,
            settingsService: settingsService
        )
    }
}
