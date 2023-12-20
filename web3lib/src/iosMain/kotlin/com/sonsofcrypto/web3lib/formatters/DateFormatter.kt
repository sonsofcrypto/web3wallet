@file:OptIn(ExperimentalForeignApi::class)

package com.sonsofcrypto.web3lib.formatters

import kotlinx.cinterop.ExperimentalForeignApi
import platform.CoreFoundation.kCFAbsoluteTimeIntervalSince1970
import platform.Foundation.NSDate
import platform.Foundation.NSDateFormatter

actual class DateFormatter: NSDateFormatter() {

    actual fun format(timestamp: Int, dateFormat: String): String {
        this.dateFormat = dateFormat
        val timeIntervalSinceReferenceDate = timestamp.toDouble() - kCFAbsoluteTimeIntervalSince1970
        return stringFromDate(
            NSDate(timeIntervalSinceReferenceDate = timeIntervalSinceReferenceDate)
        )
    }
}