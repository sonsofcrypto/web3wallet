package com.sonsofcrypto.web3walletcore.modules.improvementProposal

class ImprovementProposalViewModel(
    val proposals: List<Proposal>,
    val selectedIdx: Int,
) {
    data class Proposal(
        val id: String,
        val name: String,
        val imageUrl: String,
        val status: String,
        val body: String,
    )
}