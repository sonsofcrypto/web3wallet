package com.sonsofcrypto.web3walletcore.modules.networks

data class NetworksViewModel(
    val header: String,
    val sections: List<Section>,
) {
    data class Section(
        val header: String,
        val networks: List<Network>,
    )

    data class Network(
        val chainId: UInt,
        val name: String,
        val connected: Boolean,
        val imageName: String,
        val connectionType: String,
        val isSelected: Boolean,
    )
}
