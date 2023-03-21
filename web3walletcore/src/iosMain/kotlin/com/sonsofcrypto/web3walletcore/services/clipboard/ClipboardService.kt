package com.sonsofcrypto.web3walletcore.services.clipboard

import platform.Foundation.NSDate
import platform.Foundation.NSNumber
import platform.Foundation.dateByAddingTimeInterval
import platform.UIKit.UIPasteboard
import platform.UIKit.UIPasteboardOptionExpirationDate
import platform.UIKit.UIPasteboardOptionLocalOnly
import platform.UniformTypeIdentifiers.UTTypeUTF8PlainText

actual class ClipboardService {

    actual fun paste(text: String, expireInSeconds: Int) {
        val expirationDate = NSDate().dateByAddingTimeInterval(expireInSeconds.toDouble())
        UIPasteboard.generalPasteboard().setItems(
            listOf(mapOf(UTTypeUTF8PlainText.identifier to text)),
            mapOf(
                UIPasteboardOptionExpirationDate to expirationDate,
                UIPasteboardOptionLocalOnly to NSNumber(true),
            ),
        )
    }
}