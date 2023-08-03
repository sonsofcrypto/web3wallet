package com.sonsofcrypto.web3walletcore.modules.improvementProposal

import com.sonsofcrypto.web3walletcore.services.improvementProposals.ImprovementProposal

data class ImprovementProposalWireframeContext(
    /** Proposal to display details of */
    val proposal: ImprovementProposal,
)

sealed class ImprovementProposalWireframeDestination {
    /** Vote on proposal */
    data class Vote(
        val proposal: ImprovementProposal
    ): ImprovementProposalWireframeDestination()
    /** Dismissed wireframe */
    object Back: ImprovementProposalWireframeDestination()
    object Dismiss: ImprovementProposalWireframeDestination()
}

interface ImprovementProposalWireframe {
    /** Present proposal */
    fun present()
    /** Navigate to new destination screen */
    fun navigate(destination: ImprovementProposalWireframeDestination)
}