package com.sonsofcrypto.web3lib.contract

import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.padTwosComplement
import io.ktor.utils.io.*
import io.ktor.utils.io.core.*

class AbiCoder {
}

class AddressCoder(localName: String):
    Coder("address", "address", localName, false) {

    @Throws(Throwable::class)
    override fun encode(writer: Writer, value: Any): Int {
        val data = value as? ByteArray
        return if (data != null) writer.writeValue(BigInt.from(data))
        else throw Error.UnexpectedType(this, value)
    }

    @Throws(Throwable::class)
    override fun decode(reader: Reader): Any = reader.readValue()

    @Throws(Throwable::class)
    override fun defaultValue(): Any = ByteArray(40)
}

class AnonymousCoder(private val coder: Coder):
    Coder(coder.name, coder.type, "", coder.dynamic) {

    @Throws(Throwable::class)
    override fun encode(writer: Writer, value: Any): Int = coder.encode(writer, value)

    @Throws(Throwable::class)
    override fun decode(reader: Reader): Any = coder.decode(reader)

    @Throws(Throwable::class)
    override fun defaultValue(): Any = coder.defaultValue()
}

class BooleanCoder(localName: String): Coder("bool", "bool", localName, false) {

    @Throws(Throwable::class)
    override fun encode(writer: Writer, value: Any): Int {
        val bool = value as? Boolean
        return if (bool != null) writer.writeValue(BigInt.from(value))
        else throw Error.UnexpectedType(this, value)
    }

    @Throws(Throwable::class)
    override fun decode(reader: Reader): Any {
        return reader.coerceFunc(this.type, !reader.readValue().isZero())
    }

    @Throws(Throwable::class)
    override fun defaultValue(): Any = false
}

class NullCoder(localName: String): Coder("null", "", localName, false) {

    @Throws(Throwable::class)
    override fun encode(writer: Writer, value: Any): Int {
        return if (value != null) throw Error.UnexpectedType(this, value)
        else writer.writeBytes(ByteArray(0))
    }

    @Throws(Throwable::class)
    override fun decode(reader: Reader): Any {
        reader.readBytes(0)
        return reader.coerceFunc(name, null)
    }

    @Throws(Throwable::class)
    override fun defaultValue(): Any = null
}

class NumberCoder(val size: Int, val signed: Boolean, localName: String):
    Coder(
        (if (signed) "int" else "uint") + "${size * 8}",
        (if (signed) "int" else "uint") + "${size * 8}",
        localName,
        false,
    ) {

    @Throws(Throwable::class)
    override fun encode(writer: Writer, value: Any): Int {
        (value as? BigInt)?.let {
            checkValueBounds(it)
            return if (signed) writer.writeBytes(padTwosComplement(it, size))
            else writer.writeValue(it)
        }
        throw Error.UnexpectedType(this, value)
    }

    @Throws(Throwable::class)
    private fun checkValueBounds(num: BigInt) {
        if (signed) {
            val maxInt256 = BigInt.maxInt256()
            val minInt256 = maxInt256.add(BigInt.one).mul(BigInt.negOne)
            if(num.isGreaterThan(maxInt256) || num.isLessThan(minInt256))
                throw Error.UnexpectedType(this, num)
        } else {
            val maxUInt256 = BigInt.maxUInt256()
            val zero = BigInt.zero
            if (num.isLessThan(zero) || num.isGreaterThan(maxUInt256))
                throw Error.UnexpectedType(this, num)
        }
    }

    @Throws(Throwable::class)
    override fun decode(reader: Reader): Any {
        var num = reader.readValue() as? BigInt
        if (num == null)
            throw Error.UnexpectedType(this, num)
        if (signed)
            num = BigInt.fromTwosComplement(num.toByteArray())
        return reader.coerce(name, num)
    }

    @Throws(Throwable::class)
    override fun defaultValue(): Any = 0
}

open class DynamicBytesCoder(type: String, localName: String):
    Coder(type, type, localName, true) {

    @Throws(Throwable::class)
    override fun encode(writer: Writer, value: Any): Int {
        val data = value as? ByteArray
        if (data != null) {
            val length = writer.writeValue(BigInt.from(data.size))
            return length + writer.writeBytes(data)
        } else throw Error.UnexpectedType(this, value)
    }

    @Throws(Throwable::class)
    override fun decode(reader: Reader): Any {
        return reader.readBytes(reader.readValue().toString().toInt(), true)
    }

    @Throws(Throwable::class)
    override fun defaultValue(): Any = BigInt.zero
}

class BytesCoder(localName: String):
    DynamicBytesCoder("bytes", localName) {

    @Throws(Throwable::class)
    override fun decode(reader: Reader): Any {
        return reader.coerce(name, super.decode(reader))
    }
}

class FixedBytesCoder(private val size: Int, localName : String):
    Coder("bytes$size", "bytes$size", localName, false) {

    @Throws(Throwable::class)
    override fun encode(writer: Writer, value: Any): Int {
        val data = value as ByteArray
        return if (data != null) writer.writeBytes(data)
        else throw Error.UnexpectedType(this, value)
    }

    @Throws(Throwable::class)
    override fun decode(reader: Reader): Any {
        return reader.coerceFunc(name, reader.readBytes(size))
    }

    @Throws(Throwable::class)
    override fun defaultValue(): Any = ByteArray(size)
}

class StringCoder(localName: String): DynamicBytesCoder("string", localName) {

    @Throws(Throwable::class)
    override fun encode(writer: Writer, value: Any): Int {
        val str = value as String
        return if (str != null) super.encode(writer, str.toByteArray())
        else throw Error.UnexpectedType(this, value)
    }

    @Throws(Throwable::class)
    override fun decode(reader: Reader): Any {
        return String(super.decode(reader) as ByteArray)
    }
}

class TupleCoder(val coders: List<Coder>, localName: String):
    Coder(
        "tuple",
        coders.map{ it.type }.joinToString(prefix = "tuple(", postfix = ")"),
        localName,
        coders.isNotEmpty() && coders.any { it.dynamic }
    ) {

    @Throws(Throwable::class)
    override fun encode(writer: Writer, value: Any): Int =
        pack(writer, coders, value as List<Any>)

    @Throws(Throwable::class)
    override fun decode(reader: Reader): Any =
        reader.coerce(name, unpack(reader, coders))

    @Throws(Throwable::class)
    override fun defaultValue(): Any {
        val values = coders.map { it.defaultValue() }
        // TODO: Figure out named ones, from tests
//        val uniqueNames: MutableMap<String, Int> = mutableMapOf()
//        coders.forEach { coder ->
//            if (coder.name.isNotBlank())
//                uniqueNames[coder.name] = ( uniqueNames[coder.name] ?: 0) + 1
//        }
//        coders.forEachIndexed { idx, coder ->
//            var name = coder.localName
//            if (name == null || uniqueNames[name] != 1)
//                continue
//            if (name == "length")
//                name = "_length"
//            if (values[name] != null)
//                continue
//            values[name] = values[idx]
//        }
        return values
    }
}

class ArrayCoder(val coder: Coder, val length: Int, localName: String):
    Coder(
        "array",
        coder.type + "[${if (length >= 0) length else ""}]",
        localName,
        length < 0 || coder.dynamic,
    ) {

    @Throws(Throwable::class)
    fun encode(writer: Writer, value: List<Any>): Int {
        var count = length
        if (count == -1) {
            count = value.size
            writer.writeValue(BigInt.from(value.size))
        }
        checkArgumentCount(value.size, count, "coder array $localName")
        val coders: List<Coder> = (0..value.size).map { coder }
        return pack(writer, coders, value)
    }

    @Throws(Throwable::class)
    override fun encode(writer: Writer, value: Any): Int {
        val listValue = value as? List<Any>
        if (listValue != null) return encode(writer, listValue)
        else throw Error.UnexpectedType(this, value)
    }

    @Throws(Throwable::class)
    override fun decode(reader: Reader): Any {
        var count = length
        if (count == -1) {
            count = reader.readValue().toString().toInt()
            // Check that there is *roughly* enough data to ensure stray random
            // data is not being read as a length. Each slot requires at least
            // 32 bytes for their value (or 32 bytes as a link to the data).
            // This could use a much tighter bound, but we are erroring on the
            // side of safety.
            if (count * 32 > reader.data.size)
                throw Reader.Error.InsufficientDataSize(coder, reader.data.size)
        }
        val coders: List<Coder> = (0..count).map { AnonymousCoder(coder) }
        return reader.coerceFunc(name, unpack(reader, coders))
    }

    @Throws(Throwable::class)
    override fun defaultValue(): List<Any> {
        val defaultChild = coder.defaultValue()
    }
}

@Throws(Throwable::class)
private fun checkArgumentCount(count: Int, expected: Int, message: String = "") {
    if (count < expected)
        throw Error("missing argument $count $expected: $message")
    if (count > expected)
        throw Error("too many arguments $count $expected: $message")
}

@Throws(Throwable::class)
private fun pack(writer: Writer, coders: List<Coder>, value: List<Any>): Int {
    val arrayValues = value
    // TODO: Figure out named ones, from tests
    if (coders.size != arrayValues.size)
        throw Coder.Error.SizeMismatch(coders, value)
    val staticWriter = Writer()
    val dynamicWriter = Writer()
    var updateFuncs: MutableList<(baseOffset: Int) -> Unit> = mutableListOf()
    coders.forEachIndexed { idx, coder ->
        val value = arrayValues[idx]
        if (coder.dynamic) {
            // Get current dynamic offset (for the future pointer)
            val dynamicOffset = dynamicWriter.length()
            // Encode the dynamic value into the dynamicWriter
            coder.encode(dynamicWriter, value)
            // Prepare to populate the correct offset once we are done
            val updateFunc = staticWriter.writeUpdatableValue()
            // Prepare to populate the correct offset once we are done
            updateFuncs.add { baseOffset: Int ->
                updateFunc(BigInt.from(baseOffset + dynamicOffset))
            }

        } else coder.encode(staticWriter, value)
    }
    // Backfill all the dynamic offsets, now that we know the static length
    updateFuncs.forEach { func -> func(staticWriter.length()) }
    return writer.appendWriter(staticWriter) + writer.appendWriter(dynamicWriter)
}

@Throws(Throwable::class)
private fun unpack(reader: Reader, coders: List<Coder>): Any {
    var values: MutableList<Any> = mutableListOf()
    val baseReader = reader.subReader(0)
    coders.forEach { coder ->
        var value: Any? = null
        if (coder.dynamic) {
            var offset = reader.readValue()
            var offsetReader = baseReader.subReader(offset.toString().toInt())
            try {
                value = coder.decode(offsetReader)
            } catch (error: Throwable) {
                if (error is Reader.Error.OutOfBounds) throw error
                value = Reader.Error.Decode(
                    error,
                    coder.localName,
                    coder.type,
                    coder.name
                )
            }
        } else {
            try {
                value = coder.decode(reader)
            } catch (error: Throwable) {
                if (error is Reader.Error.OutOfBounds) throw error
                value = Reader.Error.Decode(
                    error,
                    coder.localName,
                    coder.type,
                    coder.name
                )
            }
        }
        if (value != null)
            values.add(value)
    }
    // TODO: Figure out named ones, from tests
    return values
}