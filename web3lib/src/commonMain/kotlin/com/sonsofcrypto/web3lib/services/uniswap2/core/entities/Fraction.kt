package com.sonsofcrypto.web3lib.services.uniswap2.core.entities

import com.sonsofcrypto.web3lib.types.BigInt

data class Fraction(
    val numerator: BigInt,
    val denominator: BigInt,
    val isPercent: Boolean = false,
)