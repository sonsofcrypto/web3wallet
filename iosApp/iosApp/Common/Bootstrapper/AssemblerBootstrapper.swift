// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class AssemblerBootstrapper {
}

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
            KeyStoreServiceAssembler(),
            KeyChainServiceAssembler(),
            NetworksServiceAssembler(),
            NFTsServiceAssembler(),
            OnboardingServiceAssembler(),
            ReachabilityServiceAssembler(),
            SettingsServiceAssembler(),
            StoreAssembler(),
            CacheImageAssembler(),
            // Modules
            AccountWireframeFactoryAssembler(),
            AlertWireframeFactoryAssembler(),
            AppsWireframeFactoryAssembler(),
            DashboardWireframeFactoryAssembler(),
            AMMsWireframeFactoryAssembler(),
            DegenWireframeFactoryAssembler(),
            SwapWireframeFactoryAssembler(),
            KeyStoreWireframeFactoryAssembler(),
            MnemonicWireframeFactoryAssembler(),
            MnemonicConfirmationWireframeFactoryAssembler(),
            NetworksWireframeFactoryAssembler(),
            NFTsDashboardWireframeFactoryAssembler(),
            NFTsCollectionWireframeFactoryAssembler(),
            NFTDetailWireframeFactoryAssembler(),
            RootWireframeFactoryAssembler(),
            SettingsWireframeFactoryAssembler()
        ]
    }
}
