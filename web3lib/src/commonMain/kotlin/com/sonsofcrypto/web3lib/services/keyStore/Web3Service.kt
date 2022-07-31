package com.sonsofcrypto.web3lib.services.keyStore

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.utils.BigInt
import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

interface Web3Service {
    var wallet: Wallet?
    var network: Network?

    fun enabledNetworks(): List<Network>
    fun setNetwork(network: Network, enabled: Boolean)

    fun provider(network: Network): Provider?
    fun setProvider(network: Network, provider: Provider?)
    fun setProvider(network: Network, provider: ProviderInfo)

    @Serializable
    data class ProviderInfo(
        val type: Type,
        val name: String? = null,
        val url: String? = null,
        val chainId: Int? = null,
        val currencySymbol: String? = null,
    ) {
        @Serializable
        enum class Type() { POCKET, CUSTOM }
    }

    fun blockNumber(network: Network): BigInt

    sealed class Event() {
        data class WalletSelected(val wallet: Wallet?): Event()
        data class NetworkSelected(val network: Network?): Event()
        data class NetworksChanged(val networks: List<Network>): Event()
        data class BlockUpdated(val number: BigInt): Event()
    }

    interface Listener{
        fun handle(event: Event)
    }

    fun addListener(listener: Listener)
    fun removeListener(listener: Listener?)

    companion object {}
}

/** DefaultWeb3Service */
class DefaultWeb3Service: Web3Service {

    override var wallet: Wallet? = null
        set(value) {
            field = value
            emit(Web3Service.Event.WalletSelected(value))
            enabledNetworks = this.defaultNetworks(value)
            network = this.defaultSelectedNetwork(value)
        }

    override var network: Network? = null
        set(value) {
            field = value
            wallet?.let { store[selectedNetworkKey(it)] = value }
            emit(Web3Service.Event.NetworkSelected(value))
        }

    private var enabledNetworks: List<Network> = listOf()
        set(value) {
            field = value
            value.forEach { setProvider(it, provider(it)) }
            emit(Web3Service.Event.NetworksChanged(value))
            storeNetworks(value, wallet)
        }

    private var providers: MutableMap<Network, Provider> = mutableMapOf()
    private var listeners: List<Web3Service.Listener> = listOf()
    private var store: KeyValueStore

    constructor(store: KeyValueStore) {
        this.store = store
    }

    override fun enabledNetworks(): List<Network> {
        println("=== returning enabled network ${enabledNetworks.count()} $enabledNetworks")
        return enabledNetworks
    }

    override fun setNetwork(network: Network, enabled: Boolean) {
        enabledNetworks = if (!enabled) enabledNetworks.filter { it != network }
        else enabledNetworks + listOf(network)
    }

    override fun provider(network: Network): Provider? {
        if (providers[network] != null)
            return providers[network]

        store.get<Web3Service.ProviderInfo>(providerKey(network))?.let {
            providers[network] = provider(it, network)
            return providers[network]
        }

        providers[network] = defaultProvider(network)
        return providers[network]
    }

    override fun setProvider(network: Network, provider: Provider?) {
        provider?.let { store[providerKey(network)] = providerType(provider) }
        if (provider != null) {
            providers[network] = provider
        } else providers.remove(network)
    }

    override fun setProvider(network: Network, provider: Web3Service.ProviderInfo) {
        setProvider(network, provider(provider, network))
    }

    private fun defaultNetworks(wallet: Wallet?): List<Network> {
        getStoredNetworks(wallet)?.let {
            return it
        }
        return listOf(Network.ethereum())
    }

    private fun defaultSelectedNetwork(wallet: Wallet?): Network? {
        if (wallet != null) {
            return store[selectedNetworkKey(wallet)] ?: enabledNetworks.first()
        }
        return null
    }

    private fun defaultProvider(network: Network): Provider {
        return store[providerKey(network)] ?: ProviderPocket(network)
    }

    override fun addListener(listener: Web3Service.Listener) {
        listeners = listeners + listOf(listener)
    }

    override fun removeListener(listener: Web3Service.Listener?) {
        if (listener != null) listeners = listeners.filter { it != listener }
        else listeners = listOf()
    }

    private fun emit(event: Web3Service.Event) = listeners.forEach {
        it.handle(event)
    }

    override fun blockNumber(network: Network): BigInt {
        return store.get("lastKnownBlock${network.chainId}") ?: BigInt.zero()
    }

    // TODO: - Screw Kotlin's serialization and generics. Implement our own
    private fun storeNetworks(networks: List<Network>, wallet: Wallet?) {
        if (wallet != null) {
            store[networksKey(wallet)] = Json.encodeToString(networks)
        }
    }

    // TODO: - Screw Kotlin's serialization and generics. Implement our own
    private fun getStoredNetworks(wallet: Wallet?): List<Network>? {
        wallet?.let { wallet: Wallet ->
            store.get<String>(networksKey(wallet))?.let {
                return Json.decodeFromString(it)
            }
        }
        return null
    }

    private fun selectedNetworkKey(wallet: Wallet): String {
        return "last_selected_network_" + wallet.id()
    }

    private fun networksKey(wallet: Wallet): String {
        return "enabled_networks_" + wallet.id()
    }

    private fun providerKey(network: Network): String {
        return "provider_${network.chainId}"
    }

    private fun providerType(provider: Provider): Web3Service.ProviderInfo {
        return when (provider) {
            is ProviderPocket -> return Web3Service.ProviderInfo(
                Web3Service.ProviderInfo.Type.POCKET
            )
            else -> Web3Service.ProviderInfo(Web3Service.ProviderInfo.Type.CUSTOM)
        }
    }

    private fun provider(
        info: Web3Service.ProviderInfo,
        network: Network
    ): Provider = when (info.type) {
        Web3Service.ProviderInfo.Type.POCKET -> ProviderPocket(network)
        else -> TODO("Implement custom provider")
    }
}

