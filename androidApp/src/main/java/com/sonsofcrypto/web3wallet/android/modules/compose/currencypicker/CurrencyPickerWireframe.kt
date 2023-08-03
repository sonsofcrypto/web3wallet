package com.sonsofcrypto.web3wallet.android.modules.compose.currencypicker

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3wallet.android.common.ui.navigationFragment
import com.sonsofcrypto.web3wallet.android.modules.compose.currencyadd.CurrencyAddWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.currencyAdd.CurrencyAddWireframeContext
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.*

class DefaultCurrencyPickerWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: CurrencyPickerWireframeContext,
    private val walletService: WalletService,
    private val currencyStoreService: CurrencyStoreService,
    private val currencyAddWireframeFactory: CurrencyAddWireframeFactory,
): CurrencyPickerWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.navigationFragment?.present(fragment, animated = true)
    }

    override fun navigate(destination: CurrencyPickerWireframeDestination) {
        when (destination) {
            is CurrencyPickerWireframeDestination.AddCustomCurrency -> {
                val context = CurrencyAddWireframeContext(destination.network)
                currencyAddWireframeFactory.make(parent?.get(), context).present()
            }
            is CurrencyPickerWireframeDestination.Dismiss -> {
                parent?.navigationFragment?.popOrDismiss()
            }
        }
    }

    private fun wireUp(): Fragment {
        val view = CurrencyPickerFragment()
        val interactor = DefaultCurrencyPickerInteractor(
            walletService, currencyStoreService
        )
        val presenter = DefaultCurrencyPickerPresenter(
            WeakRef(view),
            this,
            interactor,
            context
        )
        view.presenter = presenter
        return view
    }
}