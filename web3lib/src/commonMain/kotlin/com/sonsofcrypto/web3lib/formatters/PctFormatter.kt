package com.sonsofcrypto.web3lib.formatters

import com.sonsofcrypto.web3lib.formatters.NumberFormatterStyle.Percentage

class PctFormatter {
    private val placeholder = "-"
    private val formatter = NumberFormatter()

    fun format(amount: Double?, div: Boolean = false): String {
        val amount = amount ?: return placeholder
        val style = Percentage(
            "en", 2u, "+", "-"
        )
        return formatter.format(if (div) amount / 100 else amount, style) ?: placeholder
    }
}