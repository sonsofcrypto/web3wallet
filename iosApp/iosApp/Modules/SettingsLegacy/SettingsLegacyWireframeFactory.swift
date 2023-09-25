// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - SettingsLegacyWireframeFactory

protocol SettingsLegacyWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: SettingsLegacyWireframeContext
    ) -> SettingsLegacyWireframe
}

// MARK: - DefaultSettingsLegacyWireframeFactory

final class DefaultSettingsLegacyWireframeFactory {
    private let settingsService: SettingsLegacyService
    private let settingsServiceActionTrigger: SettingsServiceActionTrigger

    init(
        settingsService: SettingsLegacyService,
        settingsServiceActionTrigger: SettingsServiceActionTrigger
    ) {
        self.settingsService = settingsService
        self.settingsServiceActionTrigger = settingsServiceActionTrigger
    }
}

extension DefaultSettingsLegacyWireframeFactory: SettingsLegacyWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: SettingsLegacyWireframeContext
    ) -> SettingsLegacyWireframe {
        DefaultSettingsLegacyWireframe(
            parent,
            context: context,
            settingsService: settingsService,
            settingsServiceActionTrigger: settingsServiceActionTrigger
        )
    }
}

// MARK: - Assembler

final class SettingsLegacyWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> SettingsLegacyWireframeFactory in
            DefaultSettingsLegacyWireframeFactory(
                settingsService: resolver.resolve(),
                settingsServiceActionTrigger: resolver.resolve()
            )
        }
    }
}

