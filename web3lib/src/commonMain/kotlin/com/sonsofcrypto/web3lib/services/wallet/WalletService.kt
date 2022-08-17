package com.sonsofcrypto.web3lib.services.wallet

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.provider.model.Transaction
import com.sonsofcrypto.web3lib.services.currencyStore.*
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.BigInt
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlin.native.concurrent.SharedImmutable

/** `WalletService` higher level "manager" wallet state manager. Should suffice
 * for majority of basic usecases. For more fine grained control use `Wallet`.
 * `WalletService` tracks state of wallet for all enabled networks. Periodically
 * fetches and emits events about relevant data like block and balances, etc.
 * Picks up changes about enabled networks and providers from `NetworksService`
 * Allows for easy transfers of crypto assets.
 */
interface WalletService {
    /** Tracked currencies for network */
    fun currencies(network: Network): List<Currency>
    /** Set tracked currencies for network */
    fun setCurrencies(currencies: List<Currency>, network: Network)

    /** Address for network */
    fun address(network: Network): Address.HexString
    /** Last known balance number for network connected to wallet  */
    fun balance(network: Network, currency: Currency): BigInt
    /** Last known block number for network connected to wallet  */
    fun blockNumber(network: Network): BigInt?
    /** Last known transaction count wallet (in network wallet is connected to) */
    fun transactionCount(network: Network): BigInt

    /** Retrieves private key from secure storage for 5 secs. */
    @Throws(Throwable::class)
    fun unlock(password: String, salt: String, network: Network)
    /** Transfers native currency or ERC20 token. Must call unlock wallet pior*/
    @Throws(Throwable::class)
    suspend fun transfer(currency: Currency, amount: BigInt, network: Network)
    /** List of transactions for wallet */
    fun transactions(network: Network): List<Transaction>
}

class DefaultWalletService(
    private val networkService: NetworksService,
    private val currencyStoreService: CurrencyStoreService,
    private val currenciesCache: KeyValueStore
): WalletService {
    private val currencies: MutableMap<String, List<Currency>> = mutableMapOf()

    override fun currencies(network: Network): List<Currency> {
        currencies[network.id()]?.let { return it }
        currenciesCache.get<String>(network.id())?.let {
            jsonDecode<List<Currency>>(it)?.let { curr -> return curr }
        }
        setCurrencies(defaultCurrencies(network), network)
        return ethereumDefaultCurrencies
    }

    override fun setCurrencies(currencies: List<Currency>, network: Network) {
        this.currencies[network.id()] = currencies
        currenciesCache.set(network.id(), wsJson.encodeToString(currencies))
    }

    override fun address(network: Network): Address.HexString {
        TODO("Not yet implemented")
    }

    override fun balance(network: Network, currency: Currency): BigInt {
        TODO("Not yet implemented")
    }

    override fun blockNumber(network: Network): BigInt? {
        TODO("Not yet implemented")
    }

    override fun transactionCount(network: Network): BigInt {
        TODO("Not yet implemented")
    }

    override fun unlock(password: String, salt: String, network: Network) {
        TODO("Not yet implemented")
    }

    override suspend fun transfer(currency: Currency, amount: BigInt, network: Network) {
        TODO("Not yet implemented")
    }

    override fun transactions(network: Network): List<Transaction> {
        TODO("Not yet implemented")
    }

    private fun defaultCurrencies(network: Network): List<Currency> {
        return when (network) {
            Network.ethereum() -> ethereumDefaultCurrencies
            Network.ropsten() -> ropstenDefaultCurrencies
            Network.rinkeby() -> rinkebyDefaultCurrencies
            Network.goerli() -> goerliDefaultCurrencies
            else -> emptyList()
        }
    }
}

@SharedImmutable
private val wsJson = Json {
    encodeDefaults = true
    isLenient = true
    ignoreUnknownKeys = true
    coerceInputValues = true
    allowStructuredMapKeys = true
    useAlternativeNames = false
    prettyPrint = true
    useArrayPolymorphism = true
    explicitNulls = false
}

private inline fun <reified T> jsonDecode(string: String): T? {
    return wsJson.decodeFromString<T>(string)
}
