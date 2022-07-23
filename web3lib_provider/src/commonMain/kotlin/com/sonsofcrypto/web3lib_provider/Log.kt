package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_core.jsonPrimitive
import com.sonsofcrypto.web3lib_utils.BigInt
import kotlinx.serialization.json.*


data class Log(
    val blockNumber: BigInt,
    val blockHash: DataHexString,
    val transactionIndex: BigInt,
    val removed: Boolean,
    val address: Address.HexString,
    val data: DataHexString,
    val topics: List<Topic>?,
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
                when (it) {
                    is JsonArray -> Topic.TopicList.fromHexifiedJsonObject(it)
                    else -> Topic.TopicValue.fromHexifiedJsonObject(it)
                }
            },
            transactionHash = jsonObject.get("transactionHash")!!.stringValue(),
            logIndex = jsonObject.get("logIndex")!!.stringValue().toBigIntQnt(),
        )

        fun fromHexifiedJsonObject(jsonArray: JsonArray): List<Any> {
            return jsonArray.map {
                when (it) {
                    is JsonObject -> Log.fromHexifiedJsonObject(it)
                    else -> it.stringValue()
                }
            }
        }

    }
}