// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SettingsWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
        context: SettingsWireframeContext
    ) -> SettingsWireframe
}

final class DefaultSettingsWireframeFactory {

    private let settingsService: SettingsService

    init(
        settingsService: SettingsService
    ) {
        
        self.settingsService = settingsService
    }
}

extension DefaultSettingsWireframeFactory: SettingsWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
        context: SettingsWireframeContext
    ) -> SettingsWireframe {
        
        DefaultSettingsWireframe(
            parent: parent,
            context: context,
            settingsService: settingsService
        )
    }
}
