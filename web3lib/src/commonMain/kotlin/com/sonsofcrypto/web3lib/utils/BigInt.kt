package com.sonsofcrypto.web3lib.utils

import com.ionspin.kotlin.bignum.integer.BigInteger
import com.ionspin.kotlin.bignum.integer.Sign

class BigInt {

    internal val storage: BigInteger

    internal constructor(storage: BigInteger) {
        this.storage = storage
    }

    fun add(value: BigInt): BigInt = BigInt(storage.add(value.storage))
    fun mul(value: BigInt): BigInt = BigInt(storage.multiply(value.storage))
    fun div(value: BigInt): BigInt = BigInt(storage.divide(value.storage))

    fun toByteArray(): ByteArray = storage.toByteArray()
    fun toHexString(): String = storage.toString(16)
    fun toDecimalString(): String = toString()

    override fun toString(): String = storage.toString(10)

    override fun equals(other: Any?): Boolean  {
        return storage == (other as? BigInt)?.storage
    }

    companion object {

        fun zero(): BigInt = BigInt.from(0)

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
