package com.sonsofcrypto.web3lib_services.Currencies

import com.sonsofcrypto.keyvaluestore.KeyValueStore
import com.sonsofcrypto.web3lib_core.Currency
import com.sonsofcrypto.web3lib_core.Network
import com.sonsofcrypto.web3lib_signer.Wallet

interface CurrenciesService {
    fun currencies(network: Network): List<Currency>
    fun add(currency: Currency, network: Network)
    fun remove(currency: Currency, network: Network)

    fun generateDefaultCurrencies(network: Network): List<Currency>
}

class DefaultCurrenciesService(
    val wallet: Wallet,
    val store: KeyValueStore,
): CurrenciesService {

    override fun currencies(network: Network): List<Currency> {
        return store.get(id(network)) ?: listOf()
    }

    override fun add(currency: Currency, network: Network) {
        store.set(id(network), currencies(network) + listOf(currency))
    }

    override fun remove(currency: Currency, network: Network) {
        store.set(id(network), currencies(network).filter { it != currency } )
    }

    override fun generateDefaultCurrencies(network: Network): List<Currency> = when(network) {
        Network.ethereum() -> listOf(
            Currency(
                name = "Ethereum",
                symbol = "eth",
                decimals = 18u,
                type = Currency.Type.NATIVE,
                address = null,
                coinGeckoId = "ethereum",
            ),
            Currency(
                name = "Tether",
                symbol = "usdt",
                decimals = 6u,
                type = Currency.Type.ERC20,
                address = null,
                coinGeckoId = "tether",
            ),
            Currency(
                name = "Cult DAO",
                symbol = "cult",
                decimals = 18u,
                type = Currency.Type.ERC20,
                address = "0xf0f9d895aca5c8678f706fb8216fa22957685a13",
                coinGeckoId = "cult-dao",
            ),
            Currency(
                name = "Cult DAO",
                symbol = "cult",
                decimals = 18u,
                type = Currency.Type.ERC20,
                address = "0xf0f9d895aca5c8678f706fb8216fa22957685a13",
                coinGeckoId = "cult-dao",
            ),
        )
        Network.ropsten() -> listOf(
            Currency(
                name = "Ropsten Ethereum",
                symbol = "eth",
                decimals = 18u,
                type = Currency.Type.NATIVE,
                address = null,
                coinGeckoId = "ethereum",
            )
        )
        else -> listOf()
    }

    private fun id(network: Network): String {
        return wallet.id() + network.id()
    }
}