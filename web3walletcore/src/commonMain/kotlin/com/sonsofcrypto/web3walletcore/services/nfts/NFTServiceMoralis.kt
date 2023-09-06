package com.sonsofcrypto.web3walletcore.services.nfts

import com.sonsofcrypto.web3lib.BuildKonfig
import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.types.AddressHexString
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.types.toHexStringAddress
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.extensions.jsonDecode
import com.sonsofcrypto.web3lib.utils.extensions.jsonEncode
import com.sonsofcrypto.web3lib.utils.extensions.stdJson
import com.sonsofcrypto.web3lib.utils.withBgCxt
import com.sonsofcrypto.web3lib.utils.withUICxt
import io.ktor.client.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.plugins.logging.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.utils.io.charsets.*
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

class NFTServiceMoralis(
    private val networksService: NetworksService,
    private val store: KeyValueStore,
): NFTsService {
    private var listeners: MutableList<NFTsServiceListener> = mutableListOf()
    private val client: HttpClient by lazy {
        HttpClient {
            Logging { level = LogLevel.NONE; logger = Logger.SIMPLE }
            install(ContentNegotiation) { json(
                stdJson, ContentType.Application.Json.withCharset(
                    Charsets.UTF_8)) }
        }
    }

    /** Fetch NFTs for the selected wallet & network and cache them in memory */
    @Throws(Throwable::class)
    override suspend fun fetchNFTs(): List<NFTItem> {
        val walletAddress =  networksService.wallet()?.address()
        val network = networksService.network ?: return emptyList()
        val address = walletAddress?.toHexStringAddress()?.hexString
            ?: return emptyList()
        val allResps = mutableListOf<Response?>()
        try {
            var resp = fetch(address, network, null)
            var cursor: String? = resp?.cursor
            allResps.add(resp)
            while (cursor != null) {
                resp = fetch(address, network, cursor)
                cursor = resp?.cursor
                allResps.add(resp)
            }
        } catch (err: Throwable) {
            println("[NFTServiceMoralis] error: $err")
        }
        return withBgCxt {
            val results = allResps
                .filterNotNull()
                .map { it.result }
                .filterNotNull()
                .flatten()
            val normalized = transformToStantardNFTs(results)
            return@withBgCxt withUICxt {
                storeNFTs(updateMemPoolStatus(normalized.second))
                storeCollections(normalized.first)
                broadcastNFTsChanged()
                return@withUICxt nfts()
            }
        }
    }

    /** Find a collection that matches the given identifier (from memory).
     *  We use the data fetched by the latest request to fetchNFTs. */
    override fun collection(identifier: String): NFTCollection {
        return collections().first { it.identifier == identifier }
    }
    /** Find a nft that matches the given identifier (from memory).
     *  We use the data fetched by the latest request to fetchNFTs. */
    override fun nft(identifier: String): NFTItem {
        return nfts().first { it.identifier == identifier }
    }
    /** List of unique collections for your nfts. */
    override fun collections(): List<NFTCollection> {
        return jsonDecode(store[collectionsKey] ?: "[]") ?: emptyList()
    }
    /** List of nfts. */
    override fun nfts(): List<NFTItem> {
        return jsonDecode(store[nftsKey] ?: "[]") ?: emptyList()
    }
    /** List of nfts for a given collection id. */
    override fun nfts(collectionId: String): List<NFTItem> {
        return nfts().filter { it.collectionIdentifier == collectionId }
    }
    /** To be called when a transaction for sending an nft is successful. This is so we can flag
     * that NFT as pending confirmation so we hide it or flag it in your NFTs list */
    override fun nftSent(identifier: String) {
        val mempoolNfts = nftIdsInMemPool().toMutableList()
        mempoolNfts.add(identifier)
        storeNftIdsInMemPool(mempoolNfts)
        broadcastNFTsChanged()
    }
    /** Add a listener to the service */
    override fun addListener(listener: NFTsServiceListener) {
        listeners.add(listener)
    }
    /** Removes a listener to the service */
    override fun removeListener(listener: NFTsServiceListener) {
        listeners.remove(listener)
    }

    @Throws(Throwable::class)
    private suspend fun fetch(
        address: AddressHexString,
        network: Network,
        cursor: String?
    ): Response? {
        if (network != Network.ethereum())
            return null // NOTE: Only support ETH at the moment
        val chain: String = "eth"
        val body = client.get {
            headers {
                append(HttpHeaders.Accept, "application/json")
                append("X-API-KEY", BuildKonfig.moralisKey)
            }
            url {
                protocol = URLProtocol.HTTPS
                host = "deep-index.moralis.io"
                path("api/v2.2/$address/nft")
                parameters.append("chain", chain)
                parameters.append("format", "decimal")
                parameters.append("exclude_spam", "true")
                parameters.append("normalizeMetadata", "true")
                parameters.append("media_items", "true")
                if (cursor != null)
                    parameters.append("cursor", cursor)
                else Unit
            }
        }.bodyAsText()
        return jsonDecode<Response>(body)
    }

    private fun transformToStantardNFTs(
        results: List<Response.Nft>
    ): Pair<List<NFTCollection>, List<NFTItem>> {
        val nfts: List<NFTItem?> = results.map {
            val tokenId = it.tokenId
            val tokenAddress = it.tokenAddress
            val image = it.normalized?.image
            if (tokenId == null || tokenAddress == null || image == null)
                null
            else
                NFTItem(
                    identifier = "$tokenAddress/$tokenId",
                    collectionIdentifier = tokenAddress,
                    name = it.normalized?.name ?: it.name ?: it.tokenId,
                    properties = it.normalized?.attributes?.map { attr ->
                        NFTItem.Property(
                            name = attr?.traitType ?: "",
                            value = attr?.value ?: "",
                            info = "",
                        )
                    } ?: emptyList(),
                    image = image,
                    address = tokenAddress,
                    schemaName = it.contractType ?: "",
                    tokenId = BigInt.from(tokenId, 10),
                    inMemPool = false,
                )
        }
        val colections: List<NFTCollection?> = results
            .distinctBy { it.tokenAddress }
            .map {
            val tokenId = it.tokenId
            val tokenAddress = it.tokenAddress
            val image = it.normalized?.image
            if (tokenId == null || tokenAddress == null || image == null)
                null
            else
                NFTCollection(
                    identifier = tokenAddress,
                    coverImage = null,
                    title = it.name ?: it.normalized.name ?: tokenAddress,
                    author = null,
                    isVerifiedAccount = it.normalized.verified ?: false ,
                    authorImage = null,
                    description = null,
                )
        }
        return Pair(colections.filterNotNull(), nfts.filterNotNull())
    }

    fun testProcessing(body: String): Pair<List<NFTCollection>, List<NFTItem>> {
        val resp = jsonDecode<Response>(body)
        return transformToStantardNFTs(resp?.result ?: emptyList())
    }

    @Serializable
    private data class Response(
        val page: Int?,
        @SerialName("page_size")
        val pageSize: Int?,
        val cursor: String?,
        val result: List<Response.Nft>?
    ) {
        @Serializable
        data class Nft(
            @SerialName("token_address")
            val tokenAddress: String?,
            @SerialName("token_id")
            val tokenId: String?,
            @SerialName("token_hash")
            val tokenHash: String?,
            val amount: String?,
            @SerialName("contract_type")
            val contractType: String?,
            val name: String?,
            val symbol: String?,
            @SerialName("token_uri")
            val tokenURI: String?,
            @SerialName("normalized_metadata")
            val normalized: NormalizedMetadata?
        ) {
            @Serializable
            data class NormalizedMetadata(
                val name: String?,
                val description: String?,
                val image: String?,
                val attributes: List<Attribute>?,
                @SerialName("verified_collection")
                val verified: Boolean?
            ) {
                @Serializable
                data class Attribute(
                    @SerialName("trait_type")
                    val traitType: String?,
                    val value: String?,
                )
            }
        }
    }

    /** We update the NFTItem.broadcasting property in case we have sent a
     * transaction that is pending to be accepted by the mempool */
    private fun updateMemPoolStatus(nfts: List<NFTItem>): List<NFTItem> {
        val currentNftIdsInMemPool = nftIdsInMemPool()
        val updatedNFTs = mutableListOf<NFTItem>()
        val updatedNftIdsInMemPool = mutableListOf<String>()
        nfts.forEach {
            if (currentNftIdsInMemPool.contains(it.identifier)) {
                it.inMemPool = true
                updatedNftIdsInMemPool.add(it.identifier)
            }
            updatedNFTs.add(it)
        }
        storeNftIdsInMemPool(updatedNftIdsInMemPool)
        return updatedNFTs
    }

    private fun storeNFTs(n: List<NFTItem>) {
        store[nftsKey] = jsonEncode(n)
    }

    private val nftsKey: String
        get() = "web3wallet.core.$addressKey.$networkKey.nfts"

    private fun storeCollections(c: List<NFTCollection>) {
        store[collectionsKey] = jsonEncode(c)
    }

    private val collectionsKey: String
        get() = "web3wallet.core.$addressKey.$networkKey.collections"

    private fun nftIdsInMemPool(): List<String> =
        jsonDecode(store[nftIdsInMemPoolKey] ?: "[]") ?: emptyList()

    private fun storeNftIdsInMemPool(s: List<String>) {
        store[nftIdsInMemPoolKey] = jsonEncode(s)
    }

    private val nftIdsInMemPoolKey: String get() =
        "web3wallet.core.$addressKey.$networkKey.nfts.memPool"

    private val addressKey: String get() =
        networksService.wallet()?.address()?.toHexStringAddress()?.hexString ?: "-"

    private val networkKey: String get() = networksService.network?.id() ?: "-"

    private fun broadcastNFTsChanged() =
        listeners.forEach { it.nftsChanged() }
}
