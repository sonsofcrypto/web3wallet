package com.sonsofcrypto.web3wallet.android.modules.compose.nftsend

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.NavigationFragment
import com.sonsofcrypto.web3wallet.android.modules.compose.confirmation.ConfirmationWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.nftSend.*

class DefaultNFTSendWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: NFTSendWireframeContext,
    private val networksService: NetworksService,
    private val currencyStoreService: CurrencyStoreService,
    private val confirmationWireframeFactory: ConfirmationWireframeFactory,
): NFTSendWireframe {

    private lateinit var fragment: WeakRef<Fragment>

    override fun present() {
        val fragment = wireUp()
        this.fragment = WeakRef(fragment)
        parent?.get()?.childFragmentManager?.beginTransaction()?.apply {
            add(R.id.container, fragment)
            commitNow()
        }
    }

    override fun navigate(destination: NFTSendWireframeDestination) {
        when (destination) {
            is NFTSendWireframeDestination.UnderConstructionAlert -> {}
            is NFTSendWireframeDestination.QRCodeScan -> {
                println("[AA] Implement -> navigateTo $destination")
            }
            is NFTSendWireframeDestination.ConfirmSendNFT -> {
                confirmationWireframeFactory.make(
                    parent = parent?.get(),
                    context = destination.context
                ).present()
            }
            is NFTSendWireframeDestination.Dismiss -> {
                println("[AA] Implement -> navigateTo $destination")
            }
        }
    }

    private fun wireUp(): Fragment {
        val view = NFTSendFragment()
        val interactor = DefaultNFTSendInteractor(
            networksService,
            currencyStoreService,
        )
        val presenter = DefaultNFTSendPresenter(
            WeakRef(view),
            this,
            interactor,
            context,
        )
        view.presenter = presenter
        return NavigationFragment(view)
    }
}