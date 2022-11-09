package com.sonsofcrypto.web3walletcore.modules.degenCultProposals

import com.sonsofcrypto.web3walletcore.modules.alert.AlertWireframeContext
import com.sonsofcrypto.web3walletcore.services.cult.CultProposal

sealed class CultProposalsWireframeDestination {
    data class Proposal(
        val proposal: CultProposal, val proposals: List<CultProposal>
        ): CultProposalsWireframeDestination()
    data class CastVote(
        val proposal: CultProposal, val approve: Boolean
        ): CultProposalsWireframeDestination()
    data class Alert(val context: AlertWireframeContext): CultProposalsWireframeDestination()
    object GetCult: CultProposalsWireframeDestination()
}

interface CultProposalsWireframe {
    fun present()
    fun navigate(destination: CultProposalsWireframeDestination)
}