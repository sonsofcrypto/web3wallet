package com.sonsofcrypto.web3walletcore.modules.improvementProposal

import com.sonsofcrypto.web3walletcore.services.improvementProposals.ImprovementProposal

data class ImprovementProposalWireframeContext(
    /** All the proposal from given category */
    val proposals: List<ImprovementProposal>,
    /** Idx of selected proposal from array above */
    val selectedIdx: Int
)

sealed class ImprovementProposalWireframeDestination {
    /** Vote on proposal */
    data class Vote(
        val proposal: ImprovementProposal
    ): ImprovementProposalWireframeDestination()
    /** Dismissed wireframe */
    object Dismiss: ImprovementProposalWireframeDestination()
}

interface ImprovementProposalWireframe {
    /** Present proposal */
    fun present()
    /** Navigate to new destination screen */
    fun navigate(destination: ImprovementProposalWireframeDestination)
}