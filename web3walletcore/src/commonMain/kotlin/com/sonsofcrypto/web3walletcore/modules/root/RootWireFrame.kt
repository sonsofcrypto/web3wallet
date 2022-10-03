package com.sonsofcrypto.web3walletcore.modules.root

enum class RootWireframeDestination {
    DASHBOARD,
    NETWORKS,
    KEYSTORE,
    OVERVIEW,
    OVERVIEWNETWORKS,
    OVERVIEWKEYSTORE,
}

interface RootWireframe {
    fun present()
    fun navigate(destination: RootWireframeDestination)
}