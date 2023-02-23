package com.sonsofcrypto.web3wallet.android.modules.compose.cultproposals

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.NavigationFragment
import com.sonsofcrypto.web3wallet.android.modules.cultproposal.CultProposalWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.degenCultProposal.CultProposalWireframeContext
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsWireframe
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsWireframeDestination
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.DefaultCultProposalsInteractor
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.DefaultCultProposalsPresenter
import com.sonsofcrypto.web3walletcore.services.cult.CultService

class DefaultCultProposalsWireframe(
    private val parent: WeakRef<Fragment>?,
    private val cultService: CultService,
    private val walletService: WalletService,
    private val networksService: NetworksService,
    private val cultProposalWireframeFactory: CultProposalWireframeFactory,
): CultProposalsWireframe {

    override fun present() {
        val fragment = wireUp()
        (parent?.get() as? NavigationFragment)?.push(fragment, animated = true)
    }

    override fun navigate(destination: CultProposalsWireframeDestination) {
        when (destination) {
            is CultProposalsWireframeDestination.Proposal -> {
                val context = CultProposalWireframeContext(
                    destination.proposal, destination.proposals
                )
                cultProposalWireframeFactory.make(parent?.get(), context).present()
            }
            else -> { println("handle event $destination")}
        }
    }

    private fun wireUp(): Fragment {
        val view = CultProposalsFragment()
        val interactor = DefaultCultProposalsInteractor(
            cultService, walletService
        )
        val presenter = DefaultCultProposalsPresenter(
            WeakRef(view),
            this,
            interactor
        )
        view.presenter = presenter
        return view
    }
}