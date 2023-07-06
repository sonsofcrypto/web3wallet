package com.sonsofcrypto.web3lib.services.wallet

import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network

interface RootService {

}

class DefaultRootService: RootService {

    fun executePool(network: Network, currencies: List<Currency>, provider: Provider) {

    }
}