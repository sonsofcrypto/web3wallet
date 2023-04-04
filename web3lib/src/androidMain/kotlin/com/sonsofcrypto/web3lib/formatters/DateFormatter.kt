package com.sonsofcrypto.web3lib.formatters

import android.text.format.DateFormat
import java.util.*

actual class DateFormatter {

    actual fun format(timestamp: Int, dateFormat: String): String {
        val calendar = Calendar.getInstance(Locale.ENGLISH)
        calendar.timeInMillis = timestamp * 1000L
        return DateFormat.format(dateFormat, calendar).toString()
    }
}