package com.sonsofcrypto.web3lib.services.currencyStore

import kotlinx.serialization.Serializable

@Serializable
data class CurrencyMetadata(
    val imageUrl: String?,
    val rank: Long?,
    val colors: List<String>?,
)