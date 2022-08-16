package com.sonsofcrypto.web3lib.services.currencyMetadata

import com.sonsofcrypto.web3lib.utils.extensions.toByteArray
import platform.Foundation.NSBundle
import platform.Foundation.NSData
import platform.Foundation.dataWithContentsOfURL
import platform.UIKit.UIImage
import platform.UIKit.UIImagePNGRepresentation

actual class BundledAssetProvider {

    actual constructor() {}

    actual fun image(id: String): ByteArray? {
        val image = UIImage.Companion.imageNamed(id)
        if (image != null) {
            return UIImagePNGRepresentation(image)?.toByteArray()
        }
        return null
    }

    actual fun file(name: String, ext: String): ByteArray? {
        return NSBundle.mainBundle.URLForResource(name, ext)?.let { url ->
            return NSData.dataWithContentsOfURL(url)?.toByteArray()
        }
    }
}