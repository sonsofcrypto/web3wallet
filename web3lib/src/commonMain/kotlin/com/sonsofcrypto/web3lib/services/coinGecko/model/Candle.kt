package com.sonsofcrypto.web3lib.services.coinGecko.model

import kotlinx.datetime.Instant

data class Candle(
    val timestamp: Instant,
    val open: Double,
    val high: Double,
    val low: Double,
    val close: Double,
)