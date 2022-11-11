package com.sonsofcrypto.web3lib.formatters

expect class DateFormatter() {
    fun format(timestamp: Int, dateFormat: String = "dd-MM-yyyy"): String
}