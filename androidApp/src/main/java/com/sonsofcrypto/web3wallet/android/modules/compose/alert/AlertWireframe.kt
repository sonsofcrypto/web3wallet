package com.sonsofcrypto.web3wallet.android.modules.compose.alert

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3walletcore.modules.alert.AlertWireframe
import com.sonsofcrypto.web3walletcore.modules.alert.AlertWireframeContext
import com.sonsofcrypto.web3walletcore.modules.alert.AlertWireframeDestination
import com.sonsofcrypto.web3walletcore.modules.alert.DefaultAlertPresenter

class DefaultAlertWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: AlertWireframeContext,
): AlertWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.get()?.navigationFragment?.present(fragment)
    }

    override fun navigate(destination: AlertWireframeDestination) {
        when (destination) {
            is AlertWireframeDestination.Dismiss -> {
                parent?.get()?.navigationFragment?.dismiss()
            }
        }
    }

    private fun wireUp(): Fragment {
        val fragment = AlertFragment()
        val presenter = DefaultAlertPresenter(
            WeakRef(fragment),
            this,
            context
        )
        fragment.presenter = presenter
        return fragment
    }
}