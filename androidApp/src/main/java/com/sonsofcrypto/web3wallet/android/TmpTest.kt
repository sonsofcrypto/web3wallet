package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.contract.Interface
import com.sonsofcrypto.web3lib.utils.BundledAssetProvider
import com.sonsofcrypto.web3lib.utils.extensions.jsonDecode
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonArray

class TmpTest {

    fun runAll() {
//        testResource()
        testEvents()
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


    @Serializable
    class TestData(
        val name: String,
        val types: String,
        val result: String,
        val values: String,
        val normalizedValues: String
    )

    fun testInterfaceDecode() {
        val name = "contract_interface"
        val bytes = BundledAssetProvider().file(name, "json")
        val tests = jsonDecode<List<TestData>>(String(bytes!!))
        tests?.forEachIndexed { idx, test ->
            println("$idx, ${test.name}")
        }
    }

    fun testEvents() {

        @Serializable
        class TestCase(
            val name: String,
            @SerialName("interface")
            val iface: String,
            val types: List<String>,
            val indexed: List<Boolean?>,
            val data: String,
            val topics: List<String>,
            val hashed: List<Boolean>,
            val normalizedValues: JsonArray,
        )

        val name = "contract_events"
        val bytes = BundledAssetProvider().file(name, "json")
        val tests = jsonDecode<List<TestCase>>(String(bytes!!))
        tests?.forEachIndexed { idx, test ->
            println("$idx, ${test.name}")
            val iface = Interface(test.iface)
            // let parsed = iface.decodeEventLog(iface.getEvent("testEvent"), test.data, test.topics);


        }
    }
}