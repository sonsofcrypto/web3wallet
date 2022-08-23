package com.sonsofcrypto.web3lib.utils

import com.sonsofcrypto.web3lib.provider.model.toBigIntData
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.extensions.toByteArray

private val abiParamLen = 32

fun abiEncode(address: Address.HexString): ByteArray {
    val addressBytes = address.hexString.hexStringToByteArray()
    return ByteArray(abiParamLen - addressBytes.size) + addressBytes
}

fun abiEncode(bigInt: BigInt): ByteArray {
    val bigIntBytes = bigInt.toByteArray()
    return ByteArray(abiParamLen - bigIntBytes.size) + bigIntBytes
}

fun abiEncode(uint: UInt): ByteArray {
    val uintBytes = uint.toByteArray()
    return ByteArray(abiParamLen - uintBytes.size) + uintBytes
}

fun abiDecodeBigInt(value: String): BigInt {
    var idx = 2
    while (value[idx] == '0' && idx<(value.length-2)) {  idx += 1 }
    var stripped = value.substring(idx)
    stripped = if (stripped.length % 2 == 0) stripped else "0" + stripped
    return stripped.toBigIntData()
}

fun abiDecodeAddress(value: String): Address.HexString {
    var idx = 2
    while (value[idx] == '0' && idx<(value.length-2)) {  idx += 1 }
    var stripped = value.substring(idx)
    stripped = if (stripped.length % 2 == 0) stripped else "0" + stripped
    return Address.HexString("0x" + stripped)
}

