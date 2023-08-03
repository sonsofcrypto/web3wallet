package com.sonsofcrypto.web3wallet.android.modules.compose.currencyreceive

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3wallet.android.common.ui.navigationFragment
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.*
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceiveWireframeDestination.Back
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceiveWireframeDestination.Dismiss

class DefaultCurrencyReceiveWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: CurrencyReceiveWireframeContext,
    private val networksService: NetworksService,
): CurrencyReceiveWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.navigationFragment?.push(fragment, animated = true)
    }

    override fun navigate(destination: CurrencyReceiveWireframeDestination) {
        when (destination) {
            Back -> { parent?.navigationFragment?.popOrDismiss() }
            Dismiss -> { parent?.navigationFragment?.dismiss() }
        }
    }

    private fun wireUp(): Fragment {
        val view = CurrencyReceiveFragment()
        val interactor = DefaultCurrencyReceiveInteractor(
            networksService
        )
        val presenter = DefaultCurrencyReceivePresenter(
            WeakRef(view),
            this,
            interactor,
            context
        )
        view.presenter = presenter
        return view
    }
}