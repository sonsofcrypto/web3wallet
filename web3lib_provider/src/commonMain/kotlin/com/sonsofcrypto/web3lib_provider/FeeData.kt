package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_utils.BigInt

interface FeeData {
    val maxFeePerGas: BigInt
    val maxPriorityFeePerGas: BigInt
    val gasPrice: BigInt
}