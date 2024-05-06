package com.sonsofcrypto.web3lib.integrations.uniswap2.core.entities

import com.sonsofcrypto.web3lib.types.bignum.BigInt

data class Fraction(
    val numerator: BigInt,
    val denominator: BigInt,
    val isPercent: Boolean = false,
)