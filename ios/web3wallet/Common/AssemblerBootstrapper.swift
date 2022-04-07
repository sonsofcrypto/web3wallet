//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

final class AssemblerBootstrapper {}

extension AssemblerBootstrapper: Bootstrapper {
    
    func boot() {
        
        let assembler = DefaultAssembler()
        let components = makeComponents()
        assembler.configure(components: components)
        ServiceDirectory.assembler = assembler
    }
}

private extension AssemblerBootstrapper {
    
    func makeComponents() -> [AssemblerComponent] {
        
        [
            // Services
            AccountServiceAssembler(),
            AppsServiceAssembler(),
            DegenServiceAssembler(),
            NetworksServiceAssembler(),
            NFTsServiceAssembler(),
            SettingsServiceAssembler(),
            StoreAssembler(),
            WalletsServiceAssembler(),
            // Modules
            RootWireframeFactoryAssembler(),
            AccountWireframeFactoryAssembler(),
            AppsWireframeFactoryAssembler(),
            DashboardWireframeFactoryAssembler(),
            AMMsWireframeFactoryAssembler(),
            DegenWireframeFactoryAssembler(),
            SwapWireframeFactoryAssembler(),
            NetworksWireframeFactoryAssembler(),
            NFTsWireframeFactoryAssembler(),
            SettingsWireframeFactoryAssembler(),
            WalletsWireframeFactoryAssembler()
        ]
    }
}
