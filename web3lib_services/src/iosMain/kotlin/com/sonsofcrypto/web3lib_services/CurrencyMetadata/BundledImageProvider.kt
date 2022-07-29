package com.sonsofcrypto.web3lib_services.CurrencyMetadata

import com.sonsofcrypto.web3lib_utils.toByteArray
import platform.UIKit.UIImage
import platform.UIKit.UIImagePNGRepresentation

actual class BundledImageProvider {

    actual fun image(id: String): ByteArray? {
        val image = UIImage.Companion.imageNamed(id)
        if (image != null) {
            return UIImagePNGRepresentation(image)?.toByteArray()
        }
        return null
    }
}