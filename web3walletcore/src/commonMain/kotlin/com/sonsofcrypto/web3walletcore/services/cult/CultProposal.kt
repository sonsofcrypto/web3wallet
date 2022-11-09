package com.sonsofcrypto.web3walletcore.services.cult

import kotlinx.serialization.Serializable

@Serializable
data class CultProposal(
    val id: String,
    val title: String,
    val approved: Double,
    val rejected: Double,
    val endDate: Double, // timeIntervalSince1970
    val guardianInfo: GuardianInfo?,
    val projectSummary: String,
    val projectDocuments: List<ProjectDocuments>,
    val cultReward: String,
    val rewardDistributions: String,
    val wallet: String,
    val status: Status,
    val stateName: String,
) {
    @Serializable
    data class GuardianInfo(
        val proposal: String, // aka: name
        val discord: String,
        val address: String,
    )

    @Serializable
    data class ProjectDocuments(
        val name : String,
        val documents: List<Document>,
    ) {
        @Serializable
        sealed class Document {
            @Serializable
            data class Link(val displayName: String, val url: String): Document()
            @Serializable
            data class Note(val note: String): Document()
        }
    }

    @Serializable
    enum class Status { PENDING, CLOSED }
}
