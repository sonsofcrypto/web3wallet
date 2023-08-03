package com.sonsofcrypto.web3wallet.android.modules.compose.nftsdashboard

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.NavigationFragment
import com.sonsofcrypto.web3wallet.android.common.ui.navigationFragment
import com.sonsofcrypto.web3wallet.android.modules.compose.nftdetail.NFTDetailWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.nftscollection.DefaultNFTsCollectionWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.nftDetail.NFTDetailWireframeContext
import com.sonsofcrypto.web3walletcore.modules.nftsCollection.NFTsCollectionWireframeContext
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.DefaultNFTsDashboardInteractor
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.DefaultNFTsDashboardPresenter
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardWireframe
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardWireframeDestination
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService

class DefaultNFTsDashboardWireframe(
    private val parent: WeakRef<Fragment>?,
    private val networksService: NetworksService,
    private val nftsService: NFTsService,
    private val nftsCollectionWireframeFactory: DefaultNFTsCollectionWireframeFactory,
    private val nftDetailWireframeFactory: NFTDetailWireframeFactory
): NFTsDashboardWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.navigationFragment?.push(fragment)
    }

    override fun navigate(destination: NFTsDashboardWireframeDestination) {
        when (destination) {
            is NFTsDashboardWireframeDestination.ViewCollectionNFTs -> {
                nftsCollectionWireframeFactory.make(
                    parent?.get(),
                    NFTsCollectionWireframeContext(destination.collectionId)
                ).present()
            }
            is NFTsDashboardWireframeDestination.ViewNFT -> {
                val context = NFTDetailWireframeContext(
                    destination.nftItem.identifier, destination.nftItem.collectionIdentifier
                )
                nftDetailWireframeFactory.make(parent?.get(), context).present()
            }
            is NFTsDashboardWireframeDestination.SendError -> {

            }
        }
    }

    private fun wireUp(): Fragment {
        val view = NFTsDashboardFragment()
        val interactor = DefaultNFTsDashboardInteractor(
            networksService,
            nftsService,
        )
        val presenter = DefaultNFTsDashboardPresenter(
            WeakRef(view),
            this,
            interactor,
        )
        view.presenter = presenter
        return NavigationFragment(view)
    }
}