package com.sonsofcrypto.web3lib_signer

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_core.AddressBytes
import com.sonsofcrypto.web3lib_core.Network
import com.sonsofcrypto.web3lib_core.Signer
import com.sonsofcrypto.web3lib_keystore.KeyStoreItem
import com.sonsofcrypto.web3lib_keystore.KeyStoreService
import com.sonsofcrypto.web3lib_provider.*
import com.sonsofcrypto.web3lib_provider.model.BlockTag
import com.sonsofcrypto.web3lib_utils.BigInt

class Wallet: Signer {
    private val keyStoreItem: KeyStoreItem
    private val keyStoreService: KeyStoreService
    private var provider: Provider? = null

    constructor(
        keyStoreItem: KeyStoreItem,
        keyStoreService: KeyStoreService
    ) {
        this.keyStoreItem = keyStoreItem
        this.keyStoreService = keyStoreService
    }

    fun id(): String = keyStoreItem.uuid

    override fun connect(provider: Provider): Signer {
        this.provider = provider
        return this
    }

    override fun provider(): Provider? = provider

    override suspend fun address(): AddressBytes {
        TODO("Not yet implemented")
    }

    override suspend fun signMessage(message: ByteArray): ByteArray {
        TODO("Not yet implemented")
    }

    override suspend fun signTransaction(transaction: TransactionRequest): DataHexString {
        TODO("Not yet implemented")
    }

    override suspend fun getBalance(block: BlockTag): BigInt {
        TODO("Not yet implemented")
    }

    override suspend fun getTransactionCount(address: Address, block: BlockTag): BigInt {
        TODO("Not yet implemented")
    }

    override suspend fun estimateGas(transaction: Transaction): BigInt {
        TODO("Not yet implemented")
    }

    override suspend fun call(transaction: TransactionRequest, block: UInt?): ByteArray {
        TODO("Not yet implemented")
    }

    override suspend fun sendTransaction(transaction: TransactionRequest): TransactionResponse {
        TODO("Transform to raw")
    }

    override suspend fun getChainId() {
        provider!!.network.chainId
    }

    override suspend fun gasPrice(): BigInt {
        return provider!!.gasPrice()
    }

    override suspend fun feeData(): FeeData {
        return provider!!.feeData()
    }

    override suspend fun resolveName(name: String): Address.HexString? {
        return provider!!.resolveName(name)
    }
}

