// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SettingsWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
        context: SettingsWireframeContext?
    ) -> SettingsWireframe
}

// MARK: - DefaultSettingsWireframeFactory

final class DefaultSettingsWireframeFactory {

    private let settingsService: SettingsService
    private let keyStoreService: KeyStoreService

    init(
        settingsService: SettingsService,
        keyStoreService: KeyStoreService
    ) {
        self.settingsService = settingsService
        self.keyStoreService = keyStoreService
    }
}

// MARK: - SettingsWireframeFactory

extension DefaultSettingsWireframeFactory: SettingsWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
        context: SettingsWireframeContext?
    ) -> SettingsWireframe {
        
        DefaultSettingsWireframe(
            parent: parent,
            context: context ?? .init(title: "", settings: []),
            settingsService: settingsService,
            keyStoreService: keyStoreService
        )
    }
}
