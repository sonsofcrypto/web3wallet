package com.sonsofcrypto.web3walletcore.extensions

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.formatters.Formatters.Style.Custom
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.NetworkFee
import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3walletcore.common.viewModels.NetworkFeeViewModel

val NetworkFee.timeString: String get() {
    val min: Double = seconds.toDouble() / 60.toDouble()
    return if (min > 1) { "${min.toInt()} ${Localized("min")}" }
    else { "$seconds ${Localized("sec")}" }
}

fun NetworkFee.toNetworkFeeViewModel(
    currencyFiatPrice: Double,
    amountDigits: UInt = 10u,
    fiatPriceDigits: UInt = 8u,
    fiatPriceCurrencyCode: String = "usd"
): NetworkFeeViewModel =
    NetworkFeeViewModel(
        Localized("networkFeeView.estimatedFee"),
        networkFeeAmount(amountDigits),
        networkFeeTime(),
        networkFeeFiat(currencyFiatPrice, fiatPriceDigits, fiatPriceCurrencyCode),
    )

private fun NetworkFee.networkFeeAmount(amountDigits: UInt): List<Formatters.Output> =
    Formatters.currency.format(amount, currency, Custom(amountDigits))

private fun NetworkFee.networkFeeTime(): List<Formatters.Output> =
    listOf(Formatters.Output.Normal(timeString))

private fun NetworkFee.networkFeeFiat(
    currencyFiatPrice: Double, fiatPriceDigits: UInt, fiatPriceCurrencyCode: String
): List<Formatters.Output> =
    fiatPrice(amount, currency, Custom(fiatPriceDigits), fiatPriceCurrencyCode, currencyFiatPrice)

private fun NetworkFee.fiatPrice(
    amount: BigInt, currency: Currency, style: Formatters.Style,
    currencyCode: String, currencyFiatPrice: Double
): List<Formatters.Output> {
    val value = Formatters.crypto(amount, currency.decimals(), currencyFiatPrice)
    return Formatters.fiat.format(
        BigDec.from(BigDec.from(value).mul(BigDec.from(100)).toBigInt()).div(BigDec.from(100)),
        style,
        currencyCode
    )
}