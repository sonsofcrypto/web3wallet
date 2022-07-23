package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_utils.BigInt
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonObject

data class Block(
    val hash: DataHexString,
    val parentHash: DataHexString,
    val number: Long,
    val timestamp: ULong,
    val nonce: ULong,
    val difficulty: ULong,
    val gasLimit: BigInt,
    val gasUsed: BigInt,
    val miner: DataHexString,
    val extraData: DataHexString,
    val baseFeePerGas: BigInt?,
    val transactions: List<BlockTransaction>,
) {
    sealed class BlockTransaction {
        data class Hash(val value: DataHexString) : BlockTransaction()
        data class Object(val value: Transaction) : BlockTransaction()
    }

    companion object {

        @Throws(Throwable::class)
        fun fromHexified(jsonObject: JsonObject): Block {
            return Block(
                hash = jsonObject.get("hash")!!.stringValue(),
                parentHash = jsonObject.get("parentHash")!!.stringValue(),
                number = jsonObject.get("number")!!.stringValue().toLongQnt(),
                timestamp = jsonObject.get("timestamp")!!.stringValue().toULongQnt(),
                nonce = jsonObject.get("nonce")!!.stringValue().toULongQnt(),
                difficulty = jsonObject.get("difficulty")!!.stringValue().toULongQnt(),
                gasLimit = jsonObject.get("gasLimit")!!.stringValue().toBigIntQnt(),
                gasUsed = jsonObject.get("gasUsed")!!.stringValue().toBigIntQnt(),
                miner = jsonObject.get("miner")!!.stringValue(),
                extraData = jsonObject.get("extraData")!!.stringValue(),
                baseFeePerGas = jsonObject.get("baseFeePerGas")?.stringValue()?.toBigIntQnt(),
                transactions = (jsonObject.get("transactions") as JsonArray).map {
                    when (it) {
                        is JsonObject -> BlockTransaction.Object(
                            Transaction.fromHexifiedJsonObject(it)
                        )
                        else -> BlockTransaction.Hash(it.stringValue())
                    }
                }
            )
        }
    }
}


