package com.sonsofcrypto.web3walletcore.modules.degenCultProposal

import com.sonsofcrypto.web3walletcore.services.cult.CultProposal

data class CultProposalWireframeContext(
    val proposal: CultProposal,
    val proposals: List<CultProposal>,
)

sealed class CultProposalWireframeDestination {
    object Dismiss: CultProposalWireframeDestination()
}

interface CultProposalWireframe {
    fun present()
    fun navigate(destination: CultProposalWireframeDestination)
}