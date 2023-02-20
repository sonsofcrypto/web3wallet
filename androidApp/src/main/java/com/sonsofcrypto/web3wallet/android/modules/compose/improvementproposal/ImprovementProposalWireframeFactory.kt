package com.sonsofcrypto.web3wallet.android.modules.compose.improvementproposal

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.improvementProposal.ImprovementProposalWireframe
import com.sonsofcrypto.web3walletcore.modules.improvementProposal.ImprovementProposalWireframeContext
import smartadapter.internal.extension.name

interface ImprovementProposalWireframeFactory {
    fun make(
        parent: Fragment?,
        context: ImprovementProposalWireframeContext,
    ): ImprovementProposalWireframe
}

class DefaultImprovementProposalWireframeFactory(
): ImprovementProposalWireframeFactory {

    override fun make(
        parent: Fragment?,
        context: ImprovementProposalWireframeContext,
    ): ImprovementProposalWireframe {

        return DefaultImprovementProposalWireframe(
            parent?.let { WeakRef(it) },
            context
        )
    }
}

class ImprovementProposalWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(ImprovementProposalWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultImprovementProposalWireframeFactory()
        }
    }
}