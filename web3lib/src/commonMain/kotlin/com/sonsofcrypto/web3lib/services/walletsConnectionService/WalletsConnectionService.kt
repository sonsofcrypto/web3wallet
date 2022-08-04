package com.sonsofcrypto.web3lib.services.walletsConnectionService

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.types.Network
import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

sealed class WalletsConnectionEvent() {
    data class WalletSelected(val wallet: Wallet?): WalletsConnectionEvent()
    data class NetworkSelected(val network: Network?): WalletsConnectionEvent()
    data class NetworksChanged(val networks: List<Network>): WalletsConnectionEvent()
}

interface WalletsConnectionListener{
    fun handle(event: WalletsConnectionEvent)
}

interface WalletsConnectionService {
    var wallet: Wallet?
    var network: Network?

    fun enabledNetworks(): List<Network>
    fun setNetwork(network: Network, enabled: Boolean)

    fun provider(network: Network): Provider?
    fun setProvider(network: Network, provider: Provider?)
    fun setProvider(network: Network, provider: ProviderInfo)

    fun walletsForAllNetwork(): List<Wallet>
    fun wallet(network: Network): Wallet?

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

    fun addListener(listener: WalletsConnectionListener)
    fun removeListener(listener: WalletsConnectionListener?)

    companion object {}
}

/** DefaultWalletsConnectionService */
class DefaultWalletsConnectionService: WalletsConnectionService {

    override var wallet: Wallet? = null
        set(value) {
            field = value
            emit(WalletsConnectionEvent.WalletSelected(value))
            enabledNetworks = this.defaultNetworks(value)
            network = this.defaultSelectedNetwork(value)
        }

    override var network: Network? = null
        set(value) {
            field = value
            wallet?.let { store[selectedNetworkKey(it)] = value }
            emit(WalletsConnectionEvent.NetworkSelected(value))
        }

    private var enabledNetworks: List<Network> = listOf()
        set(value) {
            field = value
            updateProviders()
            updateWallets()
            emit(WalletsConnectionEvent.NetworksChanged(value))
            storeNetworks(value, wallet)
        }

    private var providers: MutableMap<Network, Provider> = mutableMapOf()
    private var wallets: MutableMap<String, Wallet> = mutableMapOf()
    private var listeners: List<WalletsConnectionListener> = listOf()
    private var store: KeyValueStore

    constructor(store: KeyValueStore) {
        this.store = store
    }

    override fun enabledNetworks(): List<Network> {
        return enabledNetworks
    }

    override fun setNetwork(network: Network, enabled: Boolean) {
        enabledNetworks = if (!enabled) enabledNetworks.filter { it != network }
        else enabledNetworks + listOf(network)
    }

    override fun provider(network: Network): Provider? {
        if (providers[network] != null)
            return providers[network]

        store.get<WalletsConnectionService.ProviderInfo>(providerKey(network))?.let {
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

    override fun setProvider(network: Network, provider: WalletsConnectionService.ProviderInfo) {
        setProvider(network, provider(provider, network))
    }

    override fun walletsForAllNetwork(): List<Wallet> {
        return enabledNetworks.mapNotNull { wallet(it) }
    }

    private fun updateProviders() {
        val providers = mutableMapOf<Network, Provider>()
        enabledNetworks().forEach { setProvider(it, provider(it)) }
        this.providers = providers
    }

    override fun wallet(network: Network): Wallet? {
        var wallet = wallets[network.id()]
        if (wallet != null)
            return wallet

        wallet = wallet?.copy(provider(network))
        if (wallet != null)
            wallets[network.id()] = wallet
            return wallet

        return null
    }

    private fun updateWallets() {
        val wallets = mutableMapOf<String, Wallet>()
        enabledNetworks().forEach { network ->
            wallet?.copy(provider(network))?.let {
                wallets[network.id()] = it
            }
        }
        this.wallets = wallets
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

    override fun addListener(listener: WalletsConnectionListener) {
        listeners = listeners + listOf(listener)
    }

    override fun removeListener(listener: WalletsConnectionListener?) {
        if (listener != null) listeners = listeners.filter { it != listener }
        else listeners = listOf()
    }

    private fun emit(event: WalletsConnectionEvent) = listeners.forEach {
        it.handle(event)
    }

    // TODO: - Fix Kotlin serialization
    private fun storeNetworks(networks: List<Network>, wallet: Wallet?) {
        if (wallet != null) {
            store[networksKey(wallet)] = Json.encodeToString(networks)
        }
    }

    // TODO: - Fix Kotlin serialization
    private fun getStoredNetworks(wallet: Wallet?): List<Network>? {
        wallet?.let { unwrappedWallet: Wallet ->
            store.get<String>(networksKey(unwrappedWallet))?.let {
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

    private fun providerType(provider: Provider): WalletsConnectionService.ProviderInfo {
        return when (provider) {
            is ProviderPocket -> return WalletsConnectionService.ProviderInfo(
                WalletsConnectionService.ProviderInfo.Type.POCKET
            )
            else -> WalletsConnectionService.ProviderInfo(WalletsConnectionService.ProviderInfo.Type.CUSTOM)
        }
    }

    private fun provider(
        info: WalletsConnectionService.ProviderInfo,
        network: Network
    ): Provider = when (info.type) {
        WalletsConnectionService.ProviderInfo.Type.POCKET -> ProviderPocket(network)
        else -> TODO("Implement custom provider")
    }
}

