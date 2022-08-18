package com.sonsofcrypto.web3lib.services.currencyStore

import com.sonsofcrypto.web3lib.services.coinGecko.model.Candle
import com.sonsofcrypto.web3lib.types.Currency

sealed class CurrencyStoreEvent() {
    /** Cache data has been loaded */
    object CacheLoaded: CurrencyStoreEvent()
    /** New market data received */
    object MarketData: CurrencyStoreEvent()
    /** New candles received */
    data class Candles(
        val candles: List<Candle>,
        val currency: Currency,
    ): CurrencyStoreEvent()
}

interface CurrencyStoreListener { fun handle(event: CurrencyStoreEvent) }
