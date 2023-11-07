package com.sonsofcrypto.web3walletcore.modules.account

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3walletcore.common.viewModels.CandlesViewModel

data class AccountViewModel(
    val currencyName: String,
    val header: Header,
    val address: Address,
    val candles: CandlesViewModel,
    val marketInfo: MarketInfo,
    val bonusAction: BonusAction?,
    val transactions: List<Transaction>,
) {
    data class Header(
        val balance: List<Formatters.Output>,
        val fiatBalance: List<Formatters.Output>,
        val pct: String,
        val pctUp: Boolean,
        val buttons: List<Button>,
    ) {
        data class Button(
            val title: String,
            val imageName: String,
        )
    }

    data class Address(
        val addressFormatted: String,
        val address: String,
    )

    data class MarketInfo(
        val marketCap: List<Formatters.Output>,
        val price: List<Formatters.Output>,
        val volume: List<Formatters.Output>,
    )

    data class BonusAction(
        val title: String,
    )

    sealed class Transaction {
        data class Empty(val text: String): Transaction()
        data class Loading(val text: String): Transaction()
        data class Loaded(val data: Data): Transaction()

        data class Data(
            val date: String,
            val address: String,
            val amount: List<Formatters.Output>,
            val fiatPrice: List<Formatters.Output>,
            val isReceive: Boolean,
            val txHash: String,
        )
    }
}
