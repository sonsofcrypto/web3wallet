package com.sonsofcrypto.web3lib.services

import com.sonsofcrypto.web3lib.KeyStoreTest
import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.randomString
import com.sonsofcrypto.web3lib.services.keyStore.DefaultSignerStoreService
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.BIO
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.Type.MNEMONIC
import com.sonsofcrypto.web3lib.services.keyStore.SecretStorage
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

    @Test
    fun testNewMnemonic() {
        val keyStore = DefaultSignerStoreService(
            KeyValueStore("SignersServiceTests"),
            KeyStoreTest.MockKeyChainService()
        )
        keyStore.items().forEach { keyStore.remove(it) }

        val name = "Test Mnemonic"
        val password = randomString(32)
        val salt = ""
        val worldList = WordList.fromLocaleString("en")
        val bip39 = Bip39.from(ES128, salt, worldList)
        val bip44 = Bip44(bip39.seed(), ExtKey.Version.MAINNETPRV)
        val network = Network.ethereum()
        val derivationPath = network.defaultDerivationPath()
        val extKey = bip44.deriveChildKey(derivationPath)
        val signerStoreItem = SignerStoreItem(
            uuid = randomString(32),
            name = name,
            sortOrder = 0u,
            type = MNEMONIC,
            passUnlockWithBio = true,
            iCloudSecretStorage = false,
            saltMnemonic = false,
            passwordType = BIO,
            derivationPath = derivationPath,
            addresses = mapOf<String, String>(
                Pair(
                    derivationPath,
                    network.address(bip44.deriveChildKey(derivationPath).xpub())
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

        keyStore.add(signerStoreItem, password, secretStorage)

        assertTrue(
            keyStore.items().size == 1,
            "Did not save KeyStore item"
        )
        assertTrue(
            signerStoreItem == keyStore.items().first(),
            "Stored item does not equal \n${keyStore.items().first()}\n$signerStoreItem"
        )
        val decryptedMnemonic = keyStore.secretStorage(signerStoreItem, password)
            ?.decrypt(password)
            ?.mnemonic
        assertTrue(
            bip39.mnemonic.joinToString(" ") == decryptedMnemonic,
            "Decrypted Mnemonic\n$decryptedMnemonic|\n${bip39.mnemonic.joinToString(" ")}|"
        )

//        keyStore.items().forEach { keyStore.remove(it) }
//        assertTrue(keyStore.items().size == 0, "Failed to remove items")
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