package com.sonsofcrypto.web3wallet.android.modules.compose.currencyadd

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.currencyAdd.CurrencyAddWireframe
import com.sonsofcrypto.web3walletcore.modules.currencyAdd.CurrencyAddWireframeContext
import smartadapter.internal.extension.name


interface CurrencyAddWireframeFactory {
    fun make(parent: Fragment?, context: CurrencyAddWireframeContext): CurrencyAddWireframe
}

class DefaultCurrencyAddWireframeFactory(
    private val currencyStoreService: CurrencyStoreService,
): CurrencyAddWireframeFactory {

    override fun make(
        parent: Fragment?, context: CurrencyAddWireframeContext
    ): CurrencyAddWireframe = DefaultCurrencyAddWireframe(
        parent?.let { WeakRef(it) },
        context,
        currencyStoreService,
    )
}

class CurrencyAddWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(CurrencyAddWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultCurrencyAddWireframeFactory(
                it.resolve(CurrencyStoreService::class.name),
            )
        }
    }
}