package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_core.jsonPrimitive
import kotlinx.serialization.json.*

sealed class Topic {
    data class TopicList(val list: List<Topic>): Topic() {

        fun jsonPrimitive(): JsonArray = JsonArray(
            list.map {
                when(it) {
                    is TopicValue -> it.jsonPrimitive()
                    is TopicList -> it.jsonPrimitive()
                }
            }
        )

        companion object {

            @Throws(Throwable::class)
            fun fromHexifiedJsonObject(jsonArray: JsonArray): TopicList  {
                val decoded = jsonArray.map {
                    when (it) {
                        is JsonArray -> TopicList.fromHexifiedJsonObject(it)
                        else -> TopicValue.fromHexifiedJsonObject(it)
                    }
                }
                return TopicList(decoded)
            }
        }
    }

    data class TopicValue(val value: DataHexString?): Topic() {

        fun jsonPrimitive(): JsonElement {
            return if (value != null) JsonPrimitive(value) else JsonNull
        }

        companion object {

            @Throws(Throwable::class)
            fun fromHexifiedJsonObject(jsonElement: JsonElement): TopicValue {
                return when (jsonElement) {
                    is JsonNull -> TopicValue(null)
                    else -> TopicValue(jsonElement.stringValue())
                }
            }
        }
    }
}

data class FilterRequest(
    val fromBlock: BlockTag? = BlockTag.Earliest,
    val toBlock: BlockTag? = BlockTag.Latest,
    val address: Address.HexString?,
    val topics: List<Topic>?
) {

    fun toHexifiedJsonObject() : JsonObject = buildJsonObject {
        if (fromBlock != null) {
            put("fromBlock", fromBlock.jsonPrimitive())
        }
        if (toBlock != null) {
            put("toBlock", toBlock.jsonPrimitive())
        }
        if (address != null) {
            put("address", address.jsonPrimitive())
        }
        if (topics != null) {
            val encoded = topics.map {
                when (it) {
                    is Topic.TopicValue -> it.jsonPrimitive()
                    is Topic.TopicList -> it.jsonPrimitive()
                }
            }
            put("topics", JsonArray(encoded))
        } else put("topics", JsonArray(listOf()))
    }
}