package com.sonsofcrypto.web3lib.integrations.uniswap2.core.entities

import com.sonsofcrypto.web3lib.types.AddressHexString

data class MethodParameters(
    val calldata: ByteArray,
    val value: String,
    val to: AddressHexString
)