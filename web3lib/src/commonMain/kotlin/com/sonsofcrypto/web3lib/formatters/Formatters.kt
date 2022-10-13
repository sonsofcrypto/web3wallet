package com.sonsofcrypto.web3lib.formatters

class Formatters {

    companion object {
        val currency = CurrencyFormatter()
        val fiat = FiatFormatter()
        val pct = PctFormatter()
    //        val date: DateTimeFormatter()
        val networkAddress = NetworkAddressFormatter()
    }

    sealed class Style {
        data class Custom(val maxLength: UInt): Style()
        object Max: Style()
    }

    sealed class Output {
        data class Up(val value: String): Output()
        data class Normal(val value: String): Output()
        data class Down(val value: String): Output()
    }
}