package com.sonsofcrypto.web3lib_core

class Network(
    val name: String,
    val chainId: UInt,
    val nameServiceAddress: AddressBytes?
) {

    companion object {

        fun ethereum() = Network("Ethereum", 1u, null)
        fun ropsten() = Network("Ropsten", 3u, null)
        fun rinkeby() = Network("Rinkeby", 4u, null)
        fun goerli() = Network("Goerli", 5u, null)
    }

}