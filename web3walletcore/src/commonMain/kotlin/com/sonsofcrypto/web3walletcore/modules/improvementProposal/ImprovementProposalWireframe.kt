package com.sonsofcrypto.web3walletcore.modules.improvementProposal

import com.sonsofcrypto.web3walletcore.services.improvementProposals.ImprovementProposal

data class ImprovementProposalContext(
    val proposal: ImprovementProposal,
    val proposals: List<ImprovementProposal>
)

sealed class ImprovementProposalWireframeDestination {
    /** Vote on proposal */
    data class Vote(val proposal: ImprovementProposal): ImprovementProposalWireframeDestination()
}

interface ImprovementProposalWireframe {
    /** Present proposal */
    fun present()
    /** Navigate to new destination screen */
    fun navigate(destination: ImprovementProposalWireframeDestination)
    /** Dismiss proposal*/
    fun dismiss()
}