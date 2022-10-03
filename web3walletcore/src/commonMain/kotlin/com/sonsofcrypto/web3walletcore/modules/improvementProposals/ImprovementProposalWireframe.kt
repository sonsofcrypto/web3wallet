package com.sonsofcrypto.web3walletcore.modules.improvementProposals

import com.sonsofcrypto.web3lib.utils.WeakRef

sealed class ImprovementProposalsWireframeDestination {
    /** Votes on proposal */
    data class Vote(
        val proposal: ImprovementProposal
    ): ImprovementProposalsWireframeDestination()
    /** Navigate to proposal detail */
    data class Proposal(
        val proposal: ImprovementProposal,
        val categoryProposals: List<ImprovementProposal>
    ): ImprovementProposalsWireframeDestination()
    /** Dismiss proposals wireframe */
    object Dismiss: ImprovementProposalsWireframeDestination()
}

interface ImprovementProposalWireframe {
    fun present()
    fun navigate(destination: ImprovementProposalsWireframeDestination)
}
