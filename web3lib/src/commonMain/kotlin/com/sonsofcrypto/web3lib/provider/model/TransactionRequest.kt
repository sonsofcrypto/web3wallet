package com.sonsofcrypto.web3lib.provider.model

import com.sonsofcrypto.web3lib.provider.model.TransactionType.EIP1559
import com.sonsofcrypto.web3lib.provider.model.TransactionType.EIP2930
import com.sonsofcrypto.web3lib.provider.model.TransactionType.LEGACY
import com.sonsofcrypto.web3lib.provider.utils.JsonPrimitiveQntHexStr
import com.sonsofcrypto.web3lib.provider.utils.RlpItem
import com.sonsofcrypto.web3lib.provider.utils.RlpList
import com.sonsofcrypto.web3lib.provider.utils.encode
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.utils.BigInt
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonObject

data class TransactionRequest(
    val to: Address.HexString? = null,
    val from: Address.HexString? = null,
    val nonce: BigInt? = null,
    val gasLimit: BigInt? = null,
    val gasPrice: BigInt? = null,
    val data: DataHexStr? = null,
    val value: BigInt? = null,
    val chainId: BigInt? = null,
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
fun TransactionRequest.encode(): ByteArray = when (type ?: EIP1559) {
    EIP1559 -> encodeEIP1559()
    EIP2930 -> encodeEIP2930()
    LEGACY -> encodeLegacy()
}

@Throws(Throwable::class)
fun TransactionRequest.encodeLegacy(): ByteArray {
    var items = listOf(
        RlpItem(
            if (nonce == null || nonce.isZero()) ByteArray(0)
            else QntHexStr(nonce).toByteArrayQnt()
        ),
        RlpItem(QntHexStr(gasPrice!!).toByteArrayQnt()),
        RlpItem(QntHexStr(gasLimit!!).toByteArrayQnt()),
        RlpItem(to?.hexString?.toByteArrayData() ?: ByteArray(0)),
        RlpItem(
            if (value == null || value.isZero()) ByteArray(0)
            else QntHexStr(value).toByteArrayQnt()
        ),
        RlpItem(data?.toByteArrayData() ?: ByteArray(0)),
    )

    if (r != null && s != null && v != null)
        items += listOf(v, r, s).map { RlpItem(it.toByteArray()) }

    return RlpList(items).encode()
}

@Throws(Throwable::class)
fun TransactionRequest.encodeEIP2930(): ByteArray {
    var items = listOf(
        RlpItem(QntHexStr(chainId!!).toByteArrayQnt()),
        RlpItem(
            if (nonce == null || nonce.isZero()) ByteArray(0)
            else QntHexStr(nonce).toByteArrayQnt()
        ),
        RlpItem(QntHexStr(gasPrice!!).toByteArrayQnt()),
        RlpItem(QntHexStr(gasLimit!!).toByteArrayQnt()),
        RlpItem(to?.hexString?.toByteArrayData() ?: ByteArray(0)),
        RlpItem(
            if (value == null || value.isZero()) ByteArray(0)
            else QntHexStr(value).toByteArrayQnt()
        ),
        RlpItem(data?.toByteArrayData() ?: ByteArray(0)),
        rlpListAccessList(),
    )

    if (r != null && s != null && v != null)
        items += listOf(v, r, s).map { RlpItem(it.toByteArray()) }

    return EIP2930.toByteArray() + RlpList(items).encode()
}

@Throws(Throwable::class)
fun TransactionRequest.encodeEIP1559(): ByteArray {
    if (gasPrice != null && gasPrice != maxFeePerGas) {
        throw Exception("Mismatch EIP-1559 gasPrice != maxFeePerGas")
    }

    var items = listOf(
        RlpItem(QntHexStr(chainId!!).toByteArrayQnt()),
        RlpItem(
            if (nonce == null || nonce.isZero()) ByteArray(0)
            else QntHexStr(nonce).toByteArrayQnt()
        ),
        RlpItem(QntHexStr(maxPriorityFeePerGas ?: BigInt.zero).toByteArrayQnt()),
        RlpItem(QntHexStr(maxFeePerGas ?: BigInt.zero).toByteArrayQnt()),
        RlpItem(QntHexStr(gasLimit!!).toByteArrayQnt()),
        RlpItem(to?.hexString?.toByteArrayData() ?: ByteArray(0)),
        RlpItem(
            if (value == null || value.isZero()) ByteArray(0)
            else QntHexStr(value).toByteArrayQnt()
        ),
        RlpItem(data?.toByteArrayData() ?: ByteArray(0)),
        rlpListAccessList(),
    )

    if (r != null && s != null && v != null)
        items += listOf(v, r, s).map { RlpItem(it.toByteArray()) }

    return EIP1559.toByteArray() + RlpList(items).encode()
}

private fun TransactionRequest.rlpListAccessList(): RlpList = RlpList(
    accessList?.map {
        RlpList(
            listOf(
                RlpItem(it.address.hexString.toByteArrayData()),
                RlpList(it.storageKeys.map { k -> RlpItem(k.toByteArrayData()) })
            )
        )
    } ?: emptyList()
)

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
