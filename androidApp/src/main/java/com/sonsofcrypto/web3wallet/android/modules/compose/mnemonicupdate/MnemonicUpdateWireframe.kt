package com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicupdate

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.*

class DefaultMnemonicUpdateWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: MnemonicUpdateWireframeContext,
    private val keyStoreService: KeyStoreService,
): MnemonicUpdateWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.get()?.navigationFragment?.push(fragment, animated = true)
    }

    override fun navigate(destination: MnemonicUpdateWireframeDestination) {
        println("Implement navigation to $destination")
    }

    private fun wireUp(): Fragment {
        val view = MnemonicUpdateFragment()
        val interactor = DefaultMnemonicUpdateInteractor(
            keyStoreService,
        )
        val presenter = DefaultMnemonicUpdatePresenter(
            WeakRef(view),
            this,
            interactor,
            context,
        )
        view.presenter = presenter
        return view
    }
}