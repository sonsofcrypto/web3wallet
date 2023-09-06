package com.sonsofcrypto.web3walletcore.services.nfts

import kotlinx.serialization.Serializable

@Serializable
data class NFTCollection(
    val identifier: String,
    /** URL pointing to the cover image for this collection **/
    val coverImage: String?,
    /** Title for the collection **/
    val title: String,
    /** Author of the collection **/
    val author: String?,
    /** Flag determine if the account is verified or not **/
    val isVerifiedAccount: Boolean,
    /** URL pointing to the author image of the collection **/
    val authorImage: String?,
    /** Description of the collection **/
    val description: String?,
)