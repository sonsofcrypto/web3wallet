package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.contract.*
import com.sonsofcrypto.web3lib.provider.utils.stringValue
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.BundledAssetProvider
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.extensions.jsonDecode
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.timerFlow
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlin.time.Duration.Companion.seconds

class InterfaceTests {

    fun runAll() {
        GlobalScope.launch {
            delay(0.seconds)
            // testAbiCoderEncoding()
            testAbiCoderDecoding()
        }
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun getValues(jsonEl: JsonElement, named: Boolean = false): Any {
        if (jsonEl as? JsonArray != null) {
            return jsonEl.map { getValues(it, named) }
        }
        val obj = jsonEl as JsonObject
        val value = obj["value"]?.stringValue() ?: ""
        return when (obj["type"]?.stringValue() ?: "") {
            "number" -> BigInt.from(value, 10, true)
            "boolean" -> value.toBoolean()
            "string" -> value
            "buffer" -> value.hexStringToByteArray()
            "tuple" -> getValues(obj, named)
            else -> throw Error("Invalid type $obj")
        }
    }

    @Serializable
    data class TestCaseAbi(
        val name: String,
        val types: String,
        val result: String,
        val values: String,
        val normalizedValues: JsonElement,
    )

    fun loadTestCases(fileName: String): ByteArray? =
        BundledAssetProvider().file(fileName, "json")

    fun testAbiCoderEncoding() {
        val bytes = loadTestCases("contract_interface")
        val tests = jsonDecode<List<TestCaseAbi>>(String(bytes!!))
        val coder = AbiCoder.default()

        tests?.subList(0, tests.size)?.forEachIndexed { i, t ->
            val types = Param.fromStringParams(t.types).mapNotNull { it }
            val strNormVals = t.normalizedValues.stringValue()
            val values = getValues(jsonDecode<JsonArray>(strNormVals)!!)
            val title = "${t.name} => ${t.types} = ${strNormVals}"
            println("testAbiCoderEncoding $i $title")
            val encoded = coder.encode(types, values as List<Any>)
                .toHexString(true)
            assertTrue(
                encoded == t.result,
                "\nencoded:  $encoded,\nexpected: ${t.result}"
            )
        }
    }

    fun testAbiCoderDecoding() {
        val bytes = loadTestCases("contract_interface")
        val tests = jsonDecode<List<TestCaseAbi>>(String(bytes!!))
        val coder = AbiCoder.default()

        fun stringify(value: Any?): String = when {
            value is ByteArray -> value.toHexString(true)
            value is List<Any?> -> value.map { stringify(it) }.toString()
            else -> value.toString()
        }

        tests?.subList(0, tests.size)?.forEachIndexed { i, t ->
            val types = Param.fromStringParams(t.types).mapNotNull { it }
            val strNormVals = t.normalizedValues.stringValue()
            val values = getValues(jsonDecode<JsonArray>(strNormVals)!!)
            val result = t.result.hexStringToByteArray()
            val title = "${t.name} => ${t.types} = ${strNormVals}"
            println("testAbiCoderDecoding $i $title")
            val decoded = coder.decode(types, result)
            assertTrue(
                stringify(decoded).lowercase() == stringify(values).lowercase(),
                "\ndencoded: ${stringify(decoded)},\nexpected: ${stringify(values)}"
            )
        }
    }
}