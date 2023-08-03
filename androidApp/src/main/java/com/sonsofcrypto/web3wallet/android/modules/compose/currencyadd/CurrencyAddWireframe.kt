package com.sonsofcrypto.web3wallet.android.modules.compose.currencyadd

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3wallet.android.common.ui.navigationFragment
import com.sonsofcrypto.web3walletcore.modules.currencyAdd.*

class DefaultCurrencyAddWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: CurrencyAddWireframeContext,
    private val currencyStoreService: CurrencyStoreService,
): CurrencyAddWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.navigationFragment?.push(fragment, animated = true)
    }

    override fun navigate(destination: CurrencyAddWireframeDestination) {
        when (destination) {
            is CurrencyAddWireframeDestination.NetworkPicker -> {
                println("Implement navigation to $destination")
            }
            is CurrencyAddWireframeDestination.Back -> {
                parent?.navigationFragment?.popOrDismiss()
            }
            is CurrencyAddWireframeDestination.Dismiss -> {
                parent?.navigationFragment?.dismiss()
            }
        }
    }

    private fun wireUp(): Fragment {
        val view = CurrencyAddFragment()
        val interactor = DefaultCurrencyAddInteractor(
            currencyStoreService,
        )
        val presenter = DefaultCurrencyAddPresenter(
            WeakRef(view),
            this,
            interactor,
            context,
        )
        view.presenter = presenter
        return view
    }
}