package com.sonsofcrypto.web3wallet

import com.sonsofcrypto.web3lib_core.*
import com.sonsofcrypto.web3lib_keystore.KeyStoreService

class Web3Service {

    private var selectedWallet: Wallet? = null
    private var selectedNetwork: Network? = null

    private val keyStoreService: KeyStoreService

    constructor(
        keyStoreService: KeyStoreService
    ) {
        this.keyStoreService = keyStoreService
    }

    fun getSelectedWallet(): Wallet? = selectedWallet

    fun setSelectedWallet(wallet: Wallet) {
        // TODO: Disconnect
        selectedWallet = wallet
    }
}
