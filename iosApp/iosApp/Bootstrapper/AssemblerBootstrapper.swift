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
            SettingsServiceAssembler(), // needs to be the first one to initialise
            KeyStoreKeyValStoreServiceAssembler(),
            KeyStoreServiceAssembler(),
            KeyChainServiceAssembler(),
            AppsServiceAssembler(),
            DegenServiceAssembler(),
            KeyStoreServiceAssembler(),
            KeyChainServiceAssembler(),
            NFTsServiceAssembler(),
            OnboardingServiceAssembler(),
            ReachabilityServiceAssembler(),
            ChatServiceAssembler(),
            CultServiceAssembler(),
            NetworksServiceAssembler(),
            CurrencyStoreServiceAssembler(),
            WalletServiceAssembler(),
            Web3ServiceLegacyAssembler(),
            FeaturesServiceAssembler(),
            FeatureVotingCacheServiceAssembler(),
            FeatureVotingRequestServiceAssembler(),
            FeatureServiceRunnerAssembler(),
            IosEtherscanServiceAssembler(),
            // DeepLink
            DeepLinkHandlerAssembler(),
            // Modules
            AuthenticateWireframeFactoryAssembler(),
            AccountWireframeFactoryAssembler(),
            AlertWireframeFactoryAssembler(),
            AppsWireframeFactoryAssembler(),
            DashboardWireframeFactoryAssembler(),
            DegenWireframeFactoryAssembler(),
            KeyStoreWireframeFactoryAssembler(),
            MnemonicNewWireframeFactoryAssembler(),
            MnemonicUpdateWireframeFactoryAssembler(),
            MnemonicImportWireframeFactoryAssembler(),
            MnemonicConfirmationWireframeFactoryAssembler(),
            NetworksWireframeFactoryAssembler(),
            NFTsDashboardWireframeFactoryAssembler(),
            NFTsCollectionWireframeFactoryAssembler(),
            NFTDetailWireframeFactoryAssembler(),
            NFTSendWireframeFactoryAssembler(),
            RootWireframeFactoryAssembler(),
            SettingsWireframeFactoryAssembler(),
            ChatWireframeFactoryAssembler(),
            CultProposalsWireframeFactoryAssembler(),
            CultProposalWireframeFactoryAssembler(),
            TokenPickerWireframeFactoryAssembler(),
            TokenReceiveWireframeFactoryAssembler(),
            TokenAddWireframeFactoryAssembler(),
            TokenSendWireframeFactoryAssembler(),
            TokenSwapWireframeFactoryAssembler(),
            NetworkPickerWireframeFactoryAssembler(),
            QRCodeScanWireframeFactoryAssembler(),
            ConfirmationWireframeFactoryAssembler(),
            FeaturesWireframeFactoryAssembler(),
            FeatureWireframeFactoryAssembler(),
            ThemePickerWireframeFactoryAssembler(),
            MailServiceAssembler(),
            WebViewWireframeFactoryAssembler(),
            UniswapServiceAssembler()
        ]
    }
}
