package com.sonsofcrypto.web3walletcore.modules.networks

import com.sonsofcrypto.web3lib.types.Network

sealed class NetworksWireframeDestination {
    object Dashboard: NetworksWireframeDestination()
    data class EditNetwork(val network: Network): NetworksWireframeDestination()
}

interface NetworksWireframe {
    fun present()
    fun navigate(destination: NetworksWireframeDestination)
}
