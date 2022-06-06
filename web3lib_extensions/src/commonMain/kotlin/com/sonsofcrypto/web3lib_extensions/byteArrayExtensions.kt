package com.sonsofcrypto.web3lib_extensions

import kotlin.experimental.or


@kotlin.ExperimentalUnsignedTypes
fun ByteArray.toHexString(): String = asUByteArray().joinToString("") {
    it.toString(radix = 16).padStart(2, '0')
}

fun String.hexStringToByteArray(): ByteArray {
    check(length % 2 == 0) { "Must have an even length" }

    return chunked(2)
        .map { it.toInt(16).toByte() }
        .toByteArray()
}

fun ByteArray.toBitArray(): BooleanArray {
    val bitArray = BooleanArray(size * 8)
    for (byteIdx in indices)
        for (bitIdx in 0..7) {
            val idx = byteIdx * 8 + bitIdx
            bitArray[idx] = (1 shl (7 - bitIdx)) and this[byteIdx].toInt() != 0
        }
    return bitArray
}

fun BooleanArray.toByteArray(len : Int = this.size / 8): ByteArray {
    val byteArray = ByteArray(len)
    for (byteIdx in byteArray.indices)
        for (bitIdx in 0..7)
            if (this[byteIdx * 8 + bitIdx]) {
                byteArray[byteIdx] = byteArray[byteIdx] or (1 shl (7 - bitIdx)).toByte()
            }
    return byteArray
}