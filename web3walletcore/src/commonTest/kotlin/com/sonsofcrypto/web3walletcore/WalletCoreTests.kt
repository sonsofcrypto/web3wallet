package com.sonsofcrypto.web3walletcore

import com.sonsofcrypto.web3lib.BuildKonfig
import com.sonsofcrypto.web3walletcore.modules.root.RootView
import com.sonsofcrypto.web3walletcore.modules.root.RootWireframe
import com.sonsofcrypto.web3walletcore.modules.root.RootWireframeDestination
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