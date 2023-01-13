package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.contract.*
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.BundledAssetProvider
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.extensions.jsonDecode
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import kotlinx.serialization.Serializable

class InterfaceTests {

    fun runAll() {
        testAbiCoderEncoding()
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun getValues(jsonString: String, named: Boolean = false): List<Any> {
        @Serializable
        data class NormalizedValueJson(
            val type: String,
            val value: String,
        )
        val values = jsonDecode<List<NormalizedValueJson>>(jsonString) ?: emptyList()
        return values.map {
            when (it.type) {
                "number" -> BigInt.from(it.value)
                "boolean", "string" -> it.value
                "buffer" -> it.value.hexStringToByteArray()
                "tuple" -> getValues(it.value, named)
                else -> throw Error("Invalid type $it")
            }
        }
    }

    fun loadTestCases(fileName: String): ByteArray? =
        BundledAssetProvider().file(fileName, "json")

    fun testAbiCoderEncoding() {
        @Serializable
        data class TestCaseAbi(
            val name: String,
            val types: String,
            val result: String,
            val values: String,
            val normalizedValues: String,
        )

        val bytes = loadTestCases("contract_interface")
        val tests = jsonDecode<List<TestCaseAbi>>(String(bytes!!))
        val coder = AbiCoder.default()

        tests?.forEach {
            val types = Param.fromStringParams(it.types).mapNotNull { it }
            val values = getValues(it.normalizedValues)
            val result = it.result
            val title = "${it.name} => ${it.types} = ${it.normalizedValues}"
            println("testAbiCoderEncoding $title")
            val encoded = coder.encode(types, values).toHexString(true)
            assertTrue(
                encoded == result,
                "encoded: $encoded, expected: $result"
            )
        }
    }
}