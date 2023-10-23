package com.sonsofcrypto.web3lib.services

import com.sonsofcrypto.web3lib.KeyStoreTest
import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.randomString
import com.sonsofcrypto.web3lib.services.keyStore.DefaultSignerStoreService
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.BIO
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.Type.MNEMONIC
import com.sonsofcrypto.web3lib.services.keyStore.SecretStorage
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3lib.types.Bip44
import com.sonsofcrypto.web3lib.types.ExtKey
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.bip39.Bip39.EntropySize.ES128
import com.sonsofcrypto.web3lib.utils.bip39.WordList
import com.sonsofcrypto.web3lib.utils.bip39.localeString
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import kotlin.test.Test
import kotlin.test.assertTrue

class SignersServiceTests {

    private fun cleanSignerStoreService(): SignerStoreService {
        val service = DefaultSignerStoreService(
            KeyValueStore("SignerServiceTests"),
            KeyStoreTest.MockKeyChainService()
        )
        service.items().forEach { service.remove(it) }
        return service
    }

    private data class MnemonicSignerItems(
        val signerStoreItem: SignerStoreItem,
        val secretStorage: SecretStorage,
        val bip39: Bip39,
    )

    private fun newMnemonicSigner(
        name: String = "Test Mnemonic",
        password: String = randomString(32),
        salt: String = "",
        network: Network = Network.ethereum(),
        derivationPath: String? = null
    ): MnemonicSignerItems {
        val worldList = WordList.fromLocaleString("en")
        val bip39 = Bip39.from(ES128, salt, worldList)
        val bip44 = Bip44(bip39.seed(), ExtKey.Version.MAINNETPRV)
        val keyPath = derivationPath ?: network.defaultDerivationPath()
        val extKey = bip44.deriveChildKey(keyPath)
        val signerStoreItem = SignerStoreItem(
            uuid = randomString(32),
            name = name,
            sortOrder = 0u,
            type = MNEMONIC,
            passUnlockWithBio = true,
            iCloudSecretStorage = false,
            saltMnemonic = false,
            passwordType = BIO,
            derivationPath = keyPath,
            addresses = mapOf<String, String>(
                Pair(
                    keyPath,
                    network.address(bip44.deriveChildKey(keyPath).xpub())
                        .toHexString(true)
                )
            )
        )
        val secretStorage = SecretStorage.encryptDefault(
            signerStoreItem.uuid,
            extKey.key,
            password,
            network.address(extKey.xpub()).toHexString(true),
            bip39.mnemonic.joinToString(" "),
            bip39.worldList.localeString(),
            derivationPath
        )
        return MnemonicSignerItems(signerStoreItem, secretStorage, bip39)
    }

    @Test
    fun testNewMnemonic() {
        val service = cleanSignerStoreService()
        val password = randomString(32)
        val signer = newMnemonicSigner(
            name = "Test Mnemonic",
            password = password,
        )
        service.add(signer.signerStoreItem, password, signer.secretStorage)

        assertTrue(service.items().size == 1, "Did not save KeyStore item")
        assertTrue(
            signer.signerStoreItem == service.items().first(),
            "Store err \n${service.items().first()}\n${signer.signerStoreItem}"
        )
        
        val decryptedMnemonic = service
            .secretStorage(signer.signerStoreItem, password)
            ?.decrypt(password)
            ?.mnemonic
        assertTrue(
            signer.bip39.mnemonic.joinToString(" ") == decryptedMnemonic,
            "\n$decryptedMnemonic|\n${signer.bip39.mnemonic.joinToString(" ")}|"
        )
    }

    @Test
    fun testLoadAfterMigration() {
        val keyStore = DefaultSignerStoreService(
            KeyValueStore("SignersServiceTests"),
            KeyStoreTest.MockKeyChainService()
        )
        println("${keyStore.items().first()}")
    }

}