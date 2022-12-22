package com.sonsofcrypto.web3lib.utils

import com.ionspin.kotlin.bignum.integer.BigInteger
import com.ionspin.kotlin.bignum.integer.Sign
import com.ionspin.kotlin.bignum.integer.util.fromTwosComplementByteArray
import com.ionspin.kotlin.bignum.integer.util.toTwosComplementByteArray
import com.sonsofcrypto.web3lib.utils.extensions.toBooleanArray
import com.sonsofcrypto.web3lib.utils.extensions.toByteArray
import kotlinx.serialization.KSerializer
import kotlinx.serialization.Serializable
import kotlinx.serialization.Serializer
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder

@Serializable(with = BigIntSerializer::class)
class BigInt {

    internal val storage: BigInteger

    internal constructor(storage: BigInteger) {
        this.storage = storage
    }

    fun add(value: BigInt): BigInt = BigInt(storage.add(value.storage))
    fun sub(value: BigInt): BigInt = BigInt(storage.subtract(value.storage))
    fun mul(value: BigInt): BigInt = BigInt(storage.multiply(value.storage))
    @Throws(Throwable::class)
    fun div(value: BigInt): BigInt = BigInt(storage.divide(value.storage))
    fun pow(value: Long): BigInt = BigInt(storage.pow(value))

    fun toByteArray(): ByteArray = storage.toByteArray()
    fun toTwosComplement(): ByteArray = storage.toTwosComplementByteArray()
    fun toHexString(): String = storage.toString(16)
    fun toDecimalString(): String = toString()

    fun compare(other: BigInt): Int = storage.compare(other.storage)
    fun isLessThan(other: BigInt): Boolean = storage.compare(other.storage) == -1
    fun isGreaterThan(other: BigInt): Boolean = storage.compare(other.storage) == 1
    fun isZero(): Boolean = storage.isZero()

    override fun toString(): String = storage.toString(10)

    override fun equals(other: Any?): Boolean  {
        return storage == (other as? BigInt)?.storage
    }

    companion object {

        val zero: BigInt get() = from(0)
        val one: BigInt get() = from(1)
        val negOne: BigInt get() = from(-1)

        fun maxUInt256(): BigInt {
            var bytes = ByteArray(32)
            for (idx in bytes.indices) { bytes.set(idx, 0xff.toByte()) }
            return from(bytes)
        }

        fun maxInt256(): BigInt {
            var bytes = ByteArray(31)
            for (idx in bytes.indices) { bytes.set(idx, 0xff.toByte()) }
            return from(bytes)
        }

        @Throws(Throwable::class)
        fun from(string: String, base: Int = 10): BigInt {
            return BigInt(BigInteger.parseString(string, base))
        }

        fun fromTwosComplement(byteArray: ByteArray): BigInt
            = BigInt(BigInteger.fromTwosComplementByteArray(byteArray))
        fun from(byteArray: ByteArray, sign: Sign = Sign.POSITIVE): BigInt
            = BigInt(BigInteger.fromByteArray(byteArray, sign))
        fun from(int: Int): BigInt = BigInt(BigInteger.fromInt(int))
        fun from(uint: UInt): BigInt = BigInt(BigInteger.fromUInt(uint))
        fun from(long: Long): BigInt = BigInt(BigInteger.fromLong(long))
        fun from(ulong: ULong): BigInt = BigInt(BigInteger.fromULong(ulong))
        fun from(bool: Boolean): BigInt = BigInt(BigInteger.fromInt(if (bool) 1 else 0 ))
        fun min(a: BigInt, b: BigInt): BigInt = BigInt(BigInteger.min(a.storage, b.storage))
    }
}

/** Pads to `size` in twos complement, correctly handling negative integers */
fun padTwosComplement(num: BigInt, size: Int): ByteArray {
    val bitArray = num.toTwosComplement().toBooleanArray()
    val result = BooleanArray(size * 8)
    for (i in 0..result.size - bitArray.size) {
        result.set(i, bitArray.get(0))
    }
    for (i in bitArray.size - 1 downTo 1) {
        result.set(result.size - (bitArray.size - i), bitArray[i])
    }
    return result.toByteArray()
}

@Serializer(forClass = BigInt::class)
object BigIntSerializer : KSerializer<BigInt> {

    override val descriptor: SerialDescriptor = PrimitiveSerialDescriptor(
        "BigInt", PrimitiveKind.STRING
    )

    override fun serialize(encoder: Encoder, value: BigInt) {
        encoder.encodeString("${value.toString()}")
    }

    override fun deserialize(decoder: Decoder): BigInt {
        return BigInt.from(decoder.decodeString())
    }
}

class ComparatorBigInt {
    companion object : Comparator<BigInt> {
        override fun compare(a: BigInt, b: BigInt): Int = a.compare(b)
    }
}
