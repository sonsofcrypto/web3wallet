package com.sonsofcrypto.web3lib_services.CurrencyMetadata

import platform.UIKit.UIImage
import platform.UIKit.UIImage.*


actual class BundledImageProvider {

    actual fun image(id: String): ByteArray? {
        TODO("Load image")
        return null // UIImage(named: id)?.pngData()?.toByteArray()
    }
}