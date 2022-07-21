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

// MARK: - DefaultMnemonicWireframeFactory

final class DefaultMnemonicNewWireframeFactory {

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

extension DefaultMnemonicNewWireframeFactory: MnemonicNewWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: MnemonicNewContext
    ) -> MnemonicNewWireframe {
        
        DefaultMnemonicNewWireframe(
            parent: parent,
            context: context,
            keyStoreService: keyStoreService,
            settingsService: settingsService
        )
    }
}
