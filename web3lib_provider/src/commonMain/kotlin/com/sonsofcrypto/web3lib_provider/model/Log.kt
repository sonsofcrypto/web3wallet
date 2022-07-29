package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_provider.model.stringValue
import com.sonsofcrypto.web3lib_provider.model.toBigIntQnt
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
) { companion object }

@Throws(Throwable::class)
fun Log.Companion.fromHexifiedJsonObject(jsonObject: JsonObject): Log = Log(
    blockNumber = jsonObject["blockNumber"]!!.toBigIntQnt(),
    blockHash = jsonObject["blockHash"]!!.stringValue(),
    transactionIndex = jsonObject["transactionIndex"]!!.toBigIntQnt(),
    removed = jsonObject["removed"]!!.stringValue().toBoolean(),
    address = Address.fromHexString(jsonObject["address"]!!.stringValue())!!,
    data = jsonObject["data"]!!.stringValue(),
    topics = jsonObject["topics"]!!.jsonArray.map {
        when (it) {
            is JsonArray -> Topic.TopicList.fromHexifiedJsonObject(it)
            else -> Topic.TopicValue.fromHexifiedJsonObject(it)
        }
    },
    transactionHash = jsonObject["transactionHash"]!!.stringValue(),
    logIndex = jsonObject["logIndex"]!!.toBigIntQnt(),
)

@Throws(Throwable::class)
fun Log.Companion.fromHexifiedJsonObject(jsonArray: JsonArray): List<Any> {
    return jsonArray.map {
        when (it) {
            is JsonObject -> Log.fromHexifiedJsonObject(it)
            else -> it.stringValue()
        }
    }
}
