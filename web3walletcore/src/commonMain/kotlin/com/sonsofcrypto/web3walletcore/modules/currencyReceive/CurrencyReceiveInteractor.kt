package com.sonsofcrypto.web3walletcore.modules.currencyReceive

import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.types.toHexStringAddress

interface CurrencyReceiveInteractor {
    fun receivingAddress(network: Network, currency: Currency): String?
}

class DefaultCurrencyReceiveInteractor(
    val networksService: NetworksService
): CurrencyReceiveInteractor {

    override fun receivingAddress(network: Network, currency: Currency) =
        networksService.wallet(network)?.address()?.toHexStringAddress()?.hexString
}