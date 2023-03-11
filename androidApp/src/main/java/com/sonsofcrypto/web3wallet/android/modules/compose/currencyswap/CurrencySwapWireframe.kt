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
import com.sonsofcrypto.web3wallet.android.modules.compose.currencypicker.CurrencyPickerWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencyreceive.CurrencyReceiveWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencysend.CurrencySendWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerWireframeContext
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerWireframeContext.NetworkData
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceiveWireframeContext
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendWireframeContext
import com.sonsofcrypto.web3walletcore.modules.currencySwap.*
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
        when (destination) {
            is CurrencySwapWireframeDestination.SelectCurrencyFrom -> {
                val factory: CurrencyPickerWireframeFactory = assembler.resolve(
                    CurrencyPickerWireframeFactory::class.name
                )
                val context = CurrencyPickerWireframeContext(
                    isMultiSelect = false,
                    showAddCustomCurrency = true,
                    networksData = listOf(
                        NetworkData(Network.ethereum(), null, null)
                    ),
                    selectedNetwork = Network.ethereum(),
                    handler = { result -> navigateToCurrencySend(result)}
                )
                factory.make(parent?.get(), context).present()
            }
            is CurrencySwapWireframeDestination.SelectCurrencyTo -> {
                val factory: CurrencyReceiveWireframeFactory = assembler.resolve(
                    CurrencyReceiveWireframeFactory::class.name
                )
                val context = CurrencyReceiveWireframeContext(
                    Network.ethereum(), Currency.usdt()
                )
                factory.make(parent?.get(), context).present()
            }
            else -> { println("[AA] Handle action...") }
        }
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

    private fun navigateToCurrencySend(result: List<CurrencyPickerWireframeContext.Result>) {
        val network = result.firstOrNull()?.network ?: return
        val currency = result.firstOrNull()?.selectedCurrencies?.firstOrNull() ?: return
        val factory: CurrencySendWireframeFactory = assembler.resolve(
            CurrencySendWireframeFactory::class.name
        )
        val context = CurrencySendWireframeContext(
            network, null, currency
        )
        factory.make(parent?.get(), context).present()
    }
}