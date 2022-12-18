package com.sonsofcrypto.web3lib.contract

import com.sonsofcrypto.web3lib.utils.BigInt

abstract class Coder(
    /** Coder name eg address, uint256, tuple, array, etc */
    val name: String,
    /** Expanded type eg address, uint256, tuple(address,bytes), uint256[3][] */
    val type: String,
    /** Local name bound in signature, eg "baz" tuple(address foo, uint baz) */
    val localName: String,
    /** Whether this type is dynamic:
     *  - Dynamic: bytes, string, address[], tuple(boolean[]), etc.
     *  - Static: address, uint256, boolean[3], tuple(address, uint8)
     */
    val dynamic: Boolean,
) {
    @Throws(Throwable::class)
    abstract fun encode(writer: Writer, value: Any): Int

    @Throws(Throwable::class)
    abstract fun decode(reader: Reader): Any

    @Throws(Throwable::class)
    abstract fun defaultValue(): Any

    /** Errors */
    sealed class Error(
        message: String? = null,
        cause: Throwable? = null
    ) : Exception(message, cause) {

        constructor(cause: Throwable) : this(null, cause)

        data class UnexpectedType(val coder: Coder, val type: Any):
            Error("$coder encountered unexpected type $type")
    }
}

class Writer(val wordSize: Int = 32) {
    private var data: ByteArray = ByteArray(0)
    private var dataLength: Int = 0
    private var padding: ByteArray = ByteArray(wordSize)

    fun data(): ByteArray = data

    fun length(): Int = dataLength

    fun appendWriter(writer: Writer): Int = writeData(writer.data)

    /** Padded on the right to wordSize. Return number of bytes written */
    fun writeBytes(bytes: ByteArray): Int {
        val paddingOffset = bytes.size % wordSize
        return if (paddingOffset == 0) writeData(bytes)
        else writeData(bytes + padding.copyOfRange(0, paddingOffset))
    }

    /** Padded on the left to wordSize */
    fun writeValue(value: BigInt): Int = writeData(getValue(value))

    fun writeUpdatableValue(): ((value: BigInt) -> Unit) {
        val offset = data.size
        data += padding
        dataLength += wordSize
        return { value: BigInt ->
            val bytes = this.getValue(value)
            for (i in 0..bytes.size) {
                data[offset + i] = bytes[i]
            }
        }
    }

    private fun writeData(data: ByteArray): Int {
        this.data += data
        this.dataLength += data.size
        return data.size
    }

    private fun getValue(value: BigInt): ByteArray {
        var bytes = value.toByteArray()
        if (bytes.size > wordSize) {
            throw Error.OutOfBounds(value, wordSize)
        }
        return if (bytes.size % wordSize == 0) bytes
        else padding.copyOfRange(0, bytes.size % wordSize) + bytes
    }

    /** Errors */
    sealed class Error(message: String? = null, cause: Throwable? = null)
        : Exception(message, cause) {

        constructor(cause: Throwable) : this(null, cause)

        data class OutOfBounds(val value: BigInt, val wordSize: Int):
            Error("Out of bounds $value, $wordSize, ${value.toByteArray().size}")
    }
}

class Reader(
    val data: ByteArray,
    val wordSize: Int = 32,
    val coerceFunc: ((type: String, value: Any) -> Any) = defaultCoerce(),
    val allowLoose: Boolean = false,
    private val offset: Int = 0,
) {

    fun consumed(): Int = offset

    fun coerce(name: String, value: Any): Any {
        TODO("Implement")
    }

    fun subReader(offset: Int): Reader {
        TODO("Implement")
    }

    fun readBytes(length: Int, loose: Boolean?): ByteArray {
        TODO("Implement")
    }

    fun readValue(): BigInt {
        TODO("Implement")
    }

    companion object {

        private fun defaultCoerce(): ((name: String, value: Any) -> Any) {
            return { name, value ->
                val match = Regex("^u?int([0-9]+)\$").matchEntire(name)
                if (match.groupValues[1].toInt() <= 48) value.
                else value
        // if (match && parseInt(match[1]) <= 48) { value =  value.toNumber(); }

            }
        }
    }
}
