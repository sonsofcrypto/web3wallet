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
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3wallet.android.modules.compose.currencypicker.CurrencyPickerWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerWireframeContext
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerWireframeContext.NetworkData
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
        parent?.get()?.navigationFragment?.push(fragment, animated = true)
    }

    override fun navigate(destination: CurrencySwapWireframeDestination) {
        when (destination) {
            is CurrencySwapWireframeDestination.SelectCurrencyFrom -> {
                navigateToCurrencyPicker(destination.onCompletion)
            }
            is CurrencySwapWireframeDestination.SelectCurrencyTo -> {
                navigateToCurrencyPicker(destination.onCompletion)
            }
            else -> { println("[AA] Handle action -> $destination") }
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

    private fun navigateToCurrencyPicker(onCompletion: (Currency) -> Unit) {
        val factory: CurrencyPickerWireframeFactory = assembler.resolve(
            CurrencyPickerWireframeFactory::class.name
        )
        val context = CurrencyPickerWireframeContext(
            isMultiSelect = false,
            showAddCustomCurrency = false,
            networksData = listOf(
                NetworkData(Network.ethereum(), null, null)
            ),
            selectedNetwork = Network.ethereum(),
            handler = { result -> result.currency?.let { onCompletion(it) } }
        )
        factory.make(parent?.get(), context).present()
    }
}

private val List<CurrencyPickerWireframeContext.Result>.currency: Currency? get() = firstOrNull()
    ?.selectedCurrencies?.firstOrNull()