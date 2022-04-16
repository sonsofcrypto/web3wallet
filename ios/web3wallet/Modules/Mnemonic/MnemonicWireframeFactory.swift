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

class DefaultMnemonicWireframeFactory {

    private let service: KeyStoreService
    private let settingsService: SettingsService

    init(
        _ service: KeyStoreService,
        settingsService: SettingsService
    ) {
        self.service = service
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
            interactor: DefaultMnemonicInteractor(service),
            context: context,
            settingsService: settingsService
        )
    }
}