package com.sonsofcrypto.web3lib.utils

import com.ionspin.kotlin.bignum.decimal.BigDecimal

class BigDec {

    internal val storage: BigDecimal

    internal constructor(storage: BigDecimal) {
        this.storage = storage
    }

    fun add(value: BigDec): BigDec = BigDec(storage.add(value.storage))
    fun mul(value: BigDec): BigDec = BigDec(storage.multiply(value.storage))
    fun div(value: BigDec): BigDec = BigDec(storage.divide(value.storage))

    fun toBigInt(): BigInt = BigInt(storage.toBigInteger())
    fun toHexString(): String = storage.toString(16)
    fun toDecimalString(): String = toString()

    override fun toString(): String = storage.toString(10)

    companion object {

        fun zero(): BigDec = BigDec.from(0)

        fun from(string: String, base: Int = 10): BigDec {
            return BigDec(BigDecimal.parseString(string, base))
        }

        fun from(int: Int): BigDec = BigDec(BigDecimal.fromInt(int))
        fun from(uint: UInt): BigDec = BigDec(BigDecimal.fromUInt(uint))
        fun from(long: Long): BigDec = BigDec(BigDecimal.fromLong(long))
        fun from(ulong: ULong): BigDec = BigDec(BigDecimal.fromULong(ulong))
        fun from(bigInt: BigInt): BigDec = BigDec(
            BigDecimal.fromBigInteger(bigInt.storage)
        )
    }
}
