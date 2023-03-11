package com.sonsofcrypto.web3wallet.android.modules.compose.currencyswap

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.uniswap.UniswapService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapWireframe
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapWireframeContext
import smartadapter.internal.extension.name

interface CurrencySwapWireframeFactory {
    fun make(fragment: Fragment?, context: CurrencySwapWireframeContext): CurrencySwapWireframe
}

class DefaultCurrencySwapWireframeFactory(
    private val walletService: WalletService,
    private val networksService: NetworksService,
    private val swapService: UniswapService,
    private val currencyStoreService: CurrencyStoreService,
): CurrencySwapWireframeFactory {

    override fun make(
        fragment: Fragment?,
        context: CurrencySwapWireframeContext
    ): CurrencySwapWireframe = DefaultCurrencySwapWireframe(
        fragment?.let { WeakRef(it) },
        context,
        walletService,
        networksService,
        swapService,
        currencyStoreService,
    )
}

class CurrencySwapWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(CurrencySwapWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultCurrencySwapWireframeFactory(
                it.resolve(WalletService::class.name),
                it.resolve(NetworksService::class.name),
                it.resolve(UniswapService::class.name),
                it.resolve(CurrencyStoreService::class.name),
            )
        }
    }
}