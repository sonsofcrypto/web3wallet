package com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicimport

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.*
import com.sonsofcrypto.web3walletcore.modules.mnemonicNew.*
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicService
import com.sonsofcrypto.web3walletcore.services.password.PasswordService

class DefaultMnemonicImportWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: MnemonicImportWireframeContext,
    private val keyStoreService: KeyStoreService,
    private val mnemonicService: MnemonicService,
    private val passwordService: PasswordService,
): MnemonicImportWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.get()?.navigationFragment?.push(fragment, animated = true)
    }

    override fun navigate(destination: MnemonicImportWireframeDestination) {
        println("Implement navigation to $destination")
    }

    private fun wireUp(): Fragment {
        val view = MnemonicImportFragment()
        val interactor = DefaultMnemonicImportInteractor(
            keyStoreService,
            mnemonicService,
            passwordService,
        )
        val presenter = DefaultMnemonicImportPresenter(
            WeakRef(view),
            this,
            interactor,
            context,
        )
        view.presenter = presenter
        return view
    }
}