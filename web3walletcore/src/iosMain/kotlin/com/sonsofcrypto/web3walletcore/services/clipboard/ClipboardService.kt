package com.sonsofcrypto.web3walletcore.services.clipboard

import platform.CoreServices.kUTTypeUTF8PlainText
import platform.Foundation.NSDate
import platform.Foundation.addTimeInterval
import platform.UIKit.UIPasteboard

actual class ClipboardService {

    actual fun paste(text: String, expireInSeconds: Int) {
        val expirationDate = NSDate()
        expirationDate.addTimeInterval(expireInSeconds.toDouble())
        UIPasteboard.generalPasteboard().setItemProviders(
            listOf(mapOf(kUTTypeUTF8PlainText.toString() to text)),
            true,
            expirationDate
        )
    }
}