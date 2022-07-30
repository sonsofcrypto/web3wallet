package com.sonsofcrypto.web3lib.services.keyStore

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.utils.BigInt

interface Web3Service {
    var wallet: Wallet?
    var network: Network?

    fun enabledNetworks(): List<Network>
    fun setNetwork(network: Network, enabled: Boolean)

    fun provider(network: Network): Provider?
    fun setProvider(network: Network, provider: Provider?)

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
            networks = this.defaultNetworks(value)
            network = this.defaultSelectedNetwork(value)
        }

    override var network: Network? = null
        set(value) {
            field = value
            emit(Web3Service.Event.NetworkSelected(value))
        }

    private var networks: List<Network> = listOf()
        set(value) {
            field = value
            updateProviders(value)
            emit(Web3Service.Event.NetworksChanged(value))
        }

    private var providers: MutableMap<Network, Provider> = mutableMapOf()
    private var listeners: List<Web3Service.Listener> = listOf()
    private var store: KeyValueStore

    constructor(store: KeyValueStore) {
        this.store = store
    }

    override fun enabledNetworks(): List<Network> = networks

    override fun setNetwork(network: Network, enabled: Boolean) {
        networks = if (!enabled) networks.filter { it != network }
        else networks + listOf(network)
    }

    override fun provider(network: Network): Provider? = providers[network]

    override fun setProvider(network: Network, provider: Provider?) {
        if (provider != null) {
            providers[network] = provider
        } else providers.remove(network)
    }

    private fun updateProviders(networks: List<Network>) = networks.forEach {
        setProvider(it, defaultProvider(it))
    }

    private fun defaultNetworks(wallet: Wallet?): List<Network> {
        if (wallet == null) return listOf()
        if (store.allKeys().contains(wallet.id())) {
            return store[wallet.id()] ?: listOf()
        }
        return listOf(
            Network.ethereum()
        )
    }

    private fun defaultSelectedNetwork(wallet: Wallet?): Network? {
        if (wallet != null) {
            return store[selectedNetworkKey(wallet)] ?: networks.first()
        }
        return null
    }

    private fun defaultProvider(network: Network): Provider {
        return ProviderPocket(network)
    }

    private fun selectedNetworkKey(wallet: Wallet): String {
        return "last_selected_network" + wallet.id()
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
}
