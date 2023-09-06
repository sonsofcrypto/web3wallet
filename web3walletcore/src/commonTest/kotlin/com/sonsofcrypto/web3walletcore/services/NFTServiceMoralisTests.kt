package com.sonsofcrypto.web3walletcore.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.utils.FileManager
import com.sonsofcrypto.web3lib.utils.FileManager.Location.BUNDLE
import com.sonsofcrypto.web3walletcore.services.nfts.NFTServiceMoralis
import com.sonsofcrypto.web3walletcore.testEnvNetworkService
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertTrue

class NFTServiceMoralisTests {

    @Test
    fun testNFTDecoding() {
        val body = FileManager()
            .readSync("testcases/nft_service_moralis_nft_tests.json", BUNDLE)
            .decodeToString()
        val nftService = NFTServiceMoralis(
            testEnvNetworkService("nftServiceMoralisTests"),
            KeyValueStore("nftServiceMoralisTests.nftService")
        )
        val result = nftService.testProcessing(body)
        println("[NFTServiceMoralisTests] collections count: ${result.first.count()}")
        println("[NFTServiceMoralisTests] nfts count: ${result.second.count()}")

        result.first.forEach {
            println(it.title)
        }
    }
}



