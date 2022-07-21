package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.*
import com.sonsofcrypto.web3lib_utils.BigInt
import kotlinx.coroutines.*
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonObject

data class TransactionRequest(
    val to: Address? = null,
    val from: Address? = null,
    val nonce: BigInt? = null,

    val gasLimit: BigInt? = null,
    val gasPrice: BigInt? = null,

    val data: ByteArray? = null,
    val value: BigInt? = null,
    val chainId: Int? = null,

    val type: TransactionType? = null,
    val accessList: AccessList? = null,

    val maxPriorityFeePerGas: BigInt? = null,
    val maxFeePerGas: BigInt? = null,

    val customData: Map<String, Any>? = null,
    val ccipReadEnabled: Boolean? = null, // EIP-3668
)

// TODO: Add support for EIP-1559 abstract signer 242
fun TransactionRequest.JsonRpc(
    nameService: NameServiceProvider? = null
): JsonElement = buildJsonObject {
    val resolvedTo = JsonRpcResolveAddress(to, nameService)
    val resolvedFrom = JsonRpcResolveAddress(to, nameService)
    if (resolvedTo != null) {
        put("to", resolvedTo.jsonPrimitive())
    }
    if (resolvedFrom != null) {
        put("from", resolvedFrom.jsonPrimitive())
    }
    if (nonce != null) {
        put("nonce", JsonPrimitive(QuantityHexString(nonce)))
    }
    if (gasLimit != null) {
        put("gas", JsonPrimitive(QuantityHexString(gasLimit)))
    }
    if (gasPrice != null) {
        put("gasPrice", JsonPrimitive(QuantityHexString(gasPrice)))
    }
    if (data != null) {
        put("data", JsonPrimitive(DataHexString(data)))
    }
    if (value != null) {
        put("value", JsonPrimitive(QuantityHexString(value)))
    }
    if (chainId != null) {
        put("chainId", JsonPrimitive(QuantityHexString(chainId)))
    }
    if (type != null) {
        put("type", JsonPrimitive(type.value))
    }
//    if (accessList != null) {
//        put("accessList", accessList)
//    }
    if (maxPriorityFeePerGas != null) {
        put("maxPriorityFeePerGas", JsonPrimitive(QuantityHexString(maxPriorityFeePerGas)))
    }
    if (maxFeePerGas != null) {
        put("maxFeePerGas", JsonPrimitive(QuantityHexString(maxFeePerGas)))
    }
}

fun TransactionRequest.JsonRpcResolveAddress(
    address: Address?,
    nameService: NameServiceProvider? = null
): Address? {
    if (address == null) {
        return null
    }
    return when (address) {
        is Address.HexStringAddress -> address
        is Address.BytesAddress -> TODO("Convert to hex string format")
        is Address.NameAddress -> if (nameService != null) {
            runBlocking { nameService.resolve(address.name) }
        } else null
    }
}
