package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.Network
import io.ktor.client.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.auth.*
import io.ktor.client.plugins.auth.providers.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.plugins.logging.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.utils.io.charsets.Charsets.UTF_8
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers

class ProviderPocket: ProviderJsonRpc {

    private val apiKeys: ApiKeys

    constructor(
        network: Network,
        apiKeys: ApiKeys = ApiKeys.default(),
        dispatcher: CoroutineDispatcher = Dispatchers.Default,
        nameService: NameServiceProvider? = null
    ) : super(
        network = network,
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
            install(HttpTimeout) {
                requestTimeoutMillis = 30000
                socketTimeoutMillis = 30000
            }
            install(Auth) {
                basic {
                    sendWithoutRequest { true }
                    credentials { BasicAuthCredentials("", apiKeys.secretKey) }
                }
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
        1u -> "https://eth-mainnet.gateway.pokt.network/v1/lb/${apiKeys.portalId}"
        3u -> "https://eth-ropsten.gateway.pokt.network/v1/lb/${apiKeys.portalId}"
        4u -> "https://eth-rinkeby.gateway.pokt.network/v1/lb/${apiKeys.portalId}"
        5u -> "https://eth-goerli.gateway.pokt.network/v1/lb/${apiKeys.portalId}"
        else -> throw  Provider.Error.UnsupportedNetwork(network)
    }

    /** Pocket network api keys */
    data class ApiKeys(
        val portalId: String,
        val secretKey: String,
        val publicKey: String,
    ) {
        companion object {

            /** Only used for development */
            fun default(): ApiKeys = ApiKeys(
                portalId = "62d4f62bb37b8e0039315bfa",
                secretKey = "a3f174d6b84aca701f065f9b60366dcf",
                publicKey = "972457802d6b4b7945c9797295507884112ad1161d2797f4a4cdcd28da2b987f",
            )
        }
    }
}
