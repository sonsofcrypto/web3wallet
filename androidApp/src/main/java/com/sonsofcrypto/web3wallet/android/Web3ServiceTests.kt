package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.services.keyStore.DefaultKeyStoreService
import com.sonsofcrypto.web3lib.services.keyStore.DefaultWeb3Service
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.types.Network
import java.lang.Exception

class Web3ServiceTests {

    fun runAll() {
        testProviderStore()
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun testProviderStore() {
        val keyStore = DefaultKeyStoreService(
            KeyValueStore("KeyStoreItemsTest2"),
            KeyStoreTest.MockKeyChainService()
        )

        keyStore.selected = mockKeyStoreItem

        val web3service = DefaultWeb3Service(KeyValueStore("web3serviceTest"))
        web3service.wallet = Wallet(mockKeyStoreItem, keyStoreService = keyStore)

        val provider = ProviderPocket(Network.ropsten())
        web3service.setProvider(Network.ropsten(), provider)

        val web3service2 = DefaultWeb3Service(KeyValueStore("web3serviceTest"))
        web3service2.wallet = Wallet(mockKeyStoreItem, keyStoreService = keyStore)
        val provider2 = web3service.provider(Network.ropsten())

        println("=== provider2 ${provider2?.network}")
    }

    private val mockKeyStoreItem = KeyStoreItem(
        uuid = "uuid001",
        name = "wallet mock",
        sortOrder = 0u,
        type = KeyStoreItem.Type.MNEMONIC,
        passUnlockWithBio = true,
        iCloudSecretStorage = true,
        saltMnemonic = true,
        passwordType = KeyStoreItem.PasswordType.PASS,
        addresses = mapOf(
            "m/44'/60'/0'/0/0" to "71C7656EC7ab88b098defB751B7401B5f6d8976F",
            "m/44'/80'/0'/0/0" to "71C7656EC7ab88b098defB751B7401B5f6d8976F",
        ),
    )
}