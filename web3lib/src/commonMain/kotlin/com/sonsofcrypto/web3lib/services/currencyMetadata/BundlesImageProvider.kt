package com.sonsofcrypto.web3lib.services.currencyMetadata

expect class BundledImageProvider {
    fun image(id: String): ByteArray?
}