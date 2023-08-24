package com.sonsofcrypto.web3lib.services.uniswap2.permit2

import com.sonsofcrypto.web3lib.services.uniswap2.core.TypedDataField

data class Witness(
    val witness: Any,
    val witnessTypeName: String,
    val witnessType: Map<String, List<TypedDataField>>,
)
