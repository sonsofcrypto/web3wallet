package com.sonsofcrypto.web3lib_extensions

import kotlin.experimental.or


// MARK: - Hex string

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

// MARK: - Int

fun Int.toByteArray(): ByteArray {
    var array = ByteArray(4)
    for (i in 0..3) array[i] = (this shr (i*8)).toByte()
    return array
}

fun ByteArray.toInt(): Int {
    return (this[3].toInt() shl 24) or
            (this[2].toInt() and 0xff shl 16) or
            (this[1].toInt() and 0xff shl 8) or
            (this[0].toInt() and 0xff)
}


fun UInt.toByteArray(): ByteArray {
    var array = ByteArray(4)
    for (i in 0..3) array[i] = (this shr (i*8)).toByte()
    return array
}

fun ByteArray.toUInt(): UInt {
    return (this[3].toUInt() shl 24) or
            (this[2].toUInt() and 255u shl 16) or
            (this[1].toUInt() and 255u shl 8) or
            (this[0].toUInt() and 255u)
}


// MARK: - BitArray

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
