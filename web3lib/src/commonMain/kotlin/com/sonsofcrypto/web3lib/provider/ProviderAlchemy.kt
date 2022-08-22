package com.sonsofcrypto.web3lib.provider

import com.sonsofcrypto.web3lib.types.Network
import io.ktor.client.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.plugins.logging.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.utils.io.charsets.*
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers

class ProviderAlchemy: ProviderJsonRpc {

    private val apiKeys: ApiKeys

    constructor(
        network: Network,
        apiKeys: ApiKeys = ApiKeys.default(),
        dispatcher: CoroutineDispatcher = Dispatchers.Default,
        nameService: NameServiceProvider? = null
    ) : super(
        network = network,
        client = HttpClient() {
            Logging { level = LogLevel.ALL; logger = Logger.SIMPLE }
            install(ContentNegotiation) {
                json(
                    providerJson,
                    ContentType.Application.Json.withCharset(Charsets.UTF_8)
                )
            }
            install(HttpTimeout) {
                requestTimeoutMillis = 30000
                socketTimeoutMillis = 30000
            }
        },
        dispatcher = dispatcher,
        nameService = nameService,
    ) {
        this.apiKeys = apiKeys
    }

    /** Utilities */

    @Throws(Throwable::class)
    override fun url(): String = when (network.chainId) {
        1u -> "https://eth-mainnet.g.alchemy.com/v2/${apiKeys.key}"
        3u -> "https://eth-ropsten.g.alchemy.com/v2/${apiKeys.key}"
        4u -> "https://eth-rinkeby.g.alchemy.com/v2/${apiKeys.key}"
        5u -> "https://eth-goerli.g.alchemy.com/v2/${apiKeys.key}"
        else -> throw  Error.UnsupportedNetwork(network)
    }

    /** Pocket network api keys */
    data class ApiKeys(
        val key: String,
    ) {
        companion object {
            /** Only used for development */
            fun default(): ApiKeys = ApiKeys("M-_He3B8ZTXiy0USdamHK_dLUopVpzii",)
        }
    }
}