package com.sonsofcrypto.web3lib.provider.model

import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.provider.utils.*
import com.sonsofcrypto.web3lib.provider.utils.JsonPrimitiveQntHexStr
import com.sonsofcrypto.web3lib.provider.utils.stringValue
import com.sonsofcrypto.web3lib.utils.BigInt
import kotlinx.serialization.json.*

typealias AccessList = List<AccessListItem>

data class AccessListItem(
    val address: Address.HexString,
    val storageKeys: List<DataHexString>
)

enum class TransactionType(val value: Int) {
    LEGACY(0), EIP2930(1), EIP1559(2);

    fun toByteArray(): ByteArray = QuantityHexString(value).toByteArrayQnt()

    companion object {
        fun from(int: Int?): TransactionType? = values().find { it.value == int}
    }
}

data class Transaction(
    val hash: String?,
    val to: Address.HexString?,
    val from: Address.HexString?,
    val nonce: BigInt,
    val gasLimit: BigInt,
    val gasPrice: BigInt?,
    val input: DataHexString,
    val value: BigInt,
    val chainId: BigInt,
    val type: TransactionType?,

    /** Signature */
    val r: BigInt?,
    val s: BigInt?,
    val v: BigInt?,

    /** Based on `type` `EIP-2930` or EIP-1559 */
    val accessList: AccessList?,

    /** EIP-1559 */
    val maxPriorityFeePerGas: BigInt?,
    val maxFeePerGas: BigInt?,

    /** In response only */
    val blockHash: String? = null,
    val blockNumber: BigInt? = null,
    val transactionIndex: BigInt? = null
) { companion object { }  }

@Throws(Throwable::class)
fun Transaction.encodeEIP1559(): ByteArray {
    if (gasPrice != null && gasPrice != maxFeePerGas) {
        throw Exception("Mismatch EIP-1559 gasPrice != maxFeePerGas")
    }

    var items = listOf(
        RlpItem(QuantityHexString(chainId).toByteArrayQnt()),
        RlpItem(QuantityHexString(nonce).toByteArrayQnt()),
        RlpItem(QuantityHexString(maxPriorityFeePerGas ?: BigInt.zero()).toByteArrayQnt()),
        RlpItem(QuantityHexString(maxFeePerGas ?: BigInt.zero()).toByteArrayQnt()),
        RlpItem(QuantityHexString(gasLimit).toByteArrayQnt()),
        RlpItem(to?.hexString?.toByteArrayData() ?: ByteArray(0)),
        RlpItem(QuantityHexString(value).toByteArrayQnt()),
        RlpItem(if(input.isEmpty()) ByteArray(0) else input.toByteArrayData()),
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

fun Transaction.toHexifiedJsonObject(): JsonObject = buildJsonObject {
    put("nonce", JsonPrimitiveQntHexStr(nonce))
    put("gas", JsonPrimitiveQntHexStr(gasLimit))
    put("data", JsonPrimitive(input))
    put("value", JsonPrimitiveQntHexStr(value))
    put("chainId", JsonPrimitiveQntHexStr(chainId))
    if (hash != null) put("hash", JsonPrimitive(hash))
    if (to != null) put("to", JsonPrimitive(to.hexString))
    if (from != null) put("from", JsonPrimitive(from.hexString))
    if (gasPrice != null) put("gasPrice", JsonPrimitiveQntHexStr(gasPrice))
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

@Throws(Throwable::class)
fun Transaction.Companion.fromHexifiedJsonObject(jsonObject: JsonObject): Transaction = Transaction(
    hash = jsonObject["hash"]?.stringValue(),
    to = Address.fromHexString(jsonObject["to"]?.stringValue()),
    from = Address.fromHexString(jsonObject["from"]?.stringValue()),
    nonce = jsonObject["nonce"]!!.toBigIntQnt(),
    gasLimit = jsonObject["gas"]!!.toBigIntQnt(),
    gasPrice = jsonObject["gasPrice"]?.toBigIntQnt(),
    input = jsonObject["input"]?.stringValue()
        ?: jsonObject["data"]?.stringValue()
        ?: "",
    value = jsonObject["value"]!!.toBigIntQnt(),
    chainId = jsonObject["chainId"]!!.toBigIntQnt(),
    type = TransactionType.from(jsonObject["type"]?.stringValue()?.toIntQnt()),
    r = jsonObject["r"]?.toBigIntQnt(),
    s = jsonObject["s"]?.toBigIntQnt(),
    v = jsonObject["v"]?.toBigIntQnt(),
    accessList = jsonObject["accessList"]?.jsonArray?.map {
        val obj = it as JsonObject
        AccessListItem(
            Address.HexString(obj["address"]!!.stringValue()),
            obj.get("storageKeys")!!.jsonArray.map { k -> k.stringValue() }
        )
    },
    maxPriorityFeePerGas = jsonObject["maxPriorityFeePerGas"]?.toBigIntQnt(),
    maxFeePerGas = jsonObject["maxFeePerGas"]?.toBigIntQnt(),
    blockHash = jsonObject["blockHash"]?.stringValue(),
    blockNumber = jsonObject["blockNumber"]?.toBigIntQnt(),
    transactionIndex = jsonObject["transactionIndex"]?.toBigIntQnt(),
)