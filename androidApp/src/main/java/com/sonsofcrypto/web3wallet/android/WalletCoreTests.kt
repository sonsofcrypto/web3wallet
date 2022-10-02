package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.keyStore.DefaultKeyStoreService
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3walletcore.*
import com.sonsofcrypto.web3walletcore.root.*

class WalletCoreTests {

        fun runAll() {
            testBuild()
        }

        fun assertTrue(actual: Boolean, message: String? = null) {
            if (!actual) throw Exception("Failed $message")
        }

        fun testBuild() {
            val keyStoreService = DefaultKeyStoreService(
                KeyValueStore("WalletServiceTest.keyStore"),
                KeyStoreTest.MockKeyChainService()
            )

            println(com.sonsofcrypto.web3walletcore.Greeting().greeting())

            val presenter = DefaultRootPresenter(
                MockRootWireframe(),
                keyStoreService
            )
            println("=== IT LIVES $presenter")
            val debug = System.getProperty("java.library.path")
            println("=== debug $debug")
            val bip39 = Bip39.from(Bip39.EntropySize.ES128)
            println(bip39.mnemonic)
        }

}

class MockRootWireframe: RootWireframe {

    override fun present() {
        println("present")
    }

    override fun navigate(destination: RootWireframeDestination) {
         println("navigate $destination")
    }
}