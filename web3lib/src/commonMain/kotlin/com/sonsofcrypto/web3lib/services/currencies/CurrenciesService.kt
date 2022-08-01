package com.sonsofcrypto.web3lib.services.currencies

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.services.currencies.model.CurrencyInfo
import com.sonsofcrypto.web3lib.services.currencies.model.ethereumDefaultCurrencies
import com.sonsofcrypto.web3lib.services.currencies.model.listFrom
import com.sonsofcrypto.web3lib.services.currencies.model.ropstenDefaultCurrencies
import com.sonsofcrypto.web3lib.signer.Wallet
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlin.native.concurrent.SharedImmutable

interface CurrenciesService {
    fun currencies(wallet: Wallet, network: Network): List<Currency>
    fun add(currency: Currency, wallet: Wallet, network: Network)
    fun remove(currency: Currency, wallet: Wallet, network: Network)

    fun generateDefaultCurrenciesIfNeeded(wallet: Wallet, network: Network)
    fun defaultCurrencies(network: Network): List<Currency>
    fun currencyList(data: String): List<Currency>
}

class DefaultCurrenciesService(val store: KeyValueStore): CurrenciesService {

    override fun currencies(wallet: Wallet, network: Network): List<Currency> {
        return getCurrencies(id(wallet, network)) ?: listOf()
    }

    override fun add(currency: Currency, wallet: Wallet, network: Network) {
        setCurrencies(
            id(wallet, network),
            currencies(wallet, network) + listOf(currency)
        )
    }

    override fun remove(currency: Currency, wallet: Wallet, network: Network) {
        setCurrencies(
            id(wallet, network),
            currencies(wallet, network).filter { it != currency }
        )
    }

    override fun generateDefaultCurrenciesIfNeeded(wallet: Wallet, network: Network) {
        if (currencies(wallet, network).isEmpty()) {
            setCurrencies(id(wallet, network), defaultCurrencies(network))
        }
    }


    override fun defaultCurrencies(network: Network): List<Currency> {
        return when(network) {
            Network.ethereum() -> ethereumDefaultCurrencies
            Network.ropsten() -> ropstenDefaultCurrencies
            else -> listOf()
        }
    }

    override fun currencyList(data: String): List<Currency> {
        return CurrencyInfo.listFrom(data).map {
            Currency(
                name = it.name,
                symbol = it.symbol,
                decimals = 18u,
                type = if(it.platforms?.ethereum != null) Currency.Type.ERC20
                        else Currency.Type.NATIVE,
                address = it.platforms?.ethereum,
                coinGeckoId = it.id,
            )
        }
    }

    private fun setCurrencies(key: String, currencies: List<Currency>) {
        store[key] = currenciesJson.encodeToString(currencies)
    }

    private fun getCurrencies(key: String): List<Currency>? {
        return store.get<String>(key)?.let {
            return currenciesJson.decodeFromString<List<Currency>>(it)
        }
    }

    private fun id(wallet: Wallet, network: Network): String {
        return wallet.id() + "-" + network.id()
    }
}

@SharedImmutable @OptIn(kotlinx.serialization.ExperimentalSerializationApi::class)
private val currenciesJson = Json {
    encodeDefaults = true
    isLenient = true
    ignoreUnknownKeys = true
    coerceInputValues = true
    allowStructuredMapKeys = true
    useAlternativeNames = false
    prettyPrint = false
    useArrayPolymorphism = true
    explicitNulls = true
}