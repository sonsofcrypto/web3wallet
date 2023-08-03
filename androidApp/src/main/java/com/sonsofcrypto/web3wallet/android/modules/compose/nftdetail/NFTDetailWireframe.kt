package com.sonsofcrypto.web3wallet.android.modules.compose.nftdetail

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.NavigationFragment
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3wallet.android.common.ui.navigationFragment
import com.sonsofcrypto.web3wallet.android.modules.compose.confirmation.ConfirmationWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.nftsend.NFTSendWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.confirmation.ConfirmationWireframeContext
import com.sonsofcrypto.web3walletcore.modules.nftDetail.*
import com.sonsofcrypto.web3walletcore.modules.nftDetail.NFTDetailWireframeDestination.Back
import com.sonsofcrypto.web3walletcore.modules.nftDetail.NFTDetailWireframeDestination.Send
import com.sonsofcrypto.web3walletcore.modules.nftSend.NFTSendWireframeContext
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService

class DefaultNFTDetailWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: NFTDetailWireframeContext,
    private val nftsService: NFTsService,
    private val nftSendWireframeFactory: NFTSendWireframeFactory,
    private val networksService: NetworksService,
): NFTDetailWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.navigationFragment?.push(fragment, true)
    }

    override fun navigate(destination: NFTDetailWireframeDestination) {
        when (destination) {
            is Send -> {
                val network = networksService.network ?: return
                val context = NFTSendWireframeContext(
                    network = network,
                    nftItem = destination.nft
                )
                nftSendWireframeFactory.make(
                    parent = parent?.get(),
                    context = context
                ).present()
            }
            is Back -> { parent?.navigationFragment?.popOrDismiss() }
        }
    }

    private fun wireUp(): Fragment {
        val view = NFTDetailFragment()
        val interactor = DefaultNFTDetailInteractor(
            nftService = nftsService
        )
        val presenter = DefaultNFTDetailPresenter(
            WeakRef(view),
            this,
            interactor,
            context,
        )
        view.presenter = presenter
        return view
    }
}