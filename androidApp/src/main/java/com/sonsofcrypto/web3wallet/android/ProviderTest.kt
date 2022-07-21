package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_core.Network
import kotlinx.coroutines.runBlocking
import com.sonsofcrypto.web3lib_provider.*
import com.sonsofcrypto.web3lib_utils.BigInt
import com.sonsofcrypto.web3lib_utils.hexStringToByteArray
import kotlinx.serialization.json.Json
import java.lang.Exception

private val providerJson = Json {
    isLenient = true
    ignoreUnknownKeys = true
    coerceInputValues = true
    allowStructuredMapKeys = true
    useAlternativeNames = false
    prettyPrint = true
}

class ProviderTest {

    fun runAll() {
//        testBlockNumber()
//        testGasPrice()
//        testGetBalance()
//        testGetStorageAt()
//        testGetTransactionCount()
//        testGetCode()
//        testErrorHandling()
//        testCall()
//        testEstimateGas()
//        testGetBlockTransactionHashCount()
//        testGetBlockTransactionNumberCount()
//        testGetUncleCount()
        testGetBlock()
//        testQuantityHexString()

    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun testBlockNumber() = runBlocking {
        val provider = PocketProvider(Network.ethereum())
        val blockNumber = provider.blockNumber()
        println("block number $blockNumber")
    }

    fun testGasPrice() = runBlocking {
        val provider = PocketProvider(Network.ethereum())
        val gasPrice = provider.blockNumber()
        println("gas price ${gasPrice.toString()}")
    }

    fun testGetBalance() = runBlocking {
        val provider = PocketProvider(Network.ethereum())
        val balance = provider.getBalance(
            Address.HexStringAddress("0x9fFd5aEFd25E18bb8AaA171b8eC619d94AD6AAf0")
        )
        println("balance $balance")
    }

    fun testGetStorageAt() = runBlocking {
        val provider = PocketProvider(Network.ethereum())
        val storage = provider.getStorageAt(
            Address.HexStringAddress("0x295a70b2de5e3953354a6a8344e616ed314d7251"),
            0uL,
            BlockTag.Latest
        )
        println("storage $storage")
    }

    fun testGetTransactionCount() = runBlocking {
        val provider = PocketProvider(Network.ethereum())
        val storage = provider.getTransactionCount(
            Address.HexStringAddress("0x9fFd5aEFd25E18bb8AaA171b8eC619d94AD6AAf0"),
            BlockTag.Latest
        )
        println("transaction count $storage")
    }

    fun testGetCode() = runBlocking {
        val provider = PocketProvider(Network.ethereum())
        val code = provider.getCode(
            Address.HexStringAddress("0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b"),
            BlockTag.Latest
        )
        println("code $code")
    }

    fun testCall() = runBlocking {
        val expected = "0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000004000000000000000000000000d9c9cd5f6779558b6e0ed4e6acf6b1947e7fa1f300000000000000000000000078d1ad571a1a09d60d9bbf25894b44e4c8859595000000000000000000000000286834935f4a8cfb4ff4c77d5770c2775ae2b0e7000000000000000000000000b86e2b0ab5a4b1373e40c51a7c712c70ba2f9f8e"
        val data = "0x45848dfc".hexStringToByteArray()
        val provider = PocketProvider(Network.rinkeby())
        val transaction = TransactionRequest(
            to = Address.HexStringAddress("0xebe8efa441b9302a0d7eaecc277c09d20d684540"),
            data = data,
        )
        val result = provider.call(
            transaction,
            BlockTag.Latest
        )
        assertTrue(result == expected, "Unexpected data received")
    }

    fun testEstimateGas() = runBlocking {
        val data = "0x45848dfc".hexStringToByteArray()
        val provider = PocketProvider(Network.rinkeby())
        val transaction = TransactionRequest(
            to = Address.HexStringAddress("0xebe8efa441b9302a0d7eaecc277c09d20d684540"),
            data = data,
        )
        val result = provider.estimateGas(transaction)
        assertTrue(result.toString() == "34312" , "Unexpected estimateGas")
    }

    fun testGetBlockTransactionHashCount() = runBlocking {
        val provider = PocketProvider(Network.ethereum())
        val result = provider.getBlockTransactionCount(
            BlockTag.Hash("0x4848a3b125c6ae2d2bdfc1537eebe09fe115fe8feac552bbc1f2d4b8ba1d61c6")
        )
        assertTrue(result == 358uL , "Unexpected getBlockTransactionCount")
    }

    fun testGetBlockTransactionNumberCount() = runBlocking {
        val provider = PocketProvider(Network.ethereum())
        val result = provider.getBlockTransactionCount(
            BlockTag.Number(15185387)
        )
        assertTrue(result == 358uL , "Unexpected getBlockTransactionCount")
    }

    fun testGetUncleCount() = runBlocking {
        val provider = PocketProvider(Network.ethereum())
        val resultByHash = provider.getUncleCount(
            BlockTag.Hash("0x78d47648352914d688272ef743a493f1952b10b12831704764a3c6a3119371cc")
        )
        assertTrue(resultByHash == 1uL , "Unexpected getUncleCountByHash")

        val resultByNumber = provider.getUncleCount(
            BlockTag.Number(15186562)
        )
        assertTrue(resultByHash == 1uL , "Unexpected getUncleCountByNumber")
    }

    fun testGetBlock() = runBlocking {
        val provider = PocketProvider(Network.ethereum())
        val result = provider.getBlock(
            BlockTag.Hash("0x78d47648352914d688272ef743a493f1952b10b12831704764a3c6a3119371cc")
        )

        println("block $result")
    }

    fun testErrorHandling() {
        val errorString = """
            {"error":{"code":-32602,"message":"test"},"id":2101504395,"jsonrpc":"2.0"}
        """.trimIndent().replace("\n", "")
        val expected = JsonRpcErrorResponse(
            JsonRpcErrorResponse.Error(-32602, "test"),
            2101504395
        )
        val provider = PocketProvider(Network.ethereum())
        val error =provider.decode<JsonRpcErrorResponse>(errorString, providerJson)
        assertTrue(error == expected, "Unexpected error $error")
    }

    fun testQuantityHexString() {
        val str = "0xe78a3b" as QuantityHexString
        assertTrue(str.toIntQnt() == 15174203, "QuantityHexString toIntQnt")
        assertTrue(str.toUIntQnt() == 15174203u, "QuantityHexString toUIntQnt")
        assertTrue(str.toLongQnt() == 15174203L, "QuantityHexString toLongQnt")
        assertTrue(str.toULongQnt() == 15174203uL, "QuantityHexString toULongQnt")

        assertTrue(QuantityHexString(15174203) == "0xe78a3b", "QuantityHexString fromIntQnt")
        assertTrue(QuantityHexString(15174203u) == "0xe78a3b", "QuantityHexString fromUIntQnt")
        assertTrue(QuantityHexString(15174203L) == "0xe78a3b", "QuantityHexString fromLongQnt")
        assertTrue(QuantityHexString(15174203uL) == "0xe78a3b", "QuantityHexString fromULongQnt")

        assertTrue(QuantityHexString(0uL) == "0x0", "QuantityHexString ${QuantityHexString(0uL)}")
        assertTrue(QuantityHexString(1024uL) == "0x400", "QuantityHexString ${QuantityHexString(1024uL)}")
    }
}