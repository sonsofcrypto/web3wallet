package com.sonsofcrypto.web3wallet.android.modules.degen

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3wallet.android.modules.cultproposals.CultProposalsWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.degen.DegenWireframe
import com.sonsofcrypto.web3walletcore.services.degen.DegenService

interface DegenNewWireframeFactory {
    fun make(parent: Fragment?): DegenWireframe
}

class DefaultDegenNewWireframeFactory(
    private val degenService: DegenService,
    private val networksService: NetworksService,
    private val cultProposalsWireframeFactory: CultProposalsWireframeFactory,
): DegenNewWireframeFactory {

    override fun make(parent: Fragment?): DegenWireframe =
        DefaultDegenNewWireframe(
            parent?.let { WeakRef(parent) },
            degenService,
            networksService,
            cultProposalsWireframeFactory,
        )
}

class DegenNewWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {
        to.register("DegenNewWireframeFactory", AssemblerRegistryScope.INSTANCE) {
            DefaultDegenNewWireframeFactory(
                it.resolve("DegenService"),
                it.resolve("NetworksService"),
                it.resolve("CultProposalsWireframeFactory")
            )
        }
    }
}