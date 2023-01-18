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
//            testContractEvents()
            testInterfaceSignatures()
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
    }.replace("0x-", "-0x")

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
                    val strigified = stringifyForEvent(decoded, i != 4)
                    assertTrue(
                         strigified == expected.toString(),
                        "\ndecoded:  $strigified,\nexpected: $expected"
                    )
                }
            }
        }

        tests?.subList(0, tests.size)?.forEachIndexed { i, t ->
            println("Decode event data $i - ${t.name} - ${t.types}")
            val iface = Interface(t.iface)
            val parsed = iface.decodeEventLog(
                iface.event("testEvent"),
                t.data.hexStringToByteArray(),
            )
            val values = getValues(t.normalizedValues!!)
            (values as? List<Any>)?.forEachIndexed {idx, expected ->
                val decoded = parsed.getOrNull(idx)
                val indexed = decoded as? Interface.Indexed
                if (t.indexed[idx] == true) {
                    assertTrue(
                        indexed?.isIndex == true && indexed?.hash == null,
                        "\ndecoded: ${indexed},\nexpected: $expected"
                    )
                } else {
                    val strigified = stringifyForEvent(decoded, i != 4)
                    assertTrue(
                         strigified == expected.toString(),
                        "\ndecoded:  $strigified,\nexpected: $expected"
                    )
                }
            }
        }
    }

    @Serializable
    data class TestCaseSig(
        val name: String,
        val abi: String,
        val sigHash: String,
        val signature: String,
    )

    fun testInterfaceSignatures() {
        val bytes = loadTestCases("contract_signatures")
        val tests = jsonDecode<List<TestCaseSig>>(String(bytes!!))
//        tests?.subList(0, tests.size)?.forEachIndexed { i, t ->
//            println("derives the correct signature $i - ${t.name}")
//            val iface = Interface(t.abi)
//            val func = iface.function("testSig")
//            assertTrue(
//                func.format() == t.signature,
//                "\nvalue:  ${func.format()},\nexpected: ${t.signature}"
//            )
//            assertTrue(
//                iface.sigHashString(func.format()) == t.sigHash,
//                "\nvalue:  ${iface.sigHashString(func.format())},\nexpected: ${t.sigHash}"
//            )
//        }

        println("derives correct description for human-readable ABI")
        val iface = Interface(transferJson)
        listOf("transfer", "transfer(address,uint256)").forEach {
            val desc = iface.function(it)
            assertTrue(desc.name == "transfer", "incorrect name key - $it")
            assertTrue(
                desc.format() == "transfer(address,uint256)",
                "incorrect signature key - $it"
            )
            assertTrue(
                iface.sigHashString(desc.format()) == "0xa9059cbb",
                "incorrect sighash key - $it"
            )
        }

        // See: https://github.com/ethers-io/ethers.js/issues/370
        println("parses transaction function")
        val desc = iface.parseTx(txData, BigInt.zero)
        assertTrue(
            stringify(desc!!.args[0]) == "0x851b9167B7cbf772D38eFaf89705b35022880A07",
            "tx - args[0]"
        )
        assertTrue(
            stringify(desc!!.args[1]) == "1000000000000000000",
            "tx - args[1]"
        )
        assertTrue(desc.name == "transfer", "tx - name")
        assertTrue(desc.signatre == "transfer(address,uint256)", "tx - sig")
        assertTrue(desc.sigHash.toHexString(true) == "0xa9059cbb", "tx - sighash")
        assertTrue(desc.value.toString() == "0", "tx - value")
    }
}

val transferJson = """
 [
    {
        "inputs": [
            { "internalType": "address","name": "to", "type": "address" },
            { "internalType": "uint256", "name": "amount", "type": "uint256" }
        ],
        "name": "transfer",
        "outputs": [ { "internalType": "bool", "name": "", "type": "bool" } ],
        "stateMutability": "nonpayable",
        "type": "function"
    }
] 
"""

val txData = "0xa9059cbb000000000000000000000000851b9167b7cbf772d38efaf89705b35022880a070000000000000000000000000000000000000000000000000de0b6b3a7640000".hexStringToByteArray()
