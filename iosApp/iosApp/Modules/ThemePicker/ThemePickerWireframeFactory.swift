// Created by web3d4v on 24/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

// MARK: - ThemePickerWireframeFactory

protocol ThemePickerWireframeFactory {
    func make(
        _ parent: UIViewController?
    ) -> ThemePickerWireframe
}

// MARK: - DefaultThemePickerWireframeFactory

final class DefaultThemePickerWireframeFactory {}

extension DefaultThemePickerWireframeFactory: ThemePickerWireframeFactory {
    
    func make(_ parent: UIViewController?) -> ThemePickerWireframe {
        DefaultThemePickerWireframe(parent)
    }
}

// MARK: - Assembler

final class ThemePickerWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { _ -> ThemePickerWireframeFactory in
            DefaultThemePickerWireframeFactory()
        }
    }
}
