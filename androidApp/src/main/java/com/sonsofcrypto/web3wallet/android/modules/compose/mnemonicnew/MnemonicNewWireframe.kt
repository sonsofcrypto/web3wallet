package com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicnew

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3walletcore.modules.mnemonicNew.*
import com.sonsofcrypto.web3walletcore.services.password.PasswordService
import com.sonsofcrypto.web3walletcore.services.settings.SettingsService

class DefaultMnemonicNewWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: MnemonicNewWireframeContext,
    private val keyStoreService: KeyStoreService,
    private val passwordService: PasswordService,
): MnemonicNewWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.get()?.navigationFragment?.push(fragment, animated = true)
    }

    override fun navigate(destination: MnemonicNewWireframeDestination) {
        println("Implement navigation to $destination")
    }

    private fun wireUp(): Fragment {
        val view = MnemonicNewFragment()
        val interactor = DefaultMnemonicNewInteractor(
            keyStoreService,
            passwordService,
        )
        val presenter = DefaultMnemonicNewPresenter(
            WeakRef(view),
            this,
            interactor,
            context,
        )
        view.presenter = presenter
        return view
    }
}