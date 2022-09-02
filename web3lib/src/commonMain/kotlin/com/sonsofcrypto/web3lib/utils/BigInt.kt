package com.sonsofcrypto.web3lib.utils

import com.ionspin.kotlin.bignum.integer.BigInteger
import com.ionspin.kotlin.bignum.integer.Sign
import com.sonsofcrypto.web3lib.services.uniswap.QuoteRequest
import com.sonsofcrypto.web3lib.services.uniswap.UniswapService
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
    fun mul(value: BigInt): BigInt = BigInt(storage.multiply(value.storage))
    @Throws(Throwable::class)
    fun div(value: BigInt): BigInt = BigInt(storage.divide(value.storage))
    fun pow(value: Long): BigInt = BigInt(storage.pow(value))

    fun toByteArray(): ByteArray = storage.toByteArray()
    fun toHexString(): String = storage.toString(16)
    fun toDecimalString(): String = toString()

    fun compare(other: BigInt): Int = storage.compare(other.storage)
    fun isZero(): Boolean =  storage.isZero()

    override fun toString(): String = storage.toString(10)

    override fun equals(other: Any?): Boolean  {
        return storage == (other as? BigInt)?.storage
    }

    companion object {

        fun zero(): BigInt = BigInt.from(0)

        @Throws(Throwable::class)
        fun from(string: String, base: Int = 10): BigInt {
            return BigInt(BigInteger.parseString(string, base))
        }

        fun from(byteArray: ByteArray): BigInt = BigInt(
            BigInteger.fromByteArray(byteArray, Sign.POSITIVE)
        )

        fun from(int: Int): BigInt = BigInt(BigInteger.fromInt(int))
        fun from(uint: UInt): BigInt = BigInt(BigInteger.fromUInt(uint))
        fun from(long: Long): BigInt = BigInt(BigInteger.fromLong(long))
        fun from(ulong: ULong): BigInt = BigInt(BigInteger.fromULong(ulong))
    }
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
