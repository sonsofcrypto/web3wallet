package com.sonsofcrypto.web3walletcore.modules.currencyAdd

import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Currency.Type.ERC20
import com.sonsofcrypto.web3lib.types.Network

interface CurrencyAddInteractor {
    fun addCurrency(
        contractAddress: String, name: String, symbol: String, decimals: UInt, network: Network
    )
}

class DefaultCurrencyAddInteractor(
    val currencyStoreService: CurrencyStoreService
): CurrencyAddInteractor {

    override fun addCurrency(
        contractAddress: String, name: String, symbol: String, decimals: UInt, network: Network
    ) {
        currencyStoreService.add(
            Currency(name, symbol.lowercase(), decimals, contractAddress, null),
            network
        )
    }
}