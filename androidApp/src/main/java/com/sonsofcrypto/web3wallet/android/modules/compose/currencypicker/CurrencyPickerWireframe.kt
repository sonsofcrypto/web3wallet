package com.sonsofcrypto.web3wallet.android.modules.compose.currencypicker

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.NavigationFragment
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.*

class DefaultCurrencyPickerWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: CurrencyPickerWireframeContext,
    private val walletService: WalletService,
    private val currencyStoreService: CurrencyStoreService,
): CurrencyPickerWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.get()?.navigationFragment?.push(fragment, animated = true)
    }

    override fun navigate(destination: CurrencyPickerWireframeDestination) {
        when (destination) {
            is CurrencyPickerWireframeDestination.AddCustomCurrency -> {}
            is CurrencyPickerWireframeDestination.Dismiss -> {
                parent?.get()?.navigationFragment?.popOrDismiss()
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