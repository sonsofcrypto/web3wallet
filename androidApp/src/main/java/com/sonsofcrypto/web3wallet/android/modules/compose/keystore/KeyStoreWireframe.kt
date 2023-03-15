package com.sonsofcrypto.web3wallet.android.modules.compose.keystore

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3walletcore.modules.keyStore.DefaultKeyStoreInteractor
import com.sonsofcrypto.web3walletcore.modules.keyStore.DefaultKeyStorePresenter
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStoreWireframe
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStoreWireframeDestination

class DefaultKeyStoreWireframe(
    private val parent: WeakRef<Fragment>?,
    private val keyStoreService: KeyStoreService,
    private val networksService: NetworksService,
): KeyStoreWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.get()?.navigationFragment?.push(fragment, animated = true)
    }

    override fun navigate(destination: KeyStoreWireframeDestination) {
        println("Implement navigation to $destination")
    }

    private fun wireUp(): Fragment {
        val view = KeyStoreFragment()
        val interactor = DefaultKeyStoreInteractor(
            keyStoreService,
            networksService,
        )
        val presenter = DefaultKeyStorePresenter(
            WeakRef(view),
            this,
            interactor,
        )
        view.presenter = presenter
        return view
    }
}