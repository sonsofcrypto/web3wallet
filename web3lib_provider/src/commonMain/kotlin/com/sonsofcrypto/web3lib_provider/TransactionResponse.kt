package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_utils.BigInt
import kotlinx.serialization.json.JsonObject

interface TransactionResponse {
    val hash: String
    val blockNumber: UInt?
    val blockHash: String?
    val timestamp: Double?
    val confirmations: UInt
    val from: Address
    val raw: ByteArray?
    val gasLimit: BigInt?
    val gasPrice: BigInt?
}

data class TransactionResponseTmp(
    val hash: DataHexString,
    val address: Address
) {
    companion object {

        @Throws(Throwable::class)
        fun fromHexified(jsonObject: JsonObject): TransactionResponseTmp = TransactionResponseTmp(
            hash = jsonObject.get("hash")!!.toString(),
            address = Address.HexStringAddress(jsonObject.get("address")!!.toString())
        )
    }
}
