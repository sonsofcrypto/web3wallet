package com.sonsofcrypto.web3lib.formatters

import com.sonsofcrypto.web3lib.formatters.NumberFormatterStyle.Currency
import platform.Foundation.*

actual class NumberFormatter: NSNumberFormatter() {

    actual fun format(amount: Double?, style: NumberFormatterStyle): String? {
        val amount = amount ?: return null
        return configure(style).stringFromNumber(NSNumber(amount))
    }

    private fun configure(style: NumberFormatterStyle): NumberFormatter {
        when (style) {
            is Currency -> {
                numberStyle = NSNumberFormatterCurrencyStyle
                locale = NSLocale(style.localeIdentifier)
            }
            is NumberFormatterStyle.Percentage -> {
                numberStyle = NSNumberFormatterPercentStyle
                locale = NSLocale(style.localeIdentifier)
                maximumFractionDigits = style.maximumFractionDigits
                positivePrefix = style.positivePrefix
                negativePrefix = style.negativePrefix
            }
        }
        return this
    }
}