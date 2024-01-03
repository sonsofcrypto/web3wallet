package com.sonsofcrypto.web3walletcore.modules.networkSettings

import com.sonsofcrypto.web3lib.provider.ProviderAlchemy
import com.sonsofcrypto.web3lib.provider.ProviderLocal
import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.networks.ProviderInfo
import com.sonsofcrypto.web3lib.services.networks.ProviderInfo.Type
import com.sonsofcrypto.web3lib.services.networks.from
import com.sonsofcrypto.web3lib.types.Network

interface NetworkSettingsInteractor {
    fun select(type: Type, network: Network)
    fun selectedType(network: Network): Type
    fun supportedProviderTypes(network: Network): List<Type>
}

class DefaultNetworkSettingsInteractor(
    private val networksService: NetworksService
): NetworkSettingsInteractor {

    override fun select(type: Type, network: Network) {
        val provider = when (type) {
            Type.POCKET -> ProviderPocket(network)
            Type.ALCHEMY -> ProviderAlchemy(network)
            Type.LOCAL -> ProviderLocal(network)
            else -> TODO("Implement custom provider")
        }
        networksService.setProvider(provider, network)
    }

    override fun selectedType(network: Network): Type =
        ProviderInfo.from(networksService.provider(network)).type

    override fun supportedProviderTypes(network: Network): List<Type> =
        NetworksService.supportedProviderTypes(network)
}
