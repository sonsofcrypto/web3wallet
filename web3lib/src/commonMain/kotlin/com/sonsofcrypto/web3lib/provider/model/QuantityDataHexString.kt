package com.sonsofcrypto.web3lib.provider.model

import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.toHexString
import kotlinx.serialization.json.JsonPrimitive

/** SEE: https://ethereum.org/en/developers/docs/apis/json-rpc/#quantities-encoding */
typealias QuantityHexString = String

fun QuantityHexString.toIntQnt(): Int = this.stripPrefixPad().toInt(16)
fun QuantityHexString.toUIntQnt(): UInt = this.stripPrefixPad().toUInt(16)
fun QuantityHexString.toLongQnt(): Long = this.stripPrefixPad().toLong(16)
fun QuantityHexString.toULongQnt(): ULong = this.stripPrefixPad().toULong(16)
fun QuantityHexString.toBigIntQnt(): BigInt = BigInt.from(this.stripPrefixPad(), 16)
fun QuantityHexString.toByteArrayQnt(): ByteArray = this.stripPrefixPad().hexStringToByteArray()

fun QuantityHexString(int: Int): QuantityHexString = int.toString(16).addPrefixPad()
fun QuantityHexString(uint: UInt): QuantityHexString = uint.toString(16).addPrefixPad()
fun QuantityHexString(long: Long): QuantityHexString = long.toString(16).addPrefixPad()
fun QuantityHexString(ulong: ULong): QuantityHexString = ulong.toString(16).addPrefixPad()
fun QuantityHexString(bigInt: BigInt): QuantityHexString = bigInt.toHexString().addPrefixPad()

/**
 * QuantityHexString (part of JsonRpc) should have no leading zeros
 * SEE: https://ethereum.org/en/developers/docs/apis/json-rpc/#quantities-encoding
 */
fun QuantityHexString.stripPrefixPad(): String {
    return (if (this.length % 2 != 0) "0"  else "") + this.substring(2)
}

/**
 * QuantityHexString (part of JsonRpc) should have no leading zeros
 * SEE: https://ethereum.org/en/developers/docs/apis/json-rpc/#quantities-encoding
 */
fun QuantityHexString.addPrefixPad(): String {
    return (
        if (this.first().toString() == "0" && this.length > 1) this.substring(1)
        else this
    ).addPrefix()
}

fun QuantityHexString.addPrefix(): String {
    return if (length == 1 || (length > 1 && substring(0, 2) != "0x")) "0x" + this else this
}

fun QuantityHexString.jsonPrimitive(): JsonPrimitive = JsonPrimitive(this)

/** SEE: https://ethereum.org/en/developers/docs/apis/json-rpc/#unformatted-data-encoding */
typealias DataHexString = String

@OptIn(kotlin.ExperimentalUnsignedTypes::class)
fun DataHexString(byteArray: ByteArray): DataHexString = byteArray.toHexString(true)

fun DataHexString.toByteArrayData(): ByteArray = hexStringToByteArray()
fun DataHexString.toBigIntData(): BigInt = BigInt.from(this, 16)
