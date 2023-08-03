package com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicconfirmation

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3wallet.android.common.ui.navigationFragment
import com.sonsofcrypto.web3walletcore.app.App
import com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation.DefaultMnemonicConfirmationInteractor
import com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation.DefaultMnemonicConfirmationPresenter
import com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation.MnemonicConfirmationWireframe
import com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation.MnemonicConfirmationWireframeDestination
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.MnemonicImportWireframeDestination
import com.sonsofcrypto.web3walletcore.services.actions.ActionsService
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicService

class DefaultMnemonicConfirmationWireframe(
    private val parent: WeakRef<Fragment>?,
    private val keyStoreService: KeyStoreService,
    private val actionsService: ActionsService,
    private val mnemonicService: MnemonicService,
): MnemonicConfirmationWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.navigationFragment?.present(fragment, animated = true)
    }

    override fun navigate(destination: MnemonicConfirmationWireframeDestination) {
        when (destination) {
            is MnemonicConfirmationWireframeDestination.Dismiss -> {
                parent?.navigationFragment?.popOrDismiss()
            }
        }
    }

    private fun wireUp(): Fragment {
        val view = MnemonicConfirmationFragment()
        val interactor = DefaultMnemonicConfirmationInteractor(
            keyStoreService,
            actionsService,
            mnemonicService,
        )
        val presenter = DefaultMnemonicConfirmationPresenter(
            WeakRef(view),
            this,
            interactor,
        )
        view.presenter = presenter
        return view
    }
}