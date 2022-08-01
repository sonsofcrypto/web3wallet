package com.sonsofcrypto.web3lib.services.currencyMetadata

expect class BundledAssetProvider {
    constructor()
    fun image(id: String): ByteArray?
    fun file(name: String, ext: String): ByteArray?
}