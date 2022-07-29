package com.sonsofcrypto.web3lib_services.CurrencyMetadata

expect class BundledImageProvider {
    fun image(id: String): ByteArray?
}