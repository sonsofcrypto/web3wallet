package com.sonsofcrypto.web3lib.services.networks

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.types.Network
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

sealed class NetworksEvent() {
    /** Emitted when `KeyStoreItem` is set */
    object KeyStoreItemDidChange: NetworksEvent()
    /** Emitted when selected `network` changes */
    data class NetworkDidChange(val network: Network?): NetworksEvent()
    /** Emitted when `enabledNetworks` changes */
    data class EnabledNetworksDidChange(val networks: List<Network>): NetworksEvent()
}

/** `NetworksEvent` listener */
interface NetworksListener { fun handle(event: NetworksEvent) }

/** Network service manages enabled `Network`s, `Wallet`s and `Provider`s
 * Enabled and selected networks and provider preferences are persisted.
 */
interface NetworksService {
    /** Selected `KeyStoreItem`, when set rebuilds networks, providers & wallets */
    var keyStoreItem: KeyStoreItem?
    /** Selected `Network`, when set rebuilds networks, providers & wallets */
    var network: Network?
    /** Enabled networks for selected `NetworksService.keyStoreItem` */
    fun enabledNetworks(): List<Network>
    /** Enabled / disable network for selected `NetworksService.keyStoreItem` */
    fun setNetwork(network: Network, enabled: Boolean)
    /** Provider for `network`. Caches previous user selection returns default */
    fun provider(network: Network): Provider
    /** Set `provider` for `network`. Does not rebuild wallets */
    fun setProvider(provider: Provider?, network: Network)
    /** Sets `provider` for `network`. Does not rebuild wallets */
    fun setProvider(provider: ProviderInfo, network: Network)
    /** `Wallet`s for all enabled networks connected to providers */
    fun walletsForEnabledNetworks(): List<Wallet>
    /** `Wallet` for network */
    fun wallet(network: Network): Wallet?
    /** `Wallet` for selected network */
    fun wallet(): Wallet?
    /** Add listener for `NetworksEvent`s */
    fun add(listener: NetworksListener)
    /** Remove listener for `NetworksEvent`s, if null removes all listeners */
    fun remove(listener: NetworksListener?)

    companion object {
        /** Currently supported networks */
        fun supportedNetworks(): List<Network> = listOf(
            Network.ethereum(), Network.ropsten(), Network.rinkeby(),
            Network.goerli(),
        )
    }
}

/** DefaultNetworksService */
class DefaultNetworksService(
    private val store: KeyValueStore,
    private val keyStoreService: KeyStoreService,
): NetworksService {

    override var keyStoreItem: KeyStoreItem? = null
        set(value) {
            field = value
            emit(NetworksEvent.KeyStoreItemDidChange)
            enabledNetworks = this.defaultNetworks(value)
            network = this.defaultSelectedNetwork(value)
        }

    override var network: Network? = null
        set(value) {
            field = value
            store[selectedNetworkKey(keyStoreItem)] = value
            emit(NetworksEvent.NetworkDidChange(value))
        }

    private var enabledNetworks: List<Network> = listOf()
        set(value) {
            field = value
            updateProviders()
            updateWallets()
            emit(NetworksEvent.EnabledNetworksDidChange(value))
            setStoredNetworks(value, keyStoreItem)
        }

    private var providers: MutableMap<Network, Provider> = mutableMapOf()
    private var wallets: MutableMap<String, Wallet> = mutableMapOf()
    private var listeners: List<NetworksListener> = listOf()

    init { keyStoreItem = keyStoreService.selected }

    override fun enabledNetworks(): List<Network> = enabledNetworks

    override fun setNetwork(network: Network, enabled: Boolean) {
        enabledNetworks = if (!enabled) enabledNetworks.filter { it != network }
        else enabledNetworks + listOf(network)
    }

    override fun provider(network: Network): Provider {
        val provider = providers[network]
            ?: store.get<ProviderInfo>(providerKey(network))?.toProvider(network)
            ?: defaultProvider(network)
        providers[network] = provider
        return provider
    }

    override fun setProvider(provider: Provider?, network: Network) {
        provider?.let { store[providerKey(network)] = ProviderInfo.from(it) }
        if (provider != null) providers[network] = provider
        else providers.remove(network)
    }

    override fun setProvider(provider: ProviderInfo, network: Network) {
        setProvider(provider.toProvider(network), network)
    }

    override fun walletsForEnabledNetworks(): List<Wallet> {
        return enabledNetworks.mapNotNull { wallet(it) }
    }

    override fun wallet(network: Network): Wallet? {
        wallets[network.id()]?.let { return it }
        keyStoreItem?.let {
            wallets[network.id()] = Wallet(it, keyStoreService, provider(network))
        }
        return wallets[network.id()]
    }

    override fun wallet(): Wallet? {
        network?.let { return wallet(it) }
        return null
    }

    override fun add(listener: NetworksListener) {
        listeners = listeners + listOf(listener)
    }

    override fun remove(listener: NetworksListener?) {
        if (listener != null) listeners = listeners.filter { it != listener }
        else listeners = listOf()
    }

    private fun emit(event: NetworksEvent) = listeners.forEach {
        it.handle(event)
    }

    private fun updateProviders() {
        providers = mutableMapOf()
        enabledNetworks().forEach { setProvider(provider(it), it) }
    }

    private fun updateWallets() {
        wallets = mutableMapOf()
        enabledNetworks.forEach { wallet(it) }
    }

    private fun defaultNetworks(keyStoreItem: KeyStoreItem?): List<Network> {
        getStoredNetworks(keyStoreItem)?.let { return it }
        return listOf(Network.ethereum())
    }

    private fun defaultSelectedNetwork(item: KeyStoreItem?): Network? {
        return store[selectedNetworkKey(item)] ?: enabledNetworks.first()
    }

    private fun defaultProvider(network: Network): Provider {
        return store[providerKey(network)] ?: ProviderPocket(network)
    }

    private fun getStoredNetworks(item: KeyStoreItem?): List<Network>? {
        store.get<String>(networksKey(item))?.let {
            return Json.decodeFromString(it)
        }
        return null
    }

    private fun setStoredNetworks(networks: List<Network>, item: KeyStoreItem?) {
        store[networksKey(item)] = Json.encodeToString(networks)
    }

    private fun selectedNetworkKey(item: KeyStoreItem?): String {
        return "last_selected_network_${item?.uuid ?: ""}"
    }

    private fun networksKey(keyStoreItem: KeyStoreItem?): String {
        return "enabled_networks_${keyStoreItem?.uuid ?: ""}"
    }

    private fun providerKey(network: Network): String {
        return "provider_${network.chainId}"
    }
}
