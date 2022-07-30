package com.sonsofcrypto.web3lib.provider.model

import com.sonsofcrypto.web3lib.utils.BigInt

data class FeeData(
    val maxFeePerGas: BigInt,
    val maxPriorityFeePerGas: BigInt,
    val gasPrice: BigInt,
)