// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class AssemblerBootstrapper {

    // NOTE: This is needed to get previews in storyboards working
    func backupAssembler() -> Assembler {
        let assembler = DefaultAssembler()
        let components = makeComponents()
        assembler.configure(components: components)
        return assembler
    }
}

extension AssemblerBootstrapper: Bootstrapper {

    func boot() {
        let assembler = DefaultAssembler()
        let components = makeComponents()
        assembler.configure(components: components)
        AppDelegate.assembler = assembler
    }
}

private extension AssemblerBootstrapper {
    
    func makeComponents() -> [AssemblerComponent] {
        [
            // Services
            SettingsServiceAssembler(),
            AddressServiceAssembler(),
            PollServiceAssembler(),
            ClipboardServiceAssembler(),
            SignerStoreServiceAssembler(),
            KeyChainServiceAssembler(),
            DegenServiceAssembler(),
            SignerStoreServiceAssembler(),
            KeyChainServiceAssembler(),
            NFTsServiceAssembler(),
            ReachabilityServiceAssembler(),
            CultServiceAssembler(),
            NodeServiceAssembler(),
            NetworksServiceAssembler(),
            CurrencyStoreServiceAssembler(),
            WalletServiceAssembler(),
            ActionsServiceAssembler(),
            ImprovementProposalsServiceAssembler(),
            EtherscanServiceAssembler(),
            PasswordServiceAssembler(),
            MnemonicServiceAssembler(),
            // DeepLink
            DeepLinkHandlerAssembler(),
            // Modules
            AuthenticateWireframeFactoryAssembler(),
            AccountWireframeFactoryAssembler(),
            AlertWireframeFactoryAssembler(),
            DashboardWireframeFactoryAssembler(),
            DegenWireframeFactoryAssembler(),
            SignersWireframeFactoryAssembler(),
            MnemonicNewWireframeFactoryAssembler(),
            MnemonicUpdateWireframeFactoryAssembler(),
            MnemonicImportWireframeFactoryAssembler(),
            MnemonicConfirmationWireframeFactoryAssembler(),
            PrvKeyImportWireframeFactoryAssembler(),
            PrvKeyUpdateWireframeFactoryAssembler(),
            NetworksWireframeFactoryAssembler(),
            NetworkSettingsWireframeFactoryAssembler(),
            NFTsDashboardWireframeFactoryAssembler(),
            NFTsCollectionWireframeFactoryAssembler(),
            NFTDetailWireframeFactoryAssembler(),
            NFTSendWireframeFactoryAssembler(),
            RootWireframeFactoryAssembler(),
            SettingsWireframeFactoryAssembler(),
            CultProposalsWireframeFactoryAssembler(),
            CultProposalWireframeFactoryAssembler(),
            CurrencyPickerWireframeFactoryAssembler(),
            CurrencyReceiveWireframeFactoryAssembler(),
            CurrencyAddWireframeFactoryAssembler(),
            CurrencySendWireframeFactoryAssembler(),
            CurrencySwapWireframeFactoryAssembler(),
            NetworkPickerWireframeFactoryAssembler(),
            QRCodeScanWireframeFactoryAssembler(),
            ConfirmationWireframeFactoryAssembler(),
            ProposalsWireframeFactoryAssembler(),
            ProposalWireframeFactoryAssembler(),
            ThemePickerWireframeFactoryAssembler(),
            MailServiceAssembler(),
            WebViewWireframeFactoryAssembler(),
            UniswapServiceAssembler()
        ]
    }
}
