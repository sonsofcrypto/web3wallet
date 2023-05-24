package com.sonsofcrypto.web3walletcore

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.keyStore.DefaultKeyStoreService
import com.sonsofcrypto.web3lib.services.keyStore.KeyChainService
import com.sonsofcrypto.web3lib.services.keyStore.KeyChainServiceErr
import com.sonsofcrypto.web3lib.services.keyStore.ServiceType
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3walletcore.modules.root.DefaultRootPresenter
import com.sonsofcrypto.web3walletcore.modules.root.RootView
import com.sonsofcrypto.web3walletcore.modules.root.RootWireframe
import com.sonsofcrypto.web3walletcore.modules.root.RootWireframeDestination
import com.sonsofcrypto.web3walletcore.services.improvementProposals.DefaultImprovementProposalsService
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.datetime.Clock
import kotlin.test.Test

class WalletCoreTests {

    @Test
    fun testBuild() {
        val keyStoreService = DefaultKeyStoreService(
            KeyValueStore("WalletServiceTest.keyStore"),
            MockKeyChainService()
        )

        val presenter = DefaultRootPresenter(
            WeakRef(MockRootView()),
            MockRootWireframe(),
            keyStoreService
        )
        println("=== IT LIVES $presenter")
        val debug = "" // System.getProperty("java.library.path")
        println("=== debug $debug")
        val bip39 = Bip39.from(Bip39.EntropySize.ES128)
        println(bip39.mnemonic)
    }

    @Test
    fun testProposalsService() {
        val service = DefaultImprovementProposalsService(KeyValueStore("mock"))
        GlobalScope.launch {
            val proposals = service.fetch()
            println("=== proposals ${proposals.count()}")
            println("=== cached ${proposals.count()}")
        }
    }
}

class MockKeyChainService: KeyChainService {

    val store = mutableMapOf<String, ByteArray>()

    @Throws(KeyChainServiceErr::class)
    override fun get(id: String, type: ServiceType): ByteArray {
        return store[id]!!
    }

    @Throws(KeyChainServiceErr::class)
    override fun set(id: String, data: ByteArray, type: ServiceType, icloud: Boolean) {
        store[id] = data
    }

    override fun remove(id: String, type: ServiceType) {
        store.remove(id)
    }

    override fun biometricsSupported(): Boolean {
        return true
    }

    override fun biometricsAuthenticate(title: String, handler: (Boolean, Error?) -> Unit) {
        TODO("Not yet implemented")
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

class MockRootView: RootView {

}