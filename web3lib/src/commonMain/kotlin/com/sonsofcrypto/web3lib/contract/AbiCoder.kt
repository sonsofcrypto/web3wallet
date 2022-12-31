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
    override fun encode(writer: Writer, value: Any): Int {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override fun decode(reader: Reader): Any {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override fun defaultValue(): Any {
        val values = coders.map { it.defaultValue() }
        val uniqueNames: MutableMap<String, Int> = coders.reduce { acc, coder ->
            name = coder.localName
            if (name.isNotBlank()) {
                acc[name] = acc.get
            }
        }


        // We only output named properties for uniquely named coders
//        const uniqueNames = this.coders.reduce((accum, coder) => {
//            const name = coder.localName;
//            if (name) {
//                if (!accum[name]) { accum[name] = 0; }
//                accum[name]++;
//            }
//            return accum;
//        }, <{ [ name: string ]: number }>{ });

    }
}

class ArrayCoder(coder: Coder, length: Int, localName: String):
    Coder(
        "array",
        coder.type + "[${if (length >= 0) length else ""}]",
        localName,
        length < 0 || coder.dynamic,
    ) {

    @Throws(Throwable::class)
    fun encode(writer: Writer, value: List<Any>): Int {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override fun encode(writer: Writer, value: Any): Int {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override fun decode(reader: Reader): Any {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override fun defaultValue(): List<Any> {
        TODO("Not yet implemented")
    }
}
