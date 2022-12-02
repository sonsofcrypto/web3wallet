// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - SettingsWireframeFactory

protocol SettingsWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: SettingsWireframeContext
    ) -> SettingsWireframe
}

// MARK: - DefaultSettingsWireframeFactory

final class DefaultSettingsWireframeFactory {
    private let settingsService: SettingsService
    private let settingsServiceActionTrigger: SettingsServiceActionTrigger

    init(
        settingsService: SettingsService,
        settingsServiceActionTrigger: SettingsServiceActionTrigger
    ) {
        self.settingsService = settingsService
        self.settingsServiceActionTrigger = settingsServiceActionTrigger
    }
}

extension DefaultSettingsWireframeFactory: SettingsWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: SettingsWireframeContext
    ) -> SettingsWireframe {
        DefaultSettingsWireframe(
            parent,
            context: context,
            settingsService: settingsService,
            settingsServiceActionTrigger: settingsServiceActionTrigger
        )
    }
}

// MARK: - Assembler

final class SettingsWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> SettingsWireframeFactory in
            DefaultSettingsWireframeFactory(
                settingsService: resolver.resolve(),
                settingsServiceActionTrigger: resolver.resolve()
            )
        }
    }
}

