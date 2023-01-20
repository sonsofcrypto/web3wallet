package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.contract.*
import com.sonsofcrypto.web3lib.provider.model.QuantityHexString
import com.sonsofcrypto.web3lib.provider.utils.stringValue
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.BigInt.Companion.one
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
            delay(1.seconds)
            println("=== LFG")
            testAbiCoderEncoding()
            testAbiCoderDecoding()
            testAbiV2CoderEncoding()
            testAbiV2CoderDecoding()
            testContractEvents()
            testInterfaceSignatures()
            testNumberCoder()
            testFixedBytesCoder()
        }
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun assertThrows(block: ()->Unit, reason: (err: Throwable)->Unit = {}) {
        try { block(); assertTrue(false, "Expected to throw") }
        catch (err: Throwable) { reason(err) }
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
        tests?.subList(0, tests.size)?.forEachIndexed { i, t ->
            println("derives the correct signature $i - ${t.name}")
            val iface = Interface(t.abi)
            val func = iface.function("testSig")
            assertTrue(
                func.format() == t.signature,
                "\nvalue:  ${func.format()},\nexpected: ${t.signature}"
            )
            assertTrue(
                iface.sigHashString(func.format()) == t.sigHash,
                "\nvalue:  ${iface.sigHashString(func.format())},\nexpected: ${t.sigHash}"
            )
        }

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
            stringify(desc!!.args[0]) == "0x851b9167B7cbf772D38eFaf89705b35022880A07"
                .lowercase(),
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

    fun testNumberCoder() {
        val coder = AbiCoder.default()
        val wrongExpStr = "Wrong exceptions"
        println("null input failed")
        assertThrows(
            { coder.decode(paramsFromString("[bool]"), ByteArray(0)) },
            { err -> assertTrue(err is Reader.Error.OutOfBounds, wrongExpStr) }
        )

        val overflowAboveHex      = "0x10000000000000000000000000000000000000000000000000000000000000000"
        val overflowBelowHex      = "-0x10000000000000000000000000000000000000000000000000000000000000000"
        val maxHex                =  "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        val maxLessOneHex         =  "0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe"
        val maxSignedHex          =  "0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        val maxSignedLessOneHex   =  "0x7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe"
        val minSignedHex          = "-0x8000000000000000000000000000000000000000000000000000000000000000"
        val minSignedHex2s        =  "0x8000000000000000000000000000000000000000000000000000000000000000"
        val minMoreOneSignedHex   = "-0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        val minMoreOneSignedHex2s =  "0x8000000000000000000000000000000000000000000000000000000000000001"
        val zeroHex               =  "0x0000000000000000000000000000000000000000000000000000000000000000"
        val oneHex                =  "0x0000000000000000000000000000000000000000000000000000000000000001"

        fun stry(value: Any?): String = stringifyForEvent(value, false)

        println("encodes zero")
        val zeroValues: List<Pair<String, BigInt>> = listOf(
            Pair("number zero", BigInt.from(0)),
            Pair("hex zero", BigInt.from("0x0", 16)),
            Pair("hex leading even length", BigInt.from("0x0000", 16)),
            Pair("hex leading odd length", BigInt.from("0x00000", 16)),
            Pair("BigNumber", BigInt.zero),
        )
        listOf("uint8", "uint256", "int8", "int256").forEach { type ->
            zeroValues.forEach { pair ->
                val value = listOf(pair.second)
                val result = coder.encode(paramsFromString("[$type]"), value)
                assertTrue(stry(result) == zeroHex, "Error ${pair.first}")
            }
        }

        println("encodes one")
        val oneValues = listOf(
                Pair("number", BigInt.from(1)),
                Pair("hex", BigInt.from("0x1", 16)),
                Pair("hex leading even length", BigInt.from("0x0001", 16)),
                Pair("hex leading odd length", BigInt.from("0x00001", 16)),
                Pair("BigNumber", one),
        )
        listOf("uint8", "uint256", "int8", "int256").forEach { type ->
            oneValues.forEach { pair ->
                val value = listOf(pair.second)
                val result = coder.encode(paramsFromString("[$type]"), value)
                assertTrue(stry(result) == oneHex, "Error ${pair.first}")
            }
        }

        println("encodes negative one")
        val negOneValues = listOf(
            Pair("number", BigInt.from(-1)),
            Pair("hex", BigInt.from("-0x1", 16)),
            Pair("hex leading even length", BigInt.from("-0x0001", 16)),
            Pair("hex leading odd length", BigInt.from("-0x00001", 16)),
            Pair("BigNumber", BigInt.negOne),
        )
        listOf("int8", "int256").forEach { type ->
            negOneValues.forEach { pair ->
                val value = listOf(pair.second)
                val result = coder.encode(paramsFromString("[$type]"), value)
                assertTrue(stry(result) == maxHex, "Error ${pair.first}")
            }
        }

        println("encodes full uint8 range")
        for (i in 0 until 256) {
            var expected = "0x00000000000000000000000000000000000000000000000000000000000000"
            expected += BigInt.from(i).toByteArray().toHexString(false)
            val result = coder.encode(paramsFromString("[uint8]"), listOf(BigInt.from(i)))
            assertTrue(stry(result) == expected, "Failed uint8 $i")
        }

        println("encodes full int8 range")
        for (i in -128 until 128) {
            val expected = when {
                i == -128 -> "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff80"
                i < 0 -> "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff" +
                    BigInt.from(i).toTwosComplement().toHexString(false)
                else -> "0x00000000000000000000000000000000000000000000000000000000000000" +
                    BigInt.from(i).toTwosComplement().toHexString(false)
            }
            val result = coder.encode(paramsFromString("[int8]"), listOf(BigInt.from(i)))
            assertTrue(stry(result) == expected, "Failed int8 $i")
        }

        println("encodes uint256 end range")
        var value = listOf(BigInt.from(maxHex, 16))
        var res = coder.encode(paramsFromString("[uint256]"), value)
        assertTrue(stry(res) == maxHex, "uint256 max")

        println("encodes uint256 end range")
        value = listOf(BigInt.from(maxLessOneHex, 16))
        res = coder.encode(paramsFromString("[uint256]"), value)
        assertTrue(stry(res) == maxLessOneHex, "uint256 maxLessOneHex")

        println("encodes int256 end ranges")
        value = listOf(BigInt.from(maxSignedHex, 16))
        res = coder.encode(paramsFromString("[int256]"), value)
        assertTrue(stry(res) == maxSignedHex, "int256 maxSignedHex")

        value = listOf(BigInt.from(maxSignedLessOneHex, 16))
        res = coder.encode(paramsFromString("[int256]"), value)
        assertTrue(stry(res) == maxSignedLessOneHex, "int256 maxSignedLessOneHex")

        value = listOf(BigInt.from(minSignedHex, 16))
        res = coder.encode(paramsFromString("[int256]"), value)
        assertTrue(stry(res) == minSignedHex2s, "int256 minSignedHex")

        value = listOf(BigInt.from(minMoreOneSignedHex, 16))
        res = coder.encode(paramsFromString("[int256]"), value)
        assertTrue(stry(res) == minMoreOneSignedHex2s, "int256 minMoreOneSignedHex")

        println("fails to encode out-of-range uint8")
        listOf(
            BigInt.from(-128), BigInt.from(-127), BigInt.from(-2),
            BigInt.from(-1), BigInt.from(256), BigInt.from(1000),
            BigInt.from(maxHex, 16), BigInt.from(maxSignedHex, 16).add(one),
            BigInt.from(minSignedHex, 16), BigInt.from(overflowAboveHex, 16),
            BigInt.from(overflowBelowHex, 16)
        ).forEach {
            assertThrows(
                { coder.encode(paramsFromString("[uint8]"), listOf(it)) },
                { err -> assertTrue(err is Coder.Error.OutOfBounds, "uint8 $err") }
            )
        }

        println("fails to encode out-of-range int8")
        listOf(
            BigInt.from(-129), BigInt.from(-130), BigInt.from(-1000),
            BigInt.from(128), BigInt.from(129), BigInt.from(1000),
            BigInt.from(maxHex, 16), BigInt.from(maxSignedHex, 16).add(one),
            BigInt.from(minSignedHex, 16).sub(one),
            BigInt.from(overflowAboveHex, 16), BigInt.from(overflowBelowHex, 16)
        ).forEach {
            assertThrows(
                { coder.encode(paramsFromString("[int8]"), listOf(it)) },
                { err -> assertTrue(err is Coder.Error.OutOfBounds, "int8 $err") }
            )
        }

        println("fails to encode out-of-range uint256")
        listOf(
            BigInt.from(-128), BigInt.from(-127), BigInt.from(-2),
            BigInt.from(-1), BigInt.from(maxHex, 16).add(one),
            BigInt.from('-' + maxHex, 16), BigInt.from(overflowAboveHex, 16),
            BigInt.from(overflowBelowHex, 16)
        ).forEach {
            assertThrows(
                { coder.encode(paramsFromString("[uint256]"), listOf(it)) },
                { err -> assertTrue(err is Coder.Error.OutOfBounds, "uint256 $err") }
            )
        }

        println("fails to encode out-of-range int256")
        listOf(
            BigInt.from(maxHex, 16),
            BigInt.from(maxSignedHex, 16).add(one),
            BigInt.from(minSignedHex, 16).sub(one),
            BigInt.from(overflowAboveHex, 16), BigInt.from(overflowBelowHex, 16)
        ).forEach {
            assertThrows(
                { coder.encode(paramsFromString("[int256]"), listOf(it)) },
                { err -> assertTrue(err is Coder.Error.OutOfBounds, "int256 $err") }
            )
        }
    }

    fun testFixedBytesCoder() {
        val coder = AbiCoder.default()
        val zeroHexStr = "0x0000000000000000000000000000000000000000000000000000000000000000"

        println("fails to encode out-of-range bytes4")
        listOf(
            "0x", "0x00000", "0x000", zeroHexStr, "0x12345", "0x123456",
            "0x123", "0x12",
        ).forEach { testVal ->
            assertThrows(
                {
                    val data =  testVal.hexStringToByteArray()
                    coder.encode(paramsFromString("[bytes4]"), listOf(data))
                },
                { err ->
                    if (testVal.length % 2 != 0)
                        assertTrue(err is IllegalStateException, "Wrong error")
                    else
                        assertTrue(err is Coder.Error.SizeMismatch, "Wrong error")
                }
            )
        }

        println("fails to encode out-of-range bytes32")
        listOf(
            "0x",
            "0x00000",
            "0x000",
            "0x12345",
            "0x123456",
            zeroHexStr + "0",
            zeroHexStr + "00",
        ).forEach { testVal ->
            assertThrows(
                {
                    val data =  testVal.hexStringToByteArray()
                    coder.encode(paramsFromString("[bytes4]"), listOf(data))
                },
                { err ->
                    if (testVal.length % 2 != 0)
                        assertTrue(err is IllegalStateException, "Wrong error")
                    else
                        assertTrue(err is Coder.Error.SizeMismatch, "Wrong error")
                }
            )
        }
    }

    private fun paramsFromString(string: String): List<Param> =
        Param.fromStringParams(string).mapNotNull { it }
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
