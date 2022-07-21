package com.sonsofcrypto.web3lib_core

import kotlinx.serialization.json.JsonPrimitive

typealias AddressBytes = ByteArray

/** Address */
sealed class Address() {
    data class BytesAddress(val data: AddressBytes) : Address()
    data class HexStringAddress(val hexString: String) : Address()
    data class NameAddress(val name: String) : Address()
}

fun Address.jsonPrimitive(): JsonPrimitive = when (this) {
    is Address.HexStringAddress -> JsonPrimitive(hexString)
    is Address.BytesAddress -> TODO("Convert to hex string format")
    else -> JsonPrimitive("")
}