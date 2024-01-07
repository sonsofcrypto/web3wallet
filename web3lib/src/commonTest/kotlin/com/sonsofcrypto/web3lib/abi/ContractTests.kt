package com.sonsofcrypto.web3lib.abi

import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.testEnvServices
import com.sonsofcrypto.web3lib.types.Network
import kotlinx.coroutines.runBlocking
import kotlin.test.Test

class ContractTests {

    @Test
    fun testER20Balances() = runBlocking {
        // Test Acc 0 0x24632a2e4b7f93c7ae0dae0b22eeda014b2c4f47
        // Test Acc 1 0xe88b8af31f935d8dccf7bee7543d3bb19f90d9c8
        // WETH 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6

        val testEnv = testEnvServices("contract", Network.goerli())
        val provider = ProviderPocket(Network.goerli())
        val contract = Contract(
            Interface.ERC20(),
            "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6",
            provider,

        )
    }
}
