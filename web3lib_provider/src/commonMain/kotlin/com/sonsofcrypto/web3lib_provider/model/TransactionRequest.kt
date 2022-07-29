package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.*
import com.sonsofcrypto.web3lib_provider.model.JsonPrimitiveQntHexStr
import com.sonsofcrypto.web3lib_utils.BigInt
import kotlinx.serialization.json.*

data class TransactionRequest(
    val to: Address.HexString? = null,
    val from: Address.HexString? = null,
    val nonce: BigInt? = null,
    val gasLimit: BigInt? = null,
    val gasPrice: BigInt? = null,
    val data: DataHexString? = null,
    val value: BigInt? = null,
    val chainId: Int? = null,
    val type: TransactionType? = null,

    /** Signature */
    val r: BigInt? = null,
    val s: BigInt? = null,
    val v: BigInt? = null,

    /** Based on `type` `EIP-2930` or EIP-1559 */
    val accessList: AccessList? = null,

    /** EIP-1559 */
    val maxPriorityFeePerGas: BigInt? = null,
    val maxFeePerGas: BigInt? = null,

    /** EIP-3668 */
    val ccipReadEnabled: Boolean? = null,
) { companion object }

@Throws(Throwable::class)
fun TransactionRequest.encodeEIP1559(): ByteArray {
    if (gasPrice != null && gasPrice != maxFeePerGas) {
        throw Exception("Mismatch EIP-1559 gasPrice != maxFeePerGas")
    }

    var items = listOf(
        RlpItem(QuantityHexString(chainId!!).toByteArrayQnt()),
        RlpItem(QuantityHexString(nonce!!).toByteArrayQnt()),
        RlpItem(QuantityHexString(maxPriorityFeePerGas ?: BigInt.zero()).toByteArrayQnt()),
        RlpItem(QuantityHexString(maxFeePerGas ?: BigInt.zero()).toByteArrayQnt()),
        RlpItem(QuantityHexString(gasLimit!!).toByteArrayQnt()),
        RlpItem(to?.hexString?.toByteArrayData() ?: ByteArray(0)),
        RlpItem(QuantityHexString(value!!).toByteArrayQnt()),
        RlpItem(if(data == null) ByteArray(0) else data.toByteArrayData()),
        RlpList(
            accessList?.map {
                RlpList(
                    listOf(
                        RlpItem(it.address.hexString.toByteArrayData()),
                        RlpList(it.storageKeys.map { k -> RlpItem(k.toByteArrayData()) })
                    )
                )
            } ?: emptyList()
        )
    )

    if (r != null && s != null && v != null) {
        items += listOf(
            RlpItem(v.toByteArray()),
            RlpItem(r.toByteArray()),
            RlpItem(s.toByteArray()),
        )
    }

    return TransactionType.EIP1559.toByteArray() + RlpList(items).encode()
}

fun TransactionRequest.toHexifiedJsonObject(): JsonObject = buildJsonObject {
    if (to != null) put("to", JsonPrimitive(to.hexString))
    if (from != null) put("from", JsonPrimitive(from.hexString))
    if (nonce != null) put("nonce", JsonPrimitiveQntHexStr(nonce))
    if (gasLimit != null) put("gas", JsonPrimitiveQntHexStr(gasLimit))
    if (gasPrice != null) put("gasPrice", JsonPrimitiveQntHexStr(gasPrice))
    put("data", JsonPrimitive(data))
    if (value != null) put("value", JsonPrimitiveQntHexStr(value))
    if (chainId != null) put("chainId", JsonPrimitiveQntHexStr(chainId))
    if (type != null) put("type", JsonPrimitiveQntHexStr(type.value))
    if (r != null) put("r", JsonPrimitiveQntHexStr(r))
    if (s != null) put("s", JsonPrimitiveQntHexStr(s))
    if (v != null) put("v", JsonPrimitiveQntHexStr(v))
    if (accessList != null) {
        val encoded = accessList.map {
            buildJsonObject{
                put("address", JsonPrimitive(it.address.hexString) as JsonElement)
                put("storageKeys", it.storageKeys.map { k -> JsonPrimitive(k) } as JsonElement)
            }
        }
        put("accessList", JsonArray(encoded))
    }
    if (maxPriorityFeePerGas != null) {
        put("maxPriorityFeePerGas", JsonPrimitiveQntHexStr(maxPriorityFeePerGas))
    }
    if (maxFeePerGas != null) {
        put("maxFeePerGas", JsonPrimitiveQntHexStr(maxFeePerGas))
    }
}
