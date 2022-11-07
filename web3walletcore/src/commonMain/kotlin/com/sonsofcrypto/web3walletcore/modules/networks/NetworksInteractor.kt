package com.sonsofcrypto.web3walletcore.modules.networks

import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.services.networks.NetworksEvent
import com.sonsofcrypto.web3lib.services.networks.NetworksListener
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.types.Network

interface NetworkInteractorLister {
    fun handle(event: NetworksEvent)
}

interface NetworksInteractor {
    var selected: Network?
    fun set(network: Network, enabled: Boolean)
    fun isEnabled(network: Network): Boolean
    fun networks(): List<Network>
    fun provider(network: Network): Provider
    fun add(listener: NetworkInteractorLister)
    fun remove(listener: NetworkInteractorLister)
}

class DefaultNetworksInteractor(
    private val networksService: NetworksService
): NetworksInteractor, NetworksListener {
    private var listener: NetworkInteractorLister? = null

    override var selected: Network?
        get() = networksService.network
        set(value) { networksService.network = value }

    override fun set(network: Network, enabled: Boolean) {
        // TODO: @Annon to remove this when the app does not crash if no networks selected at launch
        if (isDisablingLastNetwork(network, enabled)) return
        networksService.setNetwork(network, enabled)
        val enabledNetworks = networksService.enabledNetworks()
        // NOTE: Switch selected network if we disabled it and there are other networks enabled
        val selectedNetwork = networksService.network ?: return
        if (enabledNetworks.contains(selectedNetwork)) return
        selected = enabledNetworks.firstOrNull()
    }

    override fun isEnabled(network: Network): Boolean =
        networksService.enabledNetworks().contains(network)

    override fun networks(): List<Network> = NetworksService.Companion.supportedNetworks()

    override fun provider(network: Network): Provider = networksService.provider(network)

    override fun add(listener: NetworkInteractorLister) {
        if (this.listener != null) { networksService.remove(this) }
        this.listener = listener
        networksService.add(this)
    }

    override fun remove(listener: NetworkInteractorLister) {
        this.listener = null
        networksService.remove(this)
    }

    override fun handle(event: NetworksEvent) {
        listener?.handle(event)
    }

    private fun isDisablingLastNetwork(network: Network, enabled: Boolean): Boolean {
        if (enabled) return false
        val enabledNetworks = networksService.enabledNetworks()
        if (enabledNetworks.count() > 1) return false
        if (network.chainId != enabledNetworks[0].chainId) return false
        return true
    }
}
