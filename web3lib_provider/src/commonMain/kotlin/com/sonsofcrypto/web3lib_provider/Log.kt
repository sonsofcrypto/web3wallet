package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_core.AddressBytes
import com.sonsofcrypto.web3lib_utils.BigInt
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonArray

// Returns Array - Array of log objects, or an empty array if nothing has changed since last poll.
//
// For filters created with eth_newBlockFilter the return are block hashes (DATA, 32 Bytes), e.g. ["0x3454645634534..."].
// For filters created with eth_newPendingTransactionFilter the return are transaction hashes (DATA, 32 Bytes), e.g. ["0x6345343454645..."].
// For filters created with eth_newFilter logs are objects with following params:
// removed: TAG - true when the log was removed, due to a chain reorganization. false if its a valid log.
// logIndex: QUANTITY - integer of the log index position in the block. null when its pending log.
// transactionIndex: QUANTITY - integer of the transactions index position log was created from. null when its pending log.
// transactionHash: DATA, 32 Bytes - hash of the transactions this log was created from. null when its pending log.
// blockHash: DATA, 32 Bytes - hash of the block where this log was in. null when its pending. null when its pending log.
// blockNumber: QUANTITY - the block number where this log was in. null when its pending. null when its pending log.
// address: DATA, 20 Bytes - address from which this log originated.
// data: DATA - contains one or more 32 Bytes non-indexed arguments of the log.
// topics: Array of DATA - Array of 0 to 4 32 Bytes DATA of indexed log arguments. (In solidity: The first topic is the hash of the signature of the event (e.g. Deposit(address,bytes32,uint256)), except you declared the event with the anonymous specifier.)


data class Log(
    val blockNumber: BigInt,
    val blockHash: DataHexString,
    val transactionIndex: BigInt,
    val removed: Boolean,
    val address: Address.HexString,
    val data: DataHexString,
    val topics: List<DataHexString>,
    val transactionHash: DataHexString,
    val logIndex: BigInt,
) {
    companion object {

        @Throws(Throwable::class)
        fun fromHexifiedJsonObject(jsonObject: JsonObject): Log = Log(
            blockNumber = jsonObject.get("blockNumber")!!.stringValue().toBigIntQnt(),
            blockHash = jsonObject.get("blockHash")!!.stringValue(),
            transactionIndex = jsonObject.get("transactionIndex")!!.stringValue().toBigIntQnt(),
            removed = jsonObject.get("removed")!!.stringValue().toBoolean(),
            address = Address.fromHexString(
                jsonObject.get("address")!!.stringValue()
            )!!,
            data = jsonObject.get("data")!!.stringValue(),
            topics = jsonObject.get("topics")!!.jsonArray.map {
                (it as JsonElement).stringValue()
            },
            transactionHash = jsonObject.get("transactionHash")!!.stringValue(),
            logIndex = jsonObject.get("logIndex")!!.stringValue().toBigIntQnt(),
        )
    }
}