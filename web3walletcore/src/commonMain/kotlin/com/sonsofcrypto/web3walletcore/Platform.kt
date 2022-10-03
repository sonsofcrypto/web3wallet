package com.sonsofcrypto.web3walletcore

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform