package com.sonsofcrypto.web3wallet.android.modules.compose.currencysend

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3wallet.android.modules.compose.confirmation.ConfirmationWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencypicker.CurrencyPickerWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendWireframe
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendWireframeContext
import smartadapter.internal.extension.name

interface CurrencySendWireframeFactory {
    fun make(parent: Fragment?, context: CurrencySendWireframeContext): CurrencySendWireframe
}

class DefaultCurrencySendWireframeFactory(
    private val walletService: WalletService,
    private val networksService: NetworksService,
    private val currencyStoreService: CurrencyStoreService,
    private val currencyPickerWireframeFactory: CurrencyPickerWireframeFactory,
    private val confirmationWireframeFactory: ConfirmationWireframeFactory,
): CurrencySendWireframeFactory {

    override fun make(
        parent: Fragment?, context: CurrencySendWireframeContext
    ): CurrencySendWireframe = DefaultCurrencySendWireframe(
            parent?.let { WeakRef(it) },
            context,
            walletService,
            networksService,
            currencyStoreService,
            currencyPickerWireframeFactory,
            confirmationWireframeFactory,
        )
    }

class CurrencySendWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(CurrencySendWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultCurrencySendWireframeFactory(
                it.resolve(WalletService::class.name),
                it.resolve(NetworksService::class.name),
                it.resolve(CurrencyStoreService::class.name),
                it.resolve(CurrencyPickerWireframeFactory::class.name),
                it.resolve(ConfirmationWireframeFactory::class.name),
            )
        }
    }
}