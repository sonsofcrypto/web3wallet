package com.sonsofcrypto.web3lib_utils

import kotlin.experimental.or

/** Hex string */

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

/** UInt */

fun UInt.toByteArray(bigEndian: Boolean = true): ByteArray {
    var array = ByteArray(4)
    for (i in 0..3) array[i] = (this shr (i*8)).toByte()
    return if (bigEndian) array.reversedArray() else array
}

fun ByteArray.toUInt(): UInt {
    val bytes = 4
    val paddedArray = ByteArray(bytes)
    for (i in 0 until bytes-this.size) paddedArray[i] = 0
    for (i in bytes-this.size until paddedArray.size) {
        paddedArray[i] = this[i-(bytes-this.size)]
    }

    return (((paddedArray[0].toUInt() and 0xFFu) shl 24) or
            ((paddedArray[1].toUInt() and 0xFFu) shl 16) or
            ((paddedArray[2].toUInt() and 0xFFu) shl 8) or
            (paddedArray[3].toUInt() and 0xFFu))
}

/** BitArray */

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
