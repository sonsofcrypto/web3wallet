package com.sonsofcrypto.web3wallet.android.modules.compose.account

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3wallet.android.modules.compose.currencyreceive.CurrencyReceiveWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencysend.CurrencySendWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencyswap.CurrencySwapWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.account.AccountWireframe
import com.sonsofcrypto.web3walletcore.modules.account.AccountWireframeContext
import com.sonsofcrypto.web3walletcore.services.etherScan.EtherScanService
import smartadapter.internal.extension.name

interface AccountWireframeFactory {
    fun make(parent: Fragment?, context: AccountWireframeContext): AccountWireframe
}

class DefaultAccountWireframeFactory(
    private val currencyReceiveWireframeFactory: CurrencyReceiveWireframeFactory,
    private val currencySendWireframeFactory: CurrencySendWireframeFactory,
    private val currencySwapWireframeFactory: CurrencySwapWireframeFactory,
    private val currencyStoreService: CurrencyStoreService,
    private val walletService: WalletService,
    private val etherScanService: EtherScanService,
): AccountWireframeFactory {

    override fun make(
        parent: Fragment?, context: AccountWireframeContext
    ): AccountWireframe = DefaultAccountWireframe(
        parent?.let { WeakRef(it) },
        context,
        currencyReceiveWireframeFactory,
        currencySendWireframeFactory,
        currencySwapWireframeFactory,
        currencyStoreService,
        walletService,
        etherScanService,
    )
}

class AccountWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(AccountWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultAccountWireframeFactory(
                it.resolve(CurrencyReceiveWireframeFactory::class.name),
                it.resolve(CurrencySendWireframeFactory::class.name),
                it.resolve(CurrencySwapWireframeFactory::class.name),
                it.resolve(CurrencyStoreService::class.name),
                it.resolve(WalletService::class.name),
                it.resolve(EtherScanService::class.name),
            )
        }
    }
}