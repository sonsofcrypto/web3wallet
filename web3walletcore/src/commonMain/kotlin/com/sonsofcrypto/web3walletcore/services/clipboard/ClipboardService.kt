package com.sonsofcrypto.web3walletcore.services.clipboard

expect class ClipboardService() {
    fun paste(text: String, expireInSeconds: Int = 30)
}