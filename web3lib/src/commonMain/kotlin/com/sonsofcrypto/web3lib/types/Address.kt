package com.sonsofcrypto.web3lib.types

import com.sonsofcrypto.web3lib.provider.model.DataHexString
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

fun Address.toHexStringAddress(): Address.HexString = when (this) {
    is Address.HexString -> this
    is Address.Bytes -> Address.HexString(DataHexString(this.data))
    else -> TODO("Resolve name address")
}

fun Address.jsonPrimitive(): JsonPrimitive = when (this) {
    is Address.HexString -> JsonPrimitive(hexString)
    is Address.Bytes -> JsonPrimitive(DataHexString(data))
    else -> JsonPrimitive("")
}


