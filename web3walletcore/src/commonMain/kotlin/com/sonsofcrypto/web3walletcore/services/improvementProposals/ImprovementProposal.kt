package com.sonsofcrypto.web3walletcore.services.improvementProposals

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ImprovementProposal(
    val id: String,
    val title: String,
    val body: String,
    val category: Category,
    @SerialName("at_account")
    val atAccount: String?,
    val tweet: String,
    @SerialName("image_url")
    val imageUrl: String,
    @SerialName("page_url")
    val pageUrl: String,
    val votes: Int,
) {

    @Serializable
    enum class Category(val string: String) {
        @SerialName("infrastructure") INFRASTRUCTURE("infrastructure"),
        @SerialName("integration") INTEGRATION("integration"),
        @SerialName("feature") FEATURE("feature"),
        @SerialName("unknown") UNKNOWN("unknown"),
     }
}
