package com.sonsofcrypto.web3lib_services

import com.sonsofcrypto.keyvaluestore.KeyValueStore
import com.sonsofcrypto.web3lib_core.Network
import com.sonsofcrypto.web3lib_signer.Wallet
import com.sonsofcrypto.web3lib_provider.Provider
import com.sonsofcrypto.web3lib_provider.ProviderPocket

interface Web3Service {

    var wallet: Wallet?
    var network: Network?

    fun enabledNetworks(): List<Network>
    fun setNetwork(network: Network, enabled: Boolean)

    fun provider(network: Network): Provider?
    fun setProvider(network: Network, provider: Provider?)

    companion object {}
}

fun Web3Service.Companion.supportedNetworks(): List<Network> = Network.supported()

/** DefaultWeb3Service */
class DefaultWeb3Service: Web3Service {

    override var wallet: Wallet? = null
        set(value) {
            field = value
            networks = this.defaultNetworks(value)
        }

    override var network: Network? = null

    private var networks: List<Network> = mutableListOf()
    private var providers: MutableMap<Network, Provider> = mutableMapOf()
    private var store: KeyValueStore

    constructor(store: KeyValueStore) {
        this.store = store
    }

    override fun enabledNetworks(): List<Network> = networks

    override fun setNetwork(network: Network, enabled: Boolean) {
        if (!enabled) {
            networks = networks.filter { it != network }
            providers.remove(network)
            return;
        }
        networks = networks + listOf(network)
        providers[network] = defaultProvider(network)
    }

    override fun provider(network: Network): Provider? = providers[network]

    override fun setProvider(network: Network, provider: Provider?) {
        if (provider != null) {
            providers[network] = provider
        } else providers.remove(network)
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

    private fun defaultProvider(network: Network): Provider {
        return ProviderPocket(network)
    }
}
