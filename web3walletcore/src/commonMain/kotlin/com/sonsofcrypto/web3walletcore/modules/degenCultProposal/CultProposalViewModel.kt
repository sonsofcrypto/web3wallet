package com.sonsofcrypto.web3walletcore.modules.degenCultProposal

data class CultProposalViewModel(
    val title: String,
    val proposals: List<ProposalDetails>,
    val selectedIndex : Int,
){
    data class ProposalDetails(
        val name: String,
        val status: Status,
        val guardianInfo: GuardianInfo?,
        val summary: Summary,
        val documentsInfo: DocumentsInfo,
        val tokenomics : Tokenomics,
    ) {
        data class GuardianInfo(
            val title: String,
            val name: String,
            val nameValue: String,
            val socialHandle: String,
            val socialHandleValue: String,
            val wallet: String,
            val walletValue: String,
        )

        enum class Status { PENDING, CLOSED }

        data class Summary(
            val title: String,
            val summary: String,
        )

        data class DocumentsInfo(
            val title: String,
            val documents: List<Document>,
        ) {
            data class Document(
                val title: String,
                val items: List<Item>,
            ) {
                sealed class Item {
                    data class Link(val displayName: String, val url: String): Item()
                    data class Note(val text: String): Item()
                }
            }
        }

        data class Tokenomics(
            val title: String,
            val rewardAllocation: String,
            val rewardAllocationValue: String,
            val rewardDistribution: String,
            val rewardDistributionValue: String,
            val projectETHWallet: String,
            val projectETHWalletValue: String,
        )
    }
}