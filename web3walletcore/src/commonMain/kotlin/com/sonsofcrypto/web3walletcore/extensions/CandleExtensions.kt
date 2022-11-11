package com.sonsofcrypto.web3walletcore.extensions

import com.sonsofcrypto.web3lib.services.coinGecko.model.Candle
import com.sonsofcrypto.web3walletcore.common.viewModels.CandlesViewModel

fun Candle.toViewModelCandle(): CandlesViewModel.Candle = CandlesViewModel.Candle(
    open,
    high,
    low,
    close,
    0.toDouble(),
    timestamp.epochSeconds.toDouble()
)

fun List<Candle>.toViewModelCandles(): List<CandlesViewModel.Candle> =
    map { it.toViewModelCandle() }
