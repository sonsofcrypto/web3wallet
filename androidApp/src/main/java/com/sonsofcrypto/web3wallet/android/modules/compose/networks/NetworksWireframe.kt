package com.sonsofcrypto.web3wallet.android.modules.compose.networks

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3walletcore.modules.networks.DefaultNetworksInteractor
import com.sonsofcrypto.web3walletcore.modules.networks.DefaultNetworksPresenter
import com.sonsofcrypto.web3walletcore.modules.networks.NetworksWireframe
import com.sonsofcrypto.web3walletcore.modules.networks.NetworksWireframeDestination

class DefaultNetworksWireframe(
    private val parent: WeakRef<Fragment>?,
    private val networksService: NetworksService,
): NetworksWireframe {

    override fun present() {
        val fragment = wireUp()
        println("[AA] Present networks module")
        parent?.get()?.navigationFragment?.push(fragment, animated = true)
    }

    override fun navigate(destination: NetworksWireframeDestination) {
        println("Implement navigation to $destination")
    }

    private fun wireUp(): Fragment {
        val view = NetworksFragment()
        val interactor = DefaultNetworksInteractor(
            networksService,
        )
        val presenter = DefaultNetworksPresenter(
            WeakRef(view),
            this,
            interactor,
        )
        view.presenter = presenter
        return view
    }
}