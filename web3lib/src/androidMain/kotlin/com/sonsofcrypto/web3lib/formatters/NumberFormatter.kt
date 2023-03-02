package com.sonsofcrypto.web3lib.formatters

import android.icu.text.DecimalFormat
import android.icu.text.NumberFormat
import java.util.*

actual class NumberFormatter {

    actual fun format(amount: Double?, style: NumberFormatterStyle): String? {
        return  numberFormat(style).format(amount)
    }

    private fun numberFormat(style: NumberFormatterStyle): NumberFormat {
        val numberFormat = NumberFormat.getInstance(Locale(style.locale))
        when (style) {
            is NumberFormatterStyle.Currency -> {
                // numberStyle = NSNumberFormatterCurrencyStyle
                // numberFormat.currency = Currency.getInstance(curencyCode = style.currencyCode)
            }
            is NumberFormatterStyle.Percentage -> {
                numberFormat.maximumFractionDigits = style.maximumFractionDigits.toInt()
            }
        }
        return numberFormat
    }

    private val NumberFormatterStyle.locale: String get() = when(this) {
        is NumberFormatterStyle.Currency -> { this.locale }
        is NumberFormatterStyle.Percentage -> { this.locale }
    }
}