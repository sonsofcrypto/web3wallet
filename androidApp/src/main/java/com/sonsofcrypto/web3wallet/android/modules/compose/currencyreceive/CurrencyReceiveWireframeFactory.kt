package com.sonsofcrypto.web3wallet.android.modules.compose.currencyreceive

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceiveWireframe
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceiveWireframeContext
import smartadapter.internal.extension.name

interface CurrencyReceiveWireframeFactory {
    fun make(parent: Fragment?, context: CurrencyReceiveWireframeContext): CurrencyReceiveWireframe
}

class DefaultCurrencyReceiveWireframeFactory(
    private val networksService: NetworksService,
): CurrencyReceiveWireframeFactory {

    override fun make(
        parent: Fragment?, context: CurrencyReceiveWireframeContext
    ): CurrencyReceiveWireframe = DefaultCurrencyReceiveWireframe(
            parent?.let { WeakRef(it) },
            context,
            networksService
        )
    }

class CurrencyReceiveWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {
        to.register(CurrencyReceiveWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultCurrencyReceiveWireframeFactory(
                it.resolve(NetworksService::class.name)
            )
        }
    }
}