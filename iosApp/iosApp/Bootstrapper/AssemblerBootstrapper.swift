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
            KeyStoreKeyValStoreServiceAssembler(),
            KeyStoreServiceAssembler(),
            KeyChainServiceAssembler(),
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
            ChatServiceAssembler(),
            CultServiceAssembler(),
            Web3ServiceAssembler(),
            Web3ServiceLocalStorageAssembler(),
            PriceHistoryServiceAssembler(),
            // Modules
            AuthenticateWireframeFactoryAssembler(),
            AccountWireframeFactoryAssembler(),
            AlertWireframeFactoryAssembler(),
            AppsWireframeFactoryAssembler(),
            DashboardWireframeFactoryAssembler(),
            AMMsWireframeFactoryAssembler(),
            DegenWireframeFactoryAssembler(),
            SwapWireframeFactoryAssembler(),
            KeyStoreWireframeFactoryAssembler(),
            MnemonicNewWireframeFactoryAssembler(),
            MnemonicUpdateWireframeFactoryAssembler(),
            MnemonicImportWireframeFactoryAssembler(),
            MnemonicConfirmationWireframeFactoryAssembler(),
            NetworksWireframeFactoryAssembler(),
            NFTsDashboardWireframeFactoryAssembler(),
            NFTsCollectionWireframeFactoryAssembler(),
            NFTDetailWireframeFactoryAssembler(),
            RootWireframeFactoryAssembler(),
            SettingsWireframeFactoryAssembler(),
            ChatWireframeFactoryAssembler(),
            CultProposalsWireframeFactoryAssembler(),
            CultProposalWireframeFactoryAssembler(),
            TokenPickerWireframeFactoryAssembler(),
            TokenReceiveWireframeFactoryAssembler(),
            TokenAddWireframeFactoryAssembler(),
            TokenSendWireframeFactoryAssembler(),
            NetworkPickerWireframeFactoryAssembler(),
            QRCodeScanWireframeFactoryAssembler()
        ]
    }
}
