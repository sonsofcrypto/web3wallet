package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_utils.BigInt

data class FeeData(
    val maxFeePerGas: BigInt,
    val maxPriorityFeePerGas: BigInt,
    val gasPrice: BigInt,
)