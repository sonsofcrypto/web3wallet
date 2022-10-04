package com.sonsofcrypto.web3walletcore.services.ImprovmentProposals

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.utils.extensions.jsonDecode
import com.sonsofcrypto.web3lib.utils.extensions.jsonEncode
import com.sonsofcrypto.web3lib.utils.extensions.stdJson
import com.sonsofcrypto.web3walletcore.modules.improvementProposals.ImprovementProposalsWireframeDestination
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.plugins.logging.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.utils.io.charsets.*
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlin.native.concurrent.SharedImmutable

interface ImprovementProposalsService {
    /** Fetched proposals for github */
    @Throws(Throwable::class)
    suspend fun fetch(): List<ImprovementProposal>
}

class DefaultImprovementProposalsService(
    val store: KeyValueStore
): ImprovementProposalsService {

    private val client: HttpClient by lazy {
        HttpClient() {
            Logging { level = LogLevel.ALL; logger = Logger.SIMPLE }
            install(ContentNegotiation) { json(stdJson, contentType()) }
        }
    }

    @Throws(Throwable::class)
    override suspend fun fetch(): List<ImprovementProposal> {
        try {
            val body = client.get(url()).bodyAsText()
            val proposals = jsonDecode<List<ImprovementProposal>>(body) ?: emptyList()
            store(proposals)
            return proposals
        } catch (err: Throwable) {
            println("Error")
            return cached().ifEmpty { throw err }
        }
    }

    private fun store(proposals: List<ImprovementProposal>) {
        store.set(cacheKey, jsonEncode(proposals))
    }

    private fun cached(): List<ImprovementProposal> {
        return jsonDecode(store.get<String>(cacheKey) ?: "[]") ?: emptyList()
    }

    private fun url(): String {
        return "https://raw.githubusercontent.com/sonsofcrypto/" +
                "web3wallet-improvement-proposals/master/proposals-list.json"
    }

    private fun contentType(): ContentType {
        return ContentType.Application.Json.withCharset(Charsets.UTF_8)
    }

    private val cacheKey = "w3w-improvement-proposals-list"
}
