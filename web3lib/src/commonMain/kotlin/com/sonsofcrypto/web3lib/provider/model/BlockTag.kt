package com.sonsofcrypto.web3lib.provider.model

import kotlinx.serialization.json.JsonPrimitive

/** Block tag */
sealed class BlockTag() {
    object Earliest : BlockTag()
    object Latest : BlockTag()
    object Pending : BlockTag()
    data class Number(val number: Long) : BlockTag()
    data class Hash(val hash: String) : BlockTag()

    fun jsonPrimitive(): JsonPrimitive = when (this) {
        Earliest -> JsonPrimitive("earliest")
        Latest -> JsonPrimitive("latest")
        Pending -> JsonPrimitive("pending")
        is Number -> JsonPrimitive(QuantityHexString(number))
        is Hash -> JsonPrimitive(hash)
    }
}