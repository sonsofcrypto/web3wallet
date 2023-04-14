package com.sonsofcrypto.web3wallet.android.common

import androidx.appcompat.app.AppCompatActivity
import com.sonsofcrypto.web3wallet.android.assembler
import com.sonsofcrypto.web3wallet.android.modules.compose.account.AccountWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.confirmation.ConfirmationWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.cultproposal.CultProposalWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.cultproposals.CultProposalsWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.currencyadd.CurrencyAddWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.currencypicker.CurrencyPickerWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.currencyreceive.CurrencyReceiveWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.currencysend.CurrencySendWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.currencyswap.CurrencySwapWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.dashboard.DashboardWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.degen.DegenWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.improvementproposal.ImprovementProposalWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.improvementproposals.ImprovementProposalsWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.keystore.KeyStoreWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicconfirmation.MnemonicConfirmationWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicimport.MnemonicImportWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicnew.MnemonicNewWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicupdate.MnemonicUpdateWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.networks.NetworksWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.nftdetail.NFTDetailWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.nftscollection.NFTsCollectionWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.nftsdashboard.NFTsDashboardWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.nftsend.NFTSendWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.compose.settings.SettingsWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.modules.root.RootWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.root.RootWireframeFactoryAssembler
import com.sonsofcrypto.web3wallet.android.services.*
import smartadapter.internal.extension.name

interface Bootstrapper {
    fun boot()
}

class MainBootstrapper(
    private val parent: AppCompatActivity?,
): Bootstrapper {

    override fun boot() {
        listOf(
            AssemblerBootstrapper(),
            UIBootstrapper(parent)
        ).forEach { it.boot() }
    }
}

private class AssemblerBootstrapper: Bootstrapper {

    override fun boot() {

        assembler.configure(
            listOf(
                // Services
                KeyValueStoreAssembler(),
                KeyStoreServiceAssembler(),
                KeyChainServiceAssembler(),
                ActionsServiceAssembler(),
                CurrencyStoreServiceAssembler(),
                NetworksServiceAssembler(),
                NFTsServiceAssembler(),
                WalletServiceAssembler(),
                NodeServiceAssembler(),
                DegenServiceAssembler(),
                CultServiceAssembler(),
                ImprovementProposalsServiceAssembler(),
                CoinGeckoServiceAssembler(),
                UniswapServiceAssembler(),
                PasswordServiceAssembler(),
                MnemonicServiceAssembler(),
                SettingsServiceAssembler(),
                SettingsServiceActionTriggerAssembler(),
                EtherScanServiceAssembler(),
                // Modules
                RootWireframeFactoryAssembler(),
                DegenWireframeFactoryAssembler(),
                // Compose
                KeyStoreWireframeFactoryAssembler(),
                NetworksWireframeFactoryAssembler(),
                DashboardWireframeFactoryAssembler(),
                AccountWireframeFactoryAssembler(),
                MnemonicNewWireframeFactoryAssembler(),
                MnemonicImportWireframeFactoryAssembler(),
                MnemonicUpdateWireframeFactoryAssembler(),
                MnemonicConfirmationWireframeFactoryAssembler(),
                CultProposalsWireframeFactoryAssembler(),
                CultProposalWireframeFactoryAssembler(),
                ImprovementProposalsWireframeFactoryAssembler(),
                ImprovementProposalWireframeFactoryAssembler(),
                NFTsDashboardWireframeFactoryAssembler(),
                NFTsCollectionWireframeFactoryAssembler(),
                NFTDetailWireframeFactoryAssembler(),
                NFTSendWireframeFactoryAssembler(),
                CurrencyAddWireframeFactoryAssembler(),
                CurrencyPickerWireframeFactoryAssembler(),
                CurrencyReceiveWireframeFactoryAssembler(),
                CurrencySendWireframeFactoryAssembler(),
                CurrencySwapWireframeFactoryAssembler(),
                SettingsWireframeFactoryAssembler(),
                ConfirmationWireframeFactoryAssembler(),
            )
        )
    }
}

private class UIBootstrapper(
    private val parent: AppCompatActivity?,
): Bootstrapper {

    override fun boot() {
        val rootWireframeFactory: RootWireframeFactory = assembler.resolve(RootWireframeFactory::class.name)
        rootWireframeFactory.make(parent).present()
    }
}