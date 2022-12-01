package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.contract.Interface
import com.sonsofcrypto.web3lib.utils.BundledAssetProvider

class TmpTest {

    fun runAll() {
        testResource()
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun testResource() {
        val name = "contract_ierc20"
//        val name = "contract_test"
        val bytes = BundledAssetProvider().file(name, "json")
        assertTrue(bytes != null, "Failed to load contract $name")
        val string = String(bytes!!)
        val intf = Interface(string)
    }
}