package com.sonsofcrypto.web3wallet.android.modules.compose.confirmation

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3wallet.android.common.ui.navigationFragment
import com.sonsofcrypto.web3walletcore.modules.confirmation.*
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService

class DefaultConfirmationWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: ConfirmationWireframeContext,
    private val walletService: WalletService,
    private val nftsService: NFTsService,
    private val currencyStoreService: CurrencyStoreService,
): ConfirmationWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.navigationFragment?.push(fragment, animated = true)
    }

    override fun navigate(destination: ConfirmationWireframeDestination) {
        println("navigate(destination) -> $destination")
    }

    private fun wireUp(): Fragment {
        val view = ConfirmationFragment()
        val interactor = DefaultConfirmationInteractor(
            walletService,
            nftsService,
            currencyStoreService,
        )
        val presenter = DefaultConfirmationPresenter(
            WeakRef(view),
            this,
            interactor,
            context,
        )
        view.presenter = presenter
        return view
    }
}