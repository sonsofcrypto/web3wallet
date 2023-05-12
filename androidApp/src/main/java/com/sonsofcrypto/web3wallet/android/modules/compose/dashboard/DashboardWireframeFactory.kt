package com.sonsofcrypto.web3wallet.android.modules.compose.dashboard

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3wallet.android.modules.compose.account.AccountWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencypicker.CurrencyPickerWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencyreceive.CurrencyReceiveWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencysend.CurrencySendWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencyswap.CurrencySwapWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.improvementproposals.ImprovementProposalsWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicconfirmation.MnemonicConfirmationWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.nftdetail.NFTDetailWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.qrcodescan.QRCodeScanWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframe
import com.sonsofcrypto.web3walletcore.services.actions.ActionsService
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService
import smartadapter.internal.extension.name

interface DashboardWireframeFactory {
    fun make(parent: Fragment?): DashboardWireframe
}

class DefaultDashboardWireframeFactory(
    private val networksService: NetworksService,
    private val currencyStoreService: CurrencyStoreService,
    private val walletService: WalletService,
    private val nftsService: NFTsService,
    private val actionsService: ActionsService,
    private val currencyReceiveWireframeFactory: CurrencyReceiveWireframeFactory,
    private val currencySendWireframeFactory: CurrencySendWireframeFactory,
    private val currencySwapWireframeFactory: CurrencySwapWireframeFactory,
    private val currencyPickerWireframeFactory: CurrencyPickerWireframeFactory,
    private val accountWireframeFactory: AccountWireframeFactory,
    private val nftDetailWireframeFactory: NFTDetailWireframeFactory,
    private val mnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory,
    private val improvementProposalsWireframeFactory: ImprovementProposalsWireframeFactory,
    private val qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
): DashboardWireframeFactory {

    override fun make(parent: Fragment?): DashboardWireframe = DefaultDashboardWireframe(
        parent?.let { WeakRef(it) },
        networksService,
        currencyStoreService,
        walletService,
        nftsService,
        actionsService,
        currencyReceiveWireframeFactory,
        currencySendWireframeFactory,
        currencySwapWireframeFactory,
        currencyPickerWireframeFactory,
        accountWireframeFactory,
        nftDetailWireframeFactory,
        mnemonicConfirmationWireframeFactory,
        improvementProposalsWireframeFactory,
        qrCodeScanWireframeFactory,
    )
}

class DashboardWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(DashboardWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultDashboardWireframeFactory(
                it.resolve(NetworksService::class.name),
                it.resolve(CurrencyStoreService::class.name),
                it.resolve(WalletService::class.name),
                it.resolve(NFTsService::class.name),
                it.resolve(ActionsService::class.name),
                it.resolve(CurrencyReceiveWireframeFactory::class.name),
                it.resolve(CurrencySendWireframeFactory::class.name),
                it.resolve(CurrencySwapWireframeFactory::class.name),
                it.resolve(CurrencyPickerWireframeFactory::class.name),
                it.resolve(AccountWireframeFactory::class.name),
                it.resolve(NFTDetailWireframeFactory::class.name),
                it.resolve(MnemonicConfirmationWireframeFactory::class.name),
                it.resolve(ImprovementProposalsWireframeFactory::class.name),
                it.resolve(QRCodeScanWireframeFactory::class.name),
            )
        }
    }
}