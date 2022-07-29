package com.sonsofcrypto.web3lib_core

import kotlinx.serialization.json.JsonPrimitive

typealias AddressBytes = ByteArray
typealias AddressHexString = String

/** Address */
sealed class Address() {
    data class Bytes(val data: AddressBytes) : Address()
    data class HexString(val hexString: String) : Address()
    data class Name(val name: String) : Address()

    companion object {
        fun fromHexString(hexString: String?): Address.HexString? {
            return if (hexString != null && hexString != "null") {
                HexString(hexString)
            } else null
        }
    }
}

fun Address.jsonPrimitive(): JsonPrimitive = when (this) {
    is Address.HexString -> JsonPrimitive(hexString)
    is Address.Bytes -> TODO("Convert to hex string format")
    else -> JsonPrimitive("")
}

