package com.sonsofcrypto.web3walletcore.modules.degen

sealed class DegenWireframeDestination {
    object Swap: DegenWireframeDestination()
    object Cult: DegenWireframeDestination()
    object ComingSoon: DegenWireframeDestination()
}

interface DegenWireframe {
    fun present()
    fun navigate(destination: DegenWireframeDestination)
}
