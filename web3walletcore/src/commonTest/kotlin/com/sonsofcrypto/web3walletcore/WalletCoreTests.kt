package com.sonsofcrypto.web3walletcore

import com.sonsofcrypto.web3lib.BuildKonfig
import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.coinGecko.DefaultCoinGeckoService
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.currencyStore.DefaultCurrencyStoreService
import com.sonsofcrypto.web3lib.services.currencyStore.defaultCurrencies
import com.sonsofcrypto.web3lib.services.keyStore.DefaultKeyStoreService
import com.sonsofcrypto.web3lib.services.keyStore.KeyChainService
import com.sonsofcrypto.web3lib.services.keyStore.KeyChainServiceErr
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.services.keyStore.ServiceType
import com.sonsofcrypto.web3lib.services.networks.DefaultNetworksService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.node.DefaultNodeService
import com.sonsofcrypto.web3lib.services.poll.DefaultPollService
import com.sonsofcrypto.web3lib.services.wallet.DefaultWalletService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3walletcore.modules.root.DefaultRootPresenter
import com.sonsofcrypto.web3walletcore.modules.root.RootView
import com.sonsofcrypto.web3walletcore.modules.root.RootWireframe
import com.sonsofcrypto.web3walletcore.modules.root.RootWireframeDestination
import com.sonsofcrypto.web3walletcore.services.improvementProposals.DefaultImprovementProposalsService
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlin.test.Test

class WalletCoreTests {

    @Test
    fun testBuild() {
        println("Hello Test World")
    }
}

val testMnemonic = BuildKonfig.testMnemonic

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