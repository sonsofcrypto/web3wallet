package com.sonsofcrypto.web3walletcore.modules.improvementProposal

class ImprovementProposalViewModel(
    val title: String,
    val details: List<Details>,
    val selectedIndex: Int,
) {
    data class Details(
        val id: String,
        val name: String,
        val imageUrl: String,
        val status: String,
        val summary: Summary,
        val voteButton: String,
    )

    data class Summary(
        val title: String,
        val summary: String,
    )
}