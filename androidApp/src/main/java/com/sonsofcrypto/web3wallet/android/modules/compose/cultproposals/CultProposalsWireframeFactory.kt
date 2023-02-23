package com.sonsofcrypto.web3wallet.android.modules.compose.cultproposals

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3wallet.android.modules.cultproposal.CultProposalWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsWireframe
import com.sonsofcrypto.web3walletcore.services.cult.CultService
import smartadapter.internal.extension.name

interface CultProposalsWireframeFactory {
    fun make(parent: Fragment?): CultProposalsWireframe
}

class DefaultCultProposalsWireframeFactory(
    private val cultService: CultService,
    private val walletService: WalletService,
    private val networksService: NetworksService,
    private val cultProposalWireframeFactory: CultProposalWireframeFactory
): CultProposalsWireframeFactory {

    override fun make(parent: Fragment?): CultProposalsWireframe = DefaultCultProposalsWireframe(
        parent?.let { WeakRef(it) },
        cultService,
        walletService,
        networksService,
        cultProposalWireframeFactory,
    )
}

class CultProposalsWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(CultProposalsWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultCultProposalsWireframeFactory(
                it.resolve(CultService::class.name),
                it.resolve(WalletService::class.name),
                it.resolve(NetworksService::class.name),
                it.resolve(CultProposalWireframeFactory::class.name),
            )
        }
    }
}