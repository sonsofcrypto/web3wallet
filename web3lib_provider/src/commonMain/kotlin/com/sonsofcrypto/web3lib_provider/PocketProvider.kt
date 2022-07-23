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
        return@withContext performGetStrResult(Method.BLOCK_NUMBER).toULongQnt()
    }

    @Throws(Throwable::class)
    suspend fun gasPrice(): BigInt = withContext(dispatcher) {
        return@withContext performGetStrResult(Method.GAS_PRICE).toBigIntQnt()
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
        return@withContext performGetStrResult(
            method = Method.GET_BALANCE,
            params = listOf(address.jsonPrimitive(), block.jsonPrimitive())
        ).toULongQnt()
    }

    @Throws(Throwable::class)
    suspend fun getStorageAt(
        address: Address,
        position: ULong,
        block: BlockTag = BlockTag.Latest
    ): DataHexString = withContext(dispatcher) {
        return@withContext performGetStrResult(
            method = Method.GET_STORAGE_AT,
            params = listOf(
                address.jsonPrimitive(),
                QuantityHexString(position).jsonPrimitive(),
                block.jsonPrimitive()
            )
        )
    }

    @Throws(Throwable::class)
    suspend fun getTransactionCount(
        address: Address,
        block: BlockTag = BlockTag.Latest
    ): ULong = withContext(dispatcher) {
        return@withContext performGetStrResult(
            method = Method.GET_TRANSACTION_COUNT,
            params = listOf(address.jsonPrimitive(), block.jsonPrimitive())
        ).toULongQnt()
    }

    @Throws(Throwable::class)
    suspend fun getCode(
        address: Address,
        block: BlockTag = BlockTag.Latest
    ): DataHexString = withContext(dispatcher) {
        return@withContext performGetStrResult(
            method = Method.GET_CODE,
            params = listOf(address.jsonPrimitive(), block.jsonPrimitive())
        )
    }

    @Throws(Throwable::class)
    suspend fun call(
        transation: TransactionRequest,
        block: BlockTag = BlockTag.Latest
    ): DataHexString = withContext(dispatcher) {
        return@withContext performGetStrResult(
            method = Method.CALL,
            params = listOf(transation.JsonRpc(), block.jsonPrimitive())
        )
    }

    @Throws(Throwable::class)
    suspend fun estimateGas(
        transation: TransactionRequest,
    ): BigInt = withContext(dispatcher) {
        return@withContext performGetStrResult(
            method = Method.ESTIMATE_GAS,
            params = listOf(transation.JsonRpc())
        ).toBigIntQnt()
    }

    /** History */
    
    @Throws(Throwable::class)
    suspend fun getBlockTransactionCount(
        block: BlockTag
    ): ULong = withContext(dispatcher) {
        return@withContext performGetStrResult(
            method = when(block) {
                is BlockTag.Hash -> { Method.GET_BLOCK_TRANSACTION_COUNT_BY_HASH }
                else -> Method.GET_BLOCK_TRANSACTION_COUNT_BY_NUMBER
            },
            params = listOf(block.jsonPrimitive())
        ).toULongQnt()
    }

    @Throws(Throwable::class)
    suspend fun getUncleCount(
        block: BlockTag
    ): ULong = withContext(dispatcher) {
        return@withContext performGetStrResult(
            method = when(block) {
                is BlockTag.Hash -> { Method.GET_UNCLE_COUNT_BY_HASH }
                else -> Method.GET_UNCLE_COUNT_BY_NUMBER
            },
            params = listOf(block.jsonPrimitive())
        ).toULongQnt()
    }

    @Throws(Throwable::class)
    suspend fun getBlock(
        block: BlockTag,
        full: Boolean = false
    ): Block = withContext(dispatcher) {
        val result = performGetObjResult(
            method = when(block) {
                is BlockTag.Hash -> { Method.GET_BLOCK_BY_HASH }
                else -> Method.GET_BLOCK_BY_NUMBER
            },
            params = listOf(block.jsonPrimitive(), JsonPrimitive(full))
        )
        return@withContext Block.fromHexified(result)
    }

    suspend fun getTransaction(
        hash: DataHexString,
    ): Transaction = withContext(dispatcher) {
        val result = performGetObjResult(
            method = Method.GET_TRANSACTION_BY_HASH,
            params = listOf(JsonPrimitive(hash))
        )
        return@withContext Transaction.fromHexifiedJsonObject(result)
    }

    suspend fun getTransaction(
        block: BlockTag,
        index: BigInt
    ): Transaction = withContext(dispatcher) {
        val result = performGetObjResult(
            method = when(block) {
                is BlockTag.Hash -> { Method.GET_TRANSACTION_BY_BLOCK_HASH_AND_INDEX }
                else -> Method.GET_TRANSACTION_BY_BLOCK_NUMBER_AND_INDEX
            },
            params = listOf(
                block.jsonPrimitive(),
                JsonPrimitive(QuantityHexString(index))
            )
        )
        return@withContext Transaction.fromHexifiedJsonObject(result)
    }

    /** Utilities */

    @Throws(Throwable::class)
    suspend fun performGetStrResult(
        method: Method,
        params: List<JsonElement> = listOf()
    ): String = withContext(dispatcher) {
        return@withContext performGetStrResult(JsonRpcRequest.with(method, params))
    }

    @Throws(Throwable::class)
    suspend fun performGetObjResult(
        method: Method,
        params: List<JsonElement> = listOf()
    ): JsonObject = withContext(dispatcher) {
        return@withContext performGetObjResult(JsonRpcRequest.with(method, params))
    }

    @Throws(Throwable::class)
    suspend fun performGetStrResult(
        req: JsonRpcRequest
    ): String = withContext(dispatcher) {
        return@withContext (perform(req).result as JsonPrimitive).content
    }

    @Throws(Throwable::class)
    suspend fun performGetObjResult(
        req: JsonRpcRequest
    ): JsonObject = withContext(dispatcher) {
        return@withContext perform(req).result as JsonObject
    }

    @Throws(Throwable::class)
    suspend fun perform(
        req: JsonRpcRequest
    ): JsonRpcResponse2 = withContext(dispatcher) {
        try {
            return@withContext providerJson.decodeFromString(
                client.post(url()) {
                    contentType(ContentType.Application.Json)
                    setBody(providerJson.encodeToString(req))
                }.bodyAsText()
            )
        } catch (err: Throwable) {
            throw processJsonRpcError(err)
        }
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
