// Created by web3d4v on 24/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class ThemePickerWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { _ -> ThemePickerWireframeFactory in
            
            DefaultThemePickerWireframeFactory()
        }
    }
}
