package com.sonsofcrypto.web3wallet.android.modules.compose.settings

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3wallet.android.common.ui.navigationFragment
import com.sonsofcrypto.web3walletcore.modules.settings.*
import com.sonsofcrypto.web3walletcore.services.settings.SettingsService
import com.sonsofcrypto.web3walletcore.services.settings.SettingsServiceActionTrigger

class DefaultSettingsWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: SettingsWireframeContext,
    private val settingsService: SettingsService,
    private val settingsServiceActionTrigger: SettingsServiceActionTrigger,
): SettingsWireframe {

    override fun present() {
        val fragment = wireUp(context)
        parent?.navigationFragment?.push(fragment, animated = true)
    }

    override fun navigate(destination: SettingsWireframeDestination) {
        when (destination) {
            is SettingsWireframeDestination.Settings -> {
                val fragment = wireUp(destination.context)
                parent?.navigationFragment?.push(fragment, animated = true)
            }
            is SettingsWireframeDestination.Dismiss -> {
                parent?.navigationFragment?.popOrDismiss()
            }
        }
    }

    private fun wireUp(context: SettingsWireframeContext): Fragment {
        val view = SettingsFragment()
        val interactor = DefaultSettingsInteractor(
            settingsService,
            settingsServiceActionTrigger,
        )
        val presenter = DefaultSettingsPresenter(
            WeakRef(view),
            this,
            interactor,
            context
        )
        view.presenter = presenter
        return view
    }
}