package com.sonsofcrypto.web3wallet.android.modules.compose.currencyswap

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.uniswap.UniswapService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.assembler
import com.sonsofcrypto.web3wallet.android.common.NavigationFragment
import com.sonsofcrypto.web3wallet.android.modules.compose.currencysend.CurrencySendWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendWireframeContext
import com.sonsofcrypto.web3walletcore.modules.currencySwap.*
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.DefaultCultProposalsPresenter
import smartadapter.internal.extension.name

class DefaultCurrencySwapWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: CurrencySwapWireframeContext,
    private val walletService: WalletService,
    private val networksService: NetworksService,
    private val swapService: UniswapService,
    private val currencyStoreService: CurrencyStoreService,
): CurrencySwapWireframe {

    override fun present() {
        val fragment = wireUp()
        (parent?.get() as? NavigationFragment)?.push(fragment, animated = true)
    }

    override fun navigate(destination: CurrencySwapWireframeDestination) {

        val factory: CurrencySendWireframeFactory = assembler.resolve(
            CurrencySendWireframeFactory::class.name
        )
        val context = CurrencySendWireframeContext(
            Network.ethereum(), null, Currency.usdt()
        )
        factory.make(parent?.get(), context).present()
    }

    private fun wireUp(): Fragment {
        val view = CurrencySwapFragment()
        val interactor = DefaultCurrencySwapInteractor(
            walletService,
            networksService,
            swapService,
            currencyStoreService,
        )
        val presenter = DefaultCurrencySwapPresenter(
            WeakRef(view),
            this,
            interactor,
            context
        )
        view.presenter = presenter
        return view
    }
}