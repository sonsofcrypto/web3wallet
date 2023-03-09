package com.sonsofcrypto.web3lib.formatters

import com.sonsofcrypto.web3lib.utils.BigDec
import kotlin.math.max

class BigDecNumberFormatter {
    private val placeholder = "-"
    private val formattersOutput = FormattersOutput()
    fun format(
        amount: BigDec?,
        style: Formatters.Style = Formatters.Style.Max,
    ): List<Formatters.Output> {
        val amount = amount?.toString() ?: return listOf(Formatters.Output.Normal(placeholder))
        var output: List<Formatters.Output> = when (style) {
            is Formatters.Style.Custom -> {
                val maxLength =
                    if (style.maxLength == 0u) 1u
                    else max(1u, style.maxLength)
                if (amount.length.toUInt() <= maxLength) {
                    listOf(Formatters.Output.Normal(amount))
                } else {
                    formattersOutput.convert(amount, maxLength)
                }
            }
            is Formatters.Style.Max -> {
                listOf(Formatters.Output.Normal(amount))
            }
        }
        if (output.count() == 1) {
            when (val elem = output.first()) {
                is Formatters.Output.Normal -> {
                    val parts = elem.value.split(".")
                    if (parts.count() == 2 && parts[1].length == 1) {
                        output =
                            listOf(Formatters.Output.Normal(parts[0] + "." + parts[1] + "0"))
                    }
                }
                is Formatters.Output.Up -> {}
                is Formatters.Output.Down -> {}
            }
        }
        return output
    }
}