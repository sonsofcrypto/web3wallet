package com.sonsofcrypto.web3lib.services.wallet

import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService

/** */
interface WalletService {
    
}

class DefaultWalletService(
    private val networkService: NetworksService,
    private val currencyStoreService: CurrencyStoreService
): WalletService {

}

//currencies(Wallet)    //
//setCurrencies(Wallet) //

//balance(wallet, currency)
//send(wallet, currency, amount)

//transactions