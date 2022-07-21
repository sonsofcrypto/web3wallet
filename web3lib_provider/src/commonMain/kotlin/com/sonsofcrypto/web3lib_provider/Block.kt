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
    val transactions: List<Block.Transaction>,
) {
    sealed class Transaction {
        data class Hash(val value: DataHexString) : Transaction()
        data class TransactionResponse(val value: TransactionResponseTmp) : Transaction()
    }

    companion object {

        @Throws(Throwable::class)
        fun fromHexified(jsonObject: JsonObject): Block {
            return Block(
                hash = jsonObject.get("hash")!!.toString(),
                parentHash = jsonObject.get("parentHash")!!.toString(),
                number = jsonObject.get("number")!!.toString().toLongQnt(),
                timestamp = jsonObject.get("timestamp")!!.toString().toULongQnt(),
                nonce = jsonObject.get("nonce")!!.toString().toULongQnt(),
                difficulty = jsonObject.get("difficulty")!!.toString().toULongQnt(),
                gasLimit = jsonObject.get("gasLimit")!!.toString().toBigIntQnt(),
                gasUsed = jsonObject.get("gasUsed")!!.toString().toBigIntQnt(),
                miner = jsonObject.get("miner")!!.toString(),
                extraData = jsonObject.get("extraData")!!.toString(),
                baseFeePerGas = jsonObject.get("baseFeePerGas")?.toString()?.toBigIntQnt(),
                transactions = (jsonObject.get("transactions") as JsonArray).map {
                    when (it) {
                        is JsonObject -> Transaction.TransactionResponse(
                            TransactionResponseTmp.fromHexified(it)
                        )
                        else -> Transaction.Hash(it.toString())
                    }
                }
            )
        }
    }
}

