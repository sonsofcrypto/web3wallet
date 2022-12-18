package com.sonsofcrypto.web3lib.contract

class AbiCoder {
}

class AddressCoder(localName: String):
    Coder("address", "address", localName, false) {

    @Throws(Throwable::class)
    override fun encode(writer: Writer, value: Any): Int {
        val data = value as? ByteArray
        if (data == null)
            throw Error.UnexpectedType(this, value)
        return writer.writeValue(data)
    }

    @Throws(Throwable::class)
    override fun decode(reader: Reader): Any {
        TODO("Not yet implemented")
        // getAddress(hexZeroPad(reader.readValue().toHexString(), 20));
    }

    @Throws(Throwable::class)
    override fun defaultValue(): Any = ByteArray(32)
}

class AnonymousCoder(private val coder: Coder):
    Coder(coder.name, coder.type, "", coder.dynamic) {

    @Throws(Throwable::class)
    override fun encode(writer: Writer, value: Any): Int = coder.encode(writer, value)

    @Throws(Throwable::class)
    override fun decode(reader: Reader):Any = coder.decode(reader)

    @Throws(Throwable::class)
    override fun defaultValue(): Any = coder.defaultValue()
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

class BooleanCoder(localName: String): Coder("bool", "bool", localName, false) {

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
        TODO("Not yet implemented")
    }
}

open class DynamicBytesCoder(type: String, localName: String):
    Coder(type, type, localName, true) {

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
        TODO("Not yet implemented")
    }
}

class BytesCoder(localName: String):
    DynamicBytesCoder("bytes", localName)

class FixedBytesCoder(size: Int, localName : String):
    Coder("bytes$size", "bytes$size", localName, false) {

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
        TODO("Not yet implemented")
    }
}

class NullCoder(localName: String): Coder("null", "", localName, false) {

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
        TODO("Not yet implemented")
    }
}

class NumberCoder(size: Int, signed: Boolean, localName: String):
    Coder(
        (if (signed) "int" else "uint") + "${size * 8}",
        (if (signed) "int" else "uint") + "${size * 8}",
        localName,
        false,
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
        TODO("Not yet implemented")
    }
}

class StringCoder(localName: String): DynamicBytesCoder("string", localName) {

}

class TupleCoder: Coder {

    constructor(coders: List<Coder>, localName: String) {
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
    override fun defaultValue(): Any {
        TODO("Not yet implemented")
    }
}
