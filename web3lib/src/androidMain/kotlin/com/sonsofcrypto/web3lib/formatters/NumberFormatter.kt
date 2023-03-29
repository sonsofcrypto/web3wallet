package com.sonsofcrypto.web3lib.formatters

import android.icu.text.NumberFormat
import java.util.*

actual class NumberFormatter {

    actual fun format(amount: Double?, style: NumberFormatterStyle): String? {
        return numberFormat(style).format(amount)
    }

    private fun numberFormat(style: NumberFormatterStyle): NumberFormat = when (style) {
        is NumberFormatterStyle.Currency -> { NumberFormat.getInstance(Locale(style.locale)) }
        is NumberFormatterStyle.Percentage -> {
            val percentFormat = NumberFormat.getPercentInstance()
            percentFormat.maximumFractionDigits = style.maximumFractionDigits.toInt()
            percentFormat
        }
    }

    private val NumberFormatterStyle.locale: String get() = when(this) {
        is NumberFormatterStyle.Currency -> { Locale.getDefault().displayName }
        is NumberFormatterStyle.Percentage -> { Locale.getDefault().displayName }
    }
}