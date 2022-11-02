package com.sonsofcrypto.web3walletcore.services.nfts

import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.BigIntSerializer
import kotlinx.serialization.KSerializer
import kotlinx.serialization.Serializable
import kotlinx.serialization.Serializer
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder

@Serializable
data class NFTItem(
    /** Unique NFT identifier **/
    val identifier: String,
    /** Unique Collection identifier **/
    val collectionIdentifier: String,
    /** NFT name **/
    val name: String,
    /** List of properties **/
    val properties: List<Property>,
    /** URL pointing to the NFT image **/
    val image: String,
    /** Contract address of the NFT **/
    val address: String,
    /** Schema name **/
    val schemaName: String,
    /** Token id **/
    @Serializable(with = BigIntSerializer::class)
    val tokenId: BigInt,
    /** True if the NFT is known to be in the mempool pending for a transaction to be broadcasted */
    var inMemPool: Boolean,
) {

    @Serializable
    data class Property(
        /** Name **/
        val name: String,
        /** Value **/
        val value : String,
        /** Info **/
        val info: String,
    )
}
