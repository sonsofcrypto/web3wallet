package com.sonsofcrypto.web3lib.abi

import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.provider.model.BlockTag
import com.sonsofcrypto.web3lib.provider.model.BlockTag.Latest
import com.sonsofcrypto.web3lib.provider.model.DataHexString
import com.sonsofcrypto.web3lib.provider.model.FeeData
import com.sonsofcrypto.web3lib.provider.model.Log
import com.sonsofcrypto.web3lib.provider.model.TransactionReceipt
import com.sonsofcrypto.web3lib.provider.model.TransactionRequest
import com.sonsofcrypto.web3lib.provider.model.TransactionResponse
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.testEnvServices
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.BigInt
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

interface Signer {

    /** Balance of network native currency */
    @Throws(Throwable::class)
    suspend fun getBalance(block: BlockTag): BigInt
    /** Count of all the sent transactions (nonce) */
    @Throws(Throwable::class)
    suspend fun getTransactionCount(address: Address, block: BlockTag): BigInt
    /** Populates `from` if unspecified, and estimates the fee */
    @Throws(Throwable::class)
    suspend fun estimateGas(transaction: TransactionRequest): BigInt

    /** Populates "from" if unspecified, and calls with the transaction */
    @Throws(Throwable::class)
    suspend fun call(transaction: TransactionRequest, block: BlockTag = Latest): DataHexString
    /** Populates all fields, signs and sends it to the network */
    @Throws(Throwable::class)
    suspend fun sendTransaction(transaction: TransactionRequest): TransactionResponse

    /** Get transfer logs for ERC20 */
    @Throws(Throwable::class)
    suspend fun getTransferLogs(currency: Currency): List<Log>
    /** Get transaction receipt */
    suspend fun getTransactionReceipt(hash: String): TransactionReceipt

    /** Chain id of network */
    @Throws(Throwable::class)
    suspend fun getChainId(): Unit
    /** Gas price */
    @Throws(Throwable::class)
    suspend fun gasPrice(): BigInt
    /** FeeData */
    @Throws(Throwable::class)
    suspend fun feeData(): FeeData
}