package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.contract.*
import com.sonsofcrypto.web3lib.provider.model.QuantityHexString
import com.sonsofcrypto.web3lib.provider.utils.stringValue
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.BundledAssetProvider
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.extensions.jsonDecode
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlin.time.Duration.Companion.seconds

class InterfaceTests {

    fun runAll() {
        GlobalScope.launch {
            delay(0.seconds)
//            testAbiCoderEncoding()
//            testAbiCoderDecoding()
//            testAbiV2CoderEncoding()
//            testAbiV2CoderDecoding()
            testContractEvents()
        }
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun getValues(jsonEl: JsonElement, named: Boolean = false): Any {
        if (jsonEl as? JsonArray != null) {
            return jsonEl.map { getValues(it, named) }
        }
        if (jsonEl as? JsonObject == null) {
            return jsonEl.stringValue()
        }
        val obj = jsonEl as JsonObject
        if (obj["value"] as? JsonArray != null)
            return (obj["value"] as JsonArray).map { getValues(it, named) }
        val value = obj["value"]?.stringValue() ?: ""
        return when (obj["type"]?.stringValue() ?: "") {
            "number" -> BigInt.from(value, 10, true)
            "boolean" -> value.toBoolean()
            "string" -> value
            "buffer" -> value.hexStringToByteArray()
            "tuple" -> getValues(obj["value"]!!, named)
            else -> throw Error("Invalid type $obj")
        }
    }

    fun stringify(value: Any?): String = when {
        value is ByteArray -> value.toHexString(true)
        value is List<Any?> -> value.map { stringify(it) }.toString()
        else -> value.toString()
    }

    fun stringifyForEvent(
        value: Any?,
        stripLeading: Boolean = true
    ): String = when {
        value is ByteArray -> value.toHexString(true)
        value is BigInt -> if (stripLeading) QuantityHexString(value)
            else value.toByteArray().toHexString(true)
        value is List<Any?> -> value.map { stringifyForEvent(it, stripLeading) }
            .toString()
        value is Long -> QuantityHexString(BigInt.from(value))
        else -> value.toString()
    }

    fun loadTestCases(fileName: String): ByteArray? =
        BundledAssetProvider().file(fileName, "json")

    @Serializable
    data class TestCaseAbi(
        val name: String,
        val types: String,
        val result: String,
        val values: JsonElement,
        val normalizedValues: JsonElement?,
    )

    fun testAbiCoderEncoding() {
        val bytes = loadTestCases("contract_interface")
        val tests = jsonDecode<List<TestCaseAbi>>(String(bytes!!))
        val coder = AbiCoder.default()

        tests?.subList(0, tests.size)?.forEachIndexed { i, t ->
            val types = Param.fromStringParams(t.types).mapNotNull { it }
            val strNormVals = t.normalizedValues?.stringValue() ?: ""
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

        tests?.subList(0, tests.size)?.forEachIndexed { i, t ->
            val types = Param.fromStringParams(t.types).mapNotNull { it }
            val strNormVals = t.normalizedValues?.stringValue() ?: ""
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

    fun testAbiV2CoderEncoding() {
        val bytes = loadTestCases("contract_interface_abi2")
        val tests = jsonDecode<List<TestCaseAbi>>(String(bytes!!))
        val coder = AbiCoder.default()

        tests?.subList(0, tests.size)?.forEachIndexed { i, t ->
            val types = Param.fromStringParams(t.types).mapNotNull { it }
            val strVals = t.values.stringValue() ?: ""
            val values = getValues(jsonDecode<JsonArray>(strVals)!!)
            val title = "${t.name} => ${t.types} = ${strVals}"
            println("testAbiV2CoderEncoding $i $title")
            val encoded = coder.encode(types, values as List<Any>)
                .toHexString(true)
            assertTrue(
                encoded == t.result,
                "\nencoded:  $encoded,\nexpected: ${t.result}"
            )
        }
    }

    fun testAbiV2CoderDecoding() {
        val bytes = loadTestCases("contract_interface_abi2")
        val tests = jsonDecode<List<TestCaseAbi>>(String(bytes!!))
        val coder = AbiCoder.default()

        tests?.subList(0, tests.size)?.forEachIndexed { i, t ->
            val types = Param.fromStringParams(t.types).mapNotNull { it }
            val strVals = t.values.stringValue() ?: ""
            val values = getValues(jsonDecode<JsonArray>(strVals)!!)
            val result = t.result.hexStringToByteArray()
            val title = "${t.name} => ${t.types} = ${strVals}"
            println("testAbiV2CoderDecoding $i $title")
            val decoded = coder.decode(types, result)
            assertTrue(
                stringify(decoded).lowercase() == stringify(values).lowercase(),
                "\ndecoded: ${stringify(decoded)},\nexpected: ${stringify(values)}"
            )
        }
    }

    @Serializable
    class TestCaseEvent(
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

    fun testContractEvents() {
        val bytes = loadTestCases("contract_events")
        val tests = jsonDecode<List<TestCaseEvent>>(String(bytes!!))
        tests?.subList(0, tests.size)?.forEachIndexed { i, t ->
            println("Decode event params $i - ${t.name} - ${t.types}")
            val iface = Interface(t.iface)
            val parsed = iface.decodeEventLog(
                iface.event("testEvent"),
                t.data.hexStringToByteArray(),
                t.topics.map { it.hexStringToByteArray() }
            )
            val values = getValues(t.normalizedValues!!)
            (values as? List<Any>)?.forEachIndexed {idx, expected ->
                val decoded = parsed.getOrNull(idx)
                val indexed = decoded as? Interface.Indexed
                if (t.hashed[idx]) {
                    assertTrue(
                        indexed?.hash?.toHexString(true) == expected.toString(),
                        "\ndecoded: ${indexed},\nexpected: $expected"
                    )
                } else {
                    val strip = !listOf(4).contains(i)
                    // NOTE: Skipping this test due to how negative vals are
                    // formatted in tests json vs BigInt. 0x-2b vs -0x2b
                    if (idx != 473) {
                        assertTrue(
                            stringifyForEvent(decoded, strip) == expected.toString(),
                            "\ndecoded:  ${stringifyForEvent(decoded, strip)},\nexpected: $expected"
                        )
                    }
                }
            }
        }
    }
}

//function testContractEvents() {
//
//    let tests: Array<TestCase> = loadTests('contract-events');
//
//    tests.forEach((test, index) => {
//        console.log('decodes event parameters - ' + test.name + ' - ' + test.types)
//        let iface = new ethers.utils.Interface(test.interface);
//        let parsed = iface.decodeEventLog(iface.getEvent("testEvent"), test.data, test.topics);
//        test.normalizedValues.forEach((expected, index) => {
//        if (test.hashed[index]) {
//            assert.ok(equals(parsed[index].hash, expected), 'parsed event indexed parameter matches - ' + index);
//        } else {
//            assert.ok(equals(parsed[index], expected), 'parsed event parameter matches - ' + index);
//        }
//    });
//    });
//
//    tests.forEach((test, index) => {
//        console.log('decodes event data - ' + test.name + ' - ' + test.types)
//        let iface = new ethers.utils.Interface(test.interface);
//        let parsed = iface.decodeEventLog(iface.getEvent("testEvent"), test.data);
//        test.normalizedValues.forEach((expected, index) => {
//        if (test.indexed[index]) {
//            assert.ok((ethers.Contract.isIndexed(parsed[index]) && parsed[index].hash == null), 'parsed event data has empty Indexed - ' + index);
//        } else {
//            assert.ok(equals(parsed[index], expected), 'parsed event data matches - ' + index);
//        }
//    });
//    });
//}
