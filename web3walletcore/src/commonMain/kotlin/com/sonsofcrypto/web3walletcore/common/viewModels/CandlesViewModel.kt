package com.sonsofcrypto.web3walletcore.common.viewModels

import com.sonsofcrypto.web3walletcore.common.viewModels.CandlesViewModel.Loading

sealed class CandlesViewModel {
    data class Unavailable(val cnt: Int): CandlesViewModel()
    data class Loading(val cnt: Int): CandlesViewModel()
    data class Loaded(val candles: List<Candle>): CandlesViewModel()

    data class Candle(
        val open: Double,
        val high: Double,
        val low: Double,
        val close: Double,
        val volume: Double,
        val period: Double,
    )
}

fun CandlesViewModel.isLoading(): Boolean =
    when (this) {
        is Loading -> true
        else -> false
    }
