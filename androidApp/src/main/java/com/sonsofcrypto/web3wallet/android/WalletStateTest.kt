package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.provider.model.BlockTag
import com.sonsofcrypto.web3lib.provider.model.TransactionRequest
import com.sonsofcrypto.web3lib.provider.model.toBigIntData
import com.sonsofcrypto.web3lib.provider.model.toBigIntQnt
import com.sonsofcrypto.web3lib.services.keyStore.DefaultKeyStoreService
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3lib.services.walletsState.DefaultWalletsStateService
import com.sonsofcrypto.web3lib.services.walletsState.WalletsStateEvent
import com.sonsofcrypto.web3lib.services.walletsState.WalletsStateListener
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.signer.contracts.ERC20
import com.sonsofcrypto.web3lib.types.*
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.bip39.WordList
import com.sonsofcrypto.web3lib.utils.currentThreadId
import com.sonsofcrypto.web3lib.utils.toHexString
import kotlinx.coroutines.runBlocking

class WalletStateTest: WalletsStateListener {

    fun runAll() {
//        testBlockNumber()
//        testBalance()
        testBalanceOfERC20()
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
            walletStateService.add(listener)
        }
    }

    fun testBalance() {
        val words = "desert salon chuckle vacuum dad lock argue segment album dog front ordinary"
        val bip39 = Bip39(
            words.split(" "),
            "",
            WordList.ENGLISH
        )
        val bip44 = Bip44(bip39.seed(), ExtKey.Version.MAINNETPRV)
        for (path in listOf("m/44'/60'/0'/0/0")) {
            val key = bip44.deriveChildKey(path)
            val pub = key.xpub()
            val uncompressed = key.uncompressedPub()
            val address = Network.ethereum().address(pub)
            // 0x0480d1b656fb589a55dbfe097c9acafbc95d9a5f
            // 0x0480D1B656fB589A55dBfE097C9ACaFbc95d9A5f
        }

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
                "m/44'/60'/0'/0/0" to "0x0480D1B656fB589A55dBfE097C9ACaFbc95d9A5f"
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
        walletStateService.add(this)
        walletStateService.observe(wallet, listOf(Network.ethereum().nativeCurrency))

    }

    fun testBalanceOfERC20() = runBlocking {
        val provider = ProviderPocket(Network.ethereum())
        val contract = ERC20(Address.HexString("0xdac17f958d2ee523a2206206994597c13d831ec7"))
        val sig = contract.balanceOf(Address.HexString("0x0480D1B656fB589A55dBfE097C9ACaFbc95d9A5f"))
        println(sig)
        val result = provider.call(
            TransactionRequest(
                to = contract.address,
                data = sig,
            ),
            BlockTag.Latest
        )
        println("=== ${result}")
        println("=== ${contract.abiDecode(result)}")
    }


    override fun handle(event: WalletsStateEvent) {
        println("=== GOT EVENT $event ${currentThreadId()}")

        val contract = ERC20(Address.HexString("0xdac17f958d2ee523a2206206994597c13d831ec7"))
        val sig = contract.balanceOf(Address.HexString("0x0480D1B656fB589A55dBfE097C9ACaFbc95d9A5f"))
        println(sig)
    }
}