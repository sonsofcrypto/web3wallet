package com.sonsofcrypto.web3walletcore.common.viewModels

import com.sonsofcrypto.web3lib.services.coinGecko.model.Candle
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

    companion object
}

fun CandlesViewModel.isLoading(): Boolean =
    when (this) {
        is Loading -> true
        else -> false
    }

fun CandlesViewModel.Companion.loaded(candles: List<Candle>): CandlesViewModel.Loaded =
    CandlesViewModel.Loaded(
        candles.map {
            CandlesViewModel.Candle(
                it.open,
                it.high,
                it.low,
                it.close,
                0.0,
                it.timestamp.epochSeconds.toDouble()
            )
        }
    )
