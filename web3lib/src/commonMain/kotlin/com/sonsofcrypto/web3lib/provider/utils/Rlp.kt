package com.sonsofcrypto.web3lib.provider.utils

private const val ELEM_OFFSET = 128
private const val LIST_OFFSET = 192

sealed class Rlp

data class RlpItem(val bytes: ByteArray) : Rlp() {

    override fun equals(other: Any?) = when (other) {
        is RlpItem -> bytes.contentEquals(other.bytes)
        else -> false
    }

    override fun hashCode() = bytes.contentHashCode()
}

data class RlpList(val element: List<Rlp>) : Rlp()

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

/* Utils */

private fun Int.toByteArray() = ByteArray(4) { i ->
    shr(8 * (3 - i)).toByte()
}

private fun Int.toMinimalByteArray() = toByteArray().let {
    it.copyOfRange(it.minimalStart(), 4)
}

private fun ByteArray.minimalStart() = indexOfFirst { it != 0.toByte() }
    .let { if (it == -1) 4 else it }
