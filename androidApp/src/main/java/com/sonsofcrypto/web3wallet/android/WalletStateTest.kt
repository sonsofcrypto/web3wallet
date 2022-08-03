package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.services.keyStore.DefaultKeyStoreService
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3lib.services.walletsState.DefaultWalletsStateService
import com.sonsofcrypto.web3lib.services.walletsState.WalletsStateEvent
import com.sonsofcrypto.web3lib.services.walletsState.WalletsStateListener
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.currentThreadId
import kotlinx.coroutines.runBlocking

class WalletStateTest: WalletsStateListener {

    fun runAll() {
        testBlockNumber()
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun testBlockNumber() {
        val listener = this
        runBlocking {
            val keyStoreItem = KeyStoreItem(
                uuid = "WalletStateTest.KeyStoreItem",
                name = "Wallet State Test",
                sortOrder = 1u,
                type = KeyStoreItem.Type.MNEMONIC,
                passUnlockWithBio = true,
                iCloudSecretStorage = true,
                saltMnemonic = false,
                passwordType = KeyStoreItem.PasswordType.BIO,
                derivationPath = "m/44'/60'/0'/0/0",
                addresses = mapOf(
                    "m/44'/60'/0'/0/0" to "0x9fFd5aEFd25E18bb8AaA171b8eC619d94AD6AAf0"
                ),
            )
            val keyStoreService = DefaultKeyStoreService(
                KeyValueStore("WalletStateTest.KeyStoreService"),
                KeyStoreTest.MockKeyChainService()
            )
            val wallet = Wallet(keyStoreItem, keyStoreService)
            wallet.connect(ProviderPocket(Network.ethereum()))
            val walletStateService = DefaultWalletsStateService(
                KeyValueStore("WalletStateTest.WalletsStateService")
            )
            walletStateService.add(listener, wallet, listOf(Currency.ethereum()))
        }
    }

    override fun handle(event: WalletsStateEvent) {
        println("=== GOT EVENT $event ${currentThreadId()}")
    }
}