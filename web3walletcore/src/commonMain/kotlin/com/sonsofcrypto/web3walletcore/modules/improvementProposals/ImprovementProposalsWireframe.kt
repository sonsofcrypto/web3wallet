package com.sonsofcrypto.web3walletcore.modules.improvementProposals

import com.sonsofcrypto.web3walletcore.services.improvementProposals.ImprovementProposal

sealed class ImprovementProposalsWireframeDestination {
    /** Votes on proposal */
    data class Vote(
        val proposal: ImprovementProposal
    ): ImprovementProposalsWireframeDestination()
    /** Navigate to proposal detail */
    data class Proposal(
        val proposal: ImprovementProposal,
    ): ImprovementProposalsWireframeDestination()
    /** Dismiss proposals wireframe */
    object Dismiss: ImprovementProposalsWireframeDestination()
}

interface ImprovementProposalsWireframe {
    /** Present module */
    fun present()
    /** Navigate to a new destination module */
    fun navigate(destination: ImprovementProposalsWireframeDestination)
}
