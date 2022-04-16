// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol KeyStoreWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        window: UIWindow?
    ) -> KeyStoreWireframe
}

// MARK: - DefaultKeyStoreWireframeFactory

class DefaultKeyStoreWireframeFactory {

    private let keyStoreSerive: KeyStoreService
    private let settingsService: SettingsService
    private let newMnemonic: MnemonicWireframeFactory

    init(
        _ walletsService: KeyStoreService,
        settingsService: SettingsService,
        newMnemonic: MnemonicWireframeFactory
    ) {
        self.keyStoreSerive = walletsService
        self.settingsService = settingsService
        self.newMnemonic = newMnemonic
    }
}

// MARK: - WalletsWireframeFactory

extension DefaultKeyStoreWireframeFactory: KeyStoreWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        window: UIWindow?
    ) -> KeyStoreWireframe {
        DefaultKeyStoreWireframe(
            parent: parent,
            window: window,
            interactor: DefaultKeyStoreInteractor(keyStoreSerive),
            newMnemonic: newMnemonic,
            settingsService: settingsService
        )
    }
}
