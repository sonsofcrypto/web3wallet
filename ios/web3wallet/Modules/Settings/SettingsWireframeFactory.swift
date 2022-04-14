// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SettingsWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
        title: String,
        settings: [SettingsItem],
        settingsWireframeFactory: SettingsWireframeFactory
    ) -> SettingsWireframe
}

// MARK: - DefaultSettingsWireframeFactory

class DefaultSettingsWireframeFactory {

    private let service: SettingsService
    private let keyStoreService: KeyStoreService

    init(
        _ service: SettingsService,
        keyStoreService: KeyStoreService
    ) {
        self.service = service
        self.keyStoreService = keyStoreService
    }
}

// MARK: - SettingsWireframeFactory

extension DefaultSettingsWireframeFactory: SettingsWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
        title: String,
        settings: [SettingsItem],
        settingsWireframeFactory: SettingsWireframeFactory
    ) -> SettingsWireframe {
        DefaultSettingsWireframe(
            parent: parent,
            interactor: DefaultSettingsInteractor(
                service,
                keyStoreService: keyStoreService,
                title: title,
                settings: settings
            ),
            settingsWireframeFactory: settingsWireframeFactory
        )
    }
}