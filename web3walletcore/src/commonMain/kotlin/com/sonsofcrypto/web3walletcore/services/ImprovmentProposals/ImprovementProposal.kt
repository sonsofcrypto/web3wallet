package com.sonsofcrypto.web3walletcore.services.ImprovmentProposals

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ImprovementProposal(
    val id: String,
    val title: String,
    val body: String,
    val category: Category,
    @SerialName("at_account")
    val atAccount: String,
    val tweet: String,
    @SerialName("image_url")
    val imageUrl: String,
    @SerialName("page_url")
    val pageUrl: String,
    val votes: Int,
) {

    @Serializable
    enum class Category(val string: String) {
        INFRASTRUCTURE("infrastructure"),
        INTEGRATION("integration"),
        FEATURE("feature"),
        UNKNOWN("unknown"),
     }
}
