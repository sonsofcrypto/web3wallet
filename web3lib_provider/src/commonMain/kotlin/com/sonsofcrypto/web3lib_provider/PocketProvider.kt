package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_core.Network
import com.sonsofcrypto.web3lib_core.jsonPrimitive
import com.sonsofcrypto.web3lib_utils.BigInt
import com.sonsofcrypto.web3lib_provider.JsonRpcRequest.Method
import io.ktor.client.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.auth.*
import io.ktor.client.plugins.auth.providers.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.client.plugins.logging.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.utils.io.charsets.Charsets.UTF_8
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import kotlinx.serialization.InternalSerializationApi
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.*
import kotlinx.serialization.serializer
import kotlin.native.concurrent.SharedImmutable

@SharedImmutable
private val providerJson = Json {
    isLenient = true
    ignoreUnknownKeys = true
    coerceInputValues = true
    allowStructuredMapKeys = true
    useAlternativeNames = false
    prettyPrint = true
}

class PocketProvider {

    private val apiKeys: ApiKeys
    private val network: Network
    private val client: HttpClient
    private val dispatcher: CoroutineDispatcher = Dispatchers.Default
    private val nameService: NameServiceProvider?

    constructor(network: Network, apiKeys: ApiKeys = ApiKeys.default()) {
        this.apiKeys = apiKeys
        this.network = network
        this.nameService = null
        client = HttpClient() {
            Logging {
                level = LogLevel.ALL
                logger = Logger.SIMPLE
            }
            install(ContentNegotiation) {
                json(
                    providerJson,
                    ContentType.Application.Json.withCharset(UTF_8)
                )
            }
            install(Auth) {
                basic {
                    sendWithoutRequest { true }
                    credentials { BasicAuthCredentials("", apiKeys.secretKey) }
                }
            }
        }
    }

    /** Gossip */

    @Throws(Throwable::class)
    suspend fun blockNumber(): ULong = withContext(dispatcher) {
        try {
            return@withContext providerJson
                .decodeFromString<JsonRpcResponse<QuantityHexString>>(
                    perfrom(JsonRpcRequest.with(Method.BLOCK_NUMBER))
                )
                .result
                .toULongQnt()
        } catch (err: Throwable) {
            throw processJsonRpcError(err)
        }
    }

    @Throws(Throwable::class)
    suspend fun gasPrice(): BigInt = withContext(dispatcher) {
        try {
            return@withContext providerJson
                .decodeFromString<JsonRpcResponse<QuantityHexString>>(
                    perfrom(JsonRpcRequest.with(Method.GAS_PRICE))
                )
                .result
                .toBigIntQnt()
        } catch (err: Throwable) {
            throw processJsonRpcError(err)
        }
    }

//    suspend fun sendRawTransaction(): ULong = withContext(dispatcher) {
//        return@withContext perfrom<QuantityHexString>(
//            JsonRpcRequest(method = Method.BLOCK_NUMBER)
//        ).result.toULongQnt()
//    }

    /** State */

    @Throws(Throwable::class)
    suspend fun getBalance(
        address: Address,
        block: BlockTag = BlockTag.Latest
    ): ULong = withContext(dispatcher) {
        try {
            val req = JsonRpcRequest.with(
                method = Method.GET_BALANCE,
                params = listOf(address.jsonPrimitive(), block.jsonPrimitive())
            )
            return@withContext providerJson
                .decodeFromString<JsonRpcResponse<QuantityHexString>>(perfrom(req))
                .result
                .toULongQnt()
        } catch (err: Throwable) {
            throw processJsonRpcError(err)
        }
    }

    @Throws(Throwable::class)
    suspend fun getStorageAt(
        address: Address,
        position: ULong,
        block: BlockTag = BlockTag.Latest
    ): DataHexString = withContext(dispatcher) {
        try {
            val req = JsonRpcRequest.with(
                method = Method.GET_STORAGE_AT,
                params = listOf(
                    address.jsonPrimitive(),
                    QuantityHexString(position).jsonPrimitive(),
                    block.jsonPrimitive()
                )
            )
            return@withContext providerJson
                .decodeFromString<JsonRpcResponse<DataHexString>>(perfrom(req))
                .result
        } catch (err: Throwable) {
            throw processJsonRpcError(err)
        }
    }

    @Throws(Throwable::class)
    suspend fun getTransactionCount(
        address: Address,
        block: BlockTag = BlockTag.Latest
    ): ULong = withContext(dispatcher) {
        try {
            val req = JsonRpcRequest.with(
                method = Method.GET_TRANSACTION_COUNT,
                params = listOf(address.jsonPrimitive(), block.jsonPrimitive())
            )
            return@withContext providerJson
                .decodeFromString<JsonRpcResponse<QuantityHexString>>(perfrom(req))
                .result
                .toULongQnt()
        } catch (err: Throwable) {
            throw processJsonRpcError(err)
        }
    }

    @Throws(Throwable::class)
    suspend fun getCode(
        address: Address,
        block: BlockTag = BlockTag.Latest
    ): DataHexString = withContext(dispatcher) {
        try {
            val req = JsonRpcRequest.with(
                method = Method.GET_CODE,
                params = listOf(address.jsonPrimitive(), block.jsonPrimitive())
            )
            return@withContext providerJson
                .decodeFromString<JsonRpcResponse<DataHexString>>(perfrom(req))
                .result
        } catch (err: Throwable) {
            throw processJsonRpcError(err)
        }
    }

    @Throws(Throwable::class)
    suspend fun call(
        transation: TransactionRequest,
        block: BlockTag = BlockTag.Latest
    ): DataHexString = withContext(dispatcher) {
        try {
            val req = JsonRpcRequest.with(
                method = Method.CALL,
                params = listOf(transation.JsonRpc(), block.jsonPrimitive())
            )
            return@withContext providerJson
                .decodeFromString<JsonRpcResponse<DataHexString>>(perfrom(req))
                .result
        } catch (err: Throwable) {
            throw processJsonRpcError(err)
        }
    }

    @Throws(Throwable::class)
    suspend fun estimateGas(
        transation: TransactionRequest,
    ): BigInt = withContext(dispatcher) {
        try {
            val req = JsonRpcRequest.with(
                method = Method.ESTIMATE_GAS,
                params = listOf(transation.JsonRpc())
            )
            return@withContext providerJson
                .decodeFromString<JsonRpcResponse<QuantityHexString>>(perfrom(req))
                .result
                .toBigIntQnt()
        } catch (err: Throwable) {
            throw processJsonRpcError(err)
        }
    }

    /** History */
    
    @Throws(Throwable::class)
    suspend fun getBlockTransactionCount(
        block: BlockTag
    ): ULong = withContext(dispatcher) {
        try {
            val req = JsonRpcRequest.with(
                method = when(block) {
                    is BlockTag.Hash -> { Method.GET_BLOCK_TRANSACTION_COUNT_BY_HASH }
                    else -> Method.GET_BLOCK_TRANSACTION_COUNT_BY_NUMBER
                },
                params = listOf(block.jsonPrimitive())
            )
            return@withContext providerJson
                .decodeFromString<JsonRpcResponse<QuantityHexString>>(perfrom(req))
                .result
                .toULongQnt()
        } catch (err: Throwable) {
            throw processJsonRpcError(err)
        }
    }

    @Throws(Throwable::class)
    suspend fun getUncleCount(
        block: BlockTag
    ): ULong = withContext(dispatcher) {
        try {
            val req = JsonRpcRequest.with(
                method = when(block) {
                    is BlockTag.Hash -> { Method.GET_UNCLE_COUNT_BY_HASH }
                    else -> Method.GET_UNCLE_COUNT_BY_NUMBER
                },
                params = listOf(block.jsonPrimitive())
            )
            return@withContext providerJson
                .decodeFromString<JsonRpcResponse<QuantityHexString>>(perfrom(req))
                .result
                .toULongQnt()
        } catch (err: Throwable) {
            throw processJsonRpcError(err)
        }
    }

    @Throws(Throwable::class)
    suspend fun getBlock(
        block: BlockTag,
        full: Boolean = false
    ): Block = withContext(dispatcher) {
        try {
            val req = JsonRpcRequest.with(
                method = when(block) {
                    is BlockTag.Hash -> { Method.GET_BLOCK_BY_HASH }
                    else -> Method.GET_BLOCK_BY_NUMBER
                },
                params = listOf(block.jsonPrimitive(), JsonPrimitive(full))
            )
            val result = providerJson
                .decodeFromString<JsonRpcResponse<JsonObject>>(perfrom(req))
                .result
            return@withContext Block.fromHexified(result)
        } catch (err: Throwable) {
            throw processJsonRpcError(err)
        }
    }

    /** Utilities */

    @Throws(Throwable::class)
    suspend fun perfrom(req: JsonRpcRequest): String = withContext(dispatcher) {
        return@withContext client.post(url()) {
            contentType(ContentType.Application.Json)
            setBody(providerJson.encodeToString(req))
        }.bodyAsText()
    }

    private fun processJsonRpcError(error: Throwable): Throwable {
        val response = (error as? ResponseException)?.response
        val bodyText =  runBlocking { response?.bodyAsText() }
        if (bodyText == null) {
            throw error
        }
        val jsonRpcErrorResponse = decode<JsonRpcErrorResponse>(
            bodyText ?: error.message.orEmpty(),
            providerJson
        )
        throw jsonRpcErrorResponse.error ?: error
    }

    @OptIn(InternalSerializationApi::class)
    inline fun <reified T: Any>decode(string: String, json: Json): T {
        return json.decodeFromString(T::class.serializer(), string)
    }

    @Throws(Throwable::class)
    private fun url(): String = when (network.chainId) {
        60u -> "https://eth-mainnet.gateway.pokt.network/v1/lb/${apiKeys.portalId}"
        3u -> "https://eth-ropsten.gateway.pokt.network/v1/lb/${apiKeys.portalId}"
        4u -> "https://eth-rinkeby.gateway.pokt.network/v1/lb/${apiKeys.portalId}"
        5u -> "https://eth-goerli.gateway.pokt.network/v1/lb/${apiKeys.portalId}"
        else -> throw  Error.UnsupportedNetwork(network)
    }

    /** Pocket network api keys */
    data class ApiKeys(
        val portalId: String,
        val secretKey: String,
        val publicKey: String,
    ) {
        companion object {
            fun default(): ApiKeys = ApiKeys(
                portalId = "62d4f62bb37b8e0039315bfa",
                secretKey = "a3f174d6b84aca701f065f9b60366dcf",
                publicKey = "972457802d6b4b7945c9797295507884112ad1161d2797f4a4cdcd28da2b987f"
            )
        }
    }

    /** Error */
    sealed class Error(
        message: String? = null,
        cause: Throwable? = null
    ) : kotlin.Error(message, cause) {

        constructor(cause: Throwable) : this(null, cause)

        /** Initialized pocket provider with unsupported network */
        data class UnsupportedNetwork(val network: Network) :
            Error("Unsupported network $network")
    }
}

