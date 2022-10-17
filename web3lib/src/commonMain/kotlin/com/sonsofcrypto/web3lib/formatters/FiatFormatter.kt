package com.sonsofcrypto.web3lib.formatters

import com.sonsofcrypto.web3lib.formatters.Formatters.Output.Normal
import com.sonsofcrypto.web3lib.utils.BigDec
import kotlin.math.max
import kotlin.math.min

class FiatFormatter {
    private val placeholder = "-"
    private val formattersOutput = FormattersOutput()
    private data class FiatCurrency(val code: String, val symbol: String)
    private val usd = FiatCurrency("usd", "$")
    private val eur = FiatCurrency("eur", "€")

    fun format(
        amount: BigDec?,
        style: Formatters.Style = Formatters.Style.Max,
        currencyCode: String = "usd"
    ): List<Formatters.Output> {
        val amount = amount?.toString() ?: return listOf(Normal(placeholder))
        val fiat = fiatCurrency(currencyCode)
        val output: List<Formatters.Output> = when (style) {
            is Formatters.Style.Custom -> {
                val maxLength =
                    if (style.maxLength == 0u) 1u
                    else max(1u, style.maxLength - (fiat.symbol.length).toUInt())
                if (amount.length.toUInt() <= maxLength) { listOf(Normal(amount)) }
                else {
                    formattersOutput.convert(amount, maxLength)
                }
            }
            is Formatters.Style.Max -> { listOf(Normal(amount)) }
        }
        return output.addFiatSymbol(fiat)
    }

    private fun fiatCurrency(currencyCode: String): FiatCurrency =
        when (currencyCode) {
            usd.code -> usd
            eur.code -> eur
            else -> usd
        }

    private fun List<Formatters.Output>.addFiatSymbol(fiat: FiatCurrency): List<Formatters.Output> {
        if (isEmpty()) this
        return when (val first = first()) {
            is Normal -> {
                var newList = toMutableList()
                newList.removeFirst()
                newList.add(0, Normal("${fiat.symbol.uppercase()}${first.value}"))
                return newList
            }
            else -> {
                var newList = toMutableList()
                newList.add(0, Normal("${fiat.symbol.uppercase()} "))
                return newList
            }
        }
    }
}