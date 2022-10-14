package com.sonsofcrypto.web3lib.formatters

import com.sonsofcrypto.web3lib.formatters.Formatters.Output.Normal
import com.sonsofcrypto.web3lib.utils.BigDec

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
        val amount = amount ?: return listOf(Normal(placeholder))
        val fiatCurrency = fiatCurrency(currencyCode)
        val output: List<Formatters.Output> = when (style) {
            is Formatters.Style.Custom -> {
                val maxLength = style.maxLength - (fiatCurrency.symbol.length).toUInt()
                if (amount.toString().length.toUInt() <= maxLength) {
                    listOf(Normal(amount.toString()))
                } else {
                    formattersOutput.convert(
                        amount.toString(),
                        style.maxLength - (fiatCurrency.symbol.length).toUInt()
                    )
                }
            }
            is Formatters.Style.Max -> { listOf(Normal(amount.toString())) }
        }
        return output.addFiatSymbol(fiatCurrency)
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