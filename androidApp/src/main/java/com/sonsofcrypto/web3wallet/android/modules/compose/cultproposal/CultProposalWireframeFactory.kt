package com.sonsofcrypto.web3wallet.android.modules.compose.cultproposal

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.degenCultProposal.CultProposalWireframe
import com.sonsofcrypto.web3walletcore.modules.degenCultProposal.CultProposalWireframeContext
import smartadapter.internal.extension.name

interface CultProposalWireframeFactory {
    fun make(parent: Fragment?, context: CultProposalWireframeContext): CultProposalWireframe
}

class DefaultCultProposalWireframeFactory: CultProposalWireframeFactory {

    override fun make(
        parent: Fragment?, context: CultProposalWireframeContext
    ): CultProposalWireframe = DefaultCultProposalWireframe(
        parent?.let { WeakRef(it) },
        context
    )
}

class CultProposalWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(CultProposalWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultCultProposalWireframeFactory()
        }
    }
}