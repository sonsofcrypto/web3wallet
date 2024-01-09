package com.sonsofcrypto.web3lib.provider.utils

import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.extensions.toUInt

private const val ELEM_OFFSET = 128
private const val LIST_OFFSET = 192

sealed class Rlp { companion object }

data class RlpItem(val bytes: ByteArray) : Rlp() {

    override fun equals(other: Any?) = when (other) {
        is RlpItem -> bytes.contentEquals(other.bytes)
        else -> false
    }

    override fun hashCode() = bytes.contentHashCode()
}

data class RlpList(val element: List<Rlp>) : Rlp() {
    companion object
}

/* Encode */

@Throws(Throwable::class)
fun Rlp.encode(): ByteArray = when (this) {
    is RlpItem -> bytes.encodeRlp(ELEM_OFFSET)
    is RlpList -> element.asSequence().map { it.encode() }
        .fold(ByteArray(0)) { acc, bytes -> acc + bytes }
        .encodeRlp(LIST_OFFSET)
}

private fun ByteArray.encodeRlp(offset: Int) = when {
    size == 1 && ((first().toInt() and 0xff) < ELEM_OFFSET) && offset == ELEM_OFFSET -> this
    size <= 55 -> ByteArray(1) { (size + offset).toByte() }.plus(this)
    else -> size.toMinimalByteArray().let { arr ->
        ByteArray(1) { (offset + 55 + arr.size).toByte() } + arr + this
    }
}

/* Decode */

@Throws(Throwable::class)
fun Rlp.Companion.decode(bytes: ByteArray): Rlp =
    bytes.decodeRLPWithSize(0).element

private data class DecodeResult(val element: Rlp, val size: Int)

private data class LengthAndOffset(val length: Int, val offset: Int)

@Throws(Throwable::class)
private fun ByteArray.decodeRLPWithSize(offset: Int = 0): DecodeResult {
    if (offset >= size)
        throw Exception("Cannot decode RLP at offset=$offset and size=$size")

    val value = this[offset].toInt() and 0xFF
    return when {
        value < ELEM_OFFSET -> DecodeResult(RlpItem(ByteArray(1) { value.toByte() }), 1)
        value < LIST_OFFSET -> (value - ELEM_OFFSET).let {
            val lengthAndOffset = getLengthAndOffset(it, offset)
            DecodeResult(
                RlpItem(copyOfRange(lengthAndOffset.offset, lengthAndOffset.offset + lengthAndOffset.length)),
                lengthAndOffset.length + lengthAndOffset.offset - offset
            )
        }
        else -> (value - LIST_OFFSET).let {
            val list = mutableListOf<Rlp>()

            val lengthAndOffset = getLengthAndOffset(it, offset)
            var currentOffset = lengthAndOffset.offset
            while (currentOffset < lengthAndOffset.offset + lengthAndOffset.length) {
                val element = decodeRLPWithSize(currentOffset)
                currentOffset += element.size
                list.add(element.element)
            }
            DecodeResult(RlpList(list), (lengthAndOffset.offset + lengthAndOffset.length) - offset)
        }
    }
}

@Throws(Throwable::class)
private fun ByteArray.getLengthAndOffset(firstByte: Int, offset: Int) =
    if (firstByte <= 55)
        LengthAndOffset(firstByte, offset + 1)
    else {
        val size = firstByte - 54
        val length = BigInt.from(copyOfRange(offset + 1, offset + size))
            .toDecimalString()
            .toInt()
        LengthAndOffset(length, offset + size)
    }

//@Throws(Throwable::class)
//private fun ByteArray.getLengthAndOffset2(firstByte: Int, offset: Int) =
//    if (firstByte <= 55)
//        LengthAndOffset(firstByte, offset + 1)
//    else {
//        val size = firstByte - 54
//        val length = BigInteger(1, copyOfRange(offset + 1, offset + size)).toInt()
//        LengthAndOffset(length, offset + size)
//    }

/* Utils */

private fun Int.toByteArray() = ByteArray(4) { i ->
    shr(8 * (3 - i)).toByte()
}

private fun Int.toMinimalByteArray() = toByteArray().let {
    it.copyOfRange(it.minimalStart(), 4)
}

private fun ByteArray.minimalStart() = indexOfFirst { it != 0.toByte() }
    .let { if (it == -1) 4 else it }
