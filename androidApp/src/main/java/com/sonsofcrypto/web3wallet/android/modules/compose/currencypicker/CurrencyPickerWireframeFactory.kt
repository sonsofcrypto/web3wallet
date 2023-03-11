package com.sonsofcrypto.web3wallet.android.modules.compose.currencypicker

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerWireframe
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerWireframeContext
import smartadapter.internal.extension.name

interface CurrencyPickerWireframeFactory {
    fun make(parent: Fragment?, context: CurrencyPickerWireframeContext): CurrencyPickerWireframe
}

class DefaultCurrencyPickerWireframeFactory(
    private val walletService: WalletService,
    private val currencyStoreService: CurrencyStoreService,
): CurrencyPickerWireframeFactory {

    override fun make(
        parent: Fragment?, context: CurrencyPickerWireframeContext
    ): CurrencyPickerWireframe = DefaultCurrencyPickerWireframe(
        parent?.let { WeakRef(it) },
        context,
        walletService,
        currencyStoreService,
    )
}

class CurrencyPickerWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(CurrencyPickerWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultCurrencyPickerWireframeFactory(
                it.resolve(WalletService::class.name),
                it.resolve(CurrencyStoreService::class.name),
            )
        }
    }
}