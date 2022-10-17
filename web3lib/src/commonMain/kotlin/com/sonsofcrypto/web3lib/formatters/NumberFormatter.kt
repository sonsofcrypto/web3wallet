package com.sonsofcrypto.web3lib.formatters

sealed class NumberFormatterStyle {
    data class Currency(
        val localeIdentifier: String,
        val currencyCode: String,
    ): NumberFormatterStyle()

    data class Percentage(
        val localeIdentifier: String,
        val maximumFractionDigits: ULong,
        val positivePrefix: String,
        val negativePrefix: String,
    ): NumberFormatterStyle()
}

expect class NumberFormatter() {
    fun format(amount: Double?, style: NumberFormatterStyle): String?
}
