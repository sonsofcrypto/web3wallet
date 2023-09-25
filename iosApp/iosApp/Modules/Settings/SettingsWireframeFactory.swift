// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SettingsWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: SettingsWireframeContext
    ) -> SettingsWireframe
}

// MARK: - DefaultSettingsWireframeFactory

class DefaultSettingsWireframeFactory {
    private let service: SettingsService

    init(service: SettingsService) {
        self.service = service
    }
}

// MARK: - TemplateWireframeFactory

extension DefaultSettingsWireframeFactory: SettingsWireframeFactory {
    
    func make(
        _ parent: UIViewController?,
        context: SettingsWireframeContext
    ) -> SettingsWireframe {
        DefaultSettingsWireframe(
            parent,
            context: context,
            settingsService: service
        )
    }
}

// MARK: - Assembler

final class SettingsWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> SettingsWireframeFactory in
            DefaultSettingsWireframeFactory(
                service: resolver.resolve()
            )
        }
    }
}
