package com.sonsofcrypto.web3lib.services.currencyMetadata

import com.sonsofcrypto.web3lib.utils.toByteArray
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