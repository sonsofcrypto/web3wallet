package com.sonsofcrypto.web3lib.services.currencyMetadata

import java.io.File
import java.io.FileReader

actual class BundledAssetProvider {

    actual constructor() {}

    actual fun image(id: String): ByteArray? {
        // TODO: Implement
        return null
    }

    actual fun file(name: String, ext: String): ByteArray? {
        this::class.java.getResource("../")
//        val url = this::class.java.getResource("/json/coin_cache.json").readBytes()
//        println("=== url ${url.size}")
//        return url
        return null
    }
}