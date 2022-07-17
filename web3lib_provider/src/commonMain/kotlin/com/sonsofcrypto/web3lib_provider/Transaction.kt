package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.AddressBytes
import com.sonsofcrypto.web3lib_core.ExtKey
import com.sonsofcrypto.web3lib_utils.BigInt

typealias AccessList = List<Pair<AddressBytes,List<ExtKey>>>

enum class TransactionType(val value: Int) {
    LEGACY(0), EIP2930(1), EIP1559(2)
}

interface Transaction {
    val hash: String?

    val to: AddressBytes?
    val from: AddressBytes?
    val nonce: BigInt

    val gasLimit: BigInt
    val gasPrice: BigInt?

    val data: ByteArray
    val value: BigInt
    val chainId: Int

    val r: String?
    val s: String?
    val v: Int?

    val type: TransactionType?

    /** Based on `type` EIP-2930 or EIP-1559 */
    val accessList: AccessList?

    /** EIP-1559 */
    val maxPriorityFeePerGas: BigInt?
    val maxFeePerGas: BigInt?
}

interface SignedTransaction {

}

data class UnsignedTransaction(
    val to: AddressBytes?,
    val nonce: BigInt,

    val gasLimit: BigInt?,
    val gasPrice: BigInt?,

    val data: ByteArray?,
    val value: BigInt?,
    val chainId: Int?,

    val type: TransactionType?,

    /** Based on `type` EIP-2930 or EIP-1559 */
    val accessList: AccessList?,

    /** EIP-1559 */
    val maxPriorityFeePerGas: BigInt?,
    val maxFeePerGas: BigInt?,
)