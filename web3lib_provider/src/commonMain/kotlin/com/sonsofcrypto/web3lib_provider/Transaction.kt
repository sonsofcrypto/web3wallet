package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_utils.BigInt
import kotlinx.serialization.json.*

typealias AccessList = List<AccessListItem>

data class AccessListItem(
    val address: Address.HexString,
    val storageKeys: List<DataHexString>
)

enum class TransactionType(val value: Int) {
    LEGACY(0), EIP2930(1), EIP1559(2);

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

//    formatNumber(transaction.chainId || 0, "chainId"),
//    formatNumber(transaction.nonce || 0, "nonce"),
//    formatNumber(transaction.maxPriorityFeePerGas || 0, "maxPriorityFeePerGas"),
//    formatNumber(transaction.maxFeePerGas || 0, "maxFeePerGas"),
//    formatNumber(transaction.gasLimit || 0, "gasLimit"),
//    ((transaction.to != null) ? getAddress(transaction.to): "0x"),
//    formatNumber(transaction.value || 0, "value"),
//    (transaction.data || "0x"),
//    (formatAccessList(transaction.accessList || []))

    val items = listOf(
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

    return "0x02".toByteArrayData() + RlpList(items).encode()
}

fun Transaction.toHexifiedJsonObject(): JsonObject = buildJsonObject {
    if (hash != null) {
        put("hash", JsonPrimitive(hash))
    }
    if (to != null) {
        put("to", JsonPrimitive(to.hexString))
    }
    if (from != null) {
        put("from", JsonPrimitive(from.hexString))
    }
    put("nonce", JsonPrimitive(QuantityHexString(nonce)))
    put("gas", JsonPrimitive(QuantityHexString(gasLimit)))
    if (gasPrice != null) {
        put("gasPrice", JsonPrimitive(QuantityHexString(gasPrice)))
    }
    put("input", JsonPrimitive(input))
    put("value", JsonPrimitive(QuantityHexString(value)))
    put("chainId", JsonPrimitive(QuantityHexString(chainId)))
    if (type != null) {
        put("type", JsonPrimitive(QuantityHexString(type.value)))
    }
    if (r != null) {
        put("r", JsonPrimitive(QuantityHexString(r)))
    }
    if (s != null) {
        put("s", JsonPrimitive(QuantityHexString(s)))
    }
    if (v != null) {
        put("v", JsonPrimitive(QuantityHexString(v)))
    }
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
        put("maxPriorityFeePerGas", JsonPrimitive(QuantityHexString(maxPriorityFeePerGas)))
    }
    if (maxFeePerGas != null) {
        put("maxFeePerGas", JsonPrimitive(QuantityHexString(maxFeePerGas)))
    }
}

@Throws(Throwable::class)
fun Transaction.Companion.fromHexifiedJsonObject(jsonObject: JsonObject): Transaction = Transaction(
    hash = jsonObject.get("hash")?.stringValue(),
    to = Address.fromHexString(jsonObject.get("to")?.stringValue()),
    from = Address.fromHexString(jsonObject.get("from")?.stringValue()),
    nonce = jsonObject.get("nonce")!!.stringValue().toBigIntQnt(),
    gasLimit = jsonObject.get("gas")!!.stringValue().toBigIntQnt(),
    gasPrice = jsonObject.get("gasPrice")?.stringValue()?.toBigIntQnt(),
    input = jsonObject.get("input")?.stringValue() ?: "",
    value = jsonObject.get("value")!!.stringValue().toBigIntQnt(),
    chainId = jsonObject.get("chainId")!!.stringValue().toBigIntQnt(),
    type = TransactionType.from(
        jsonObject.get("type")?.stringValue()?.toIntQnt()
    ),
    r = jsonObject.get("r")?.stringValue()?.toBigIntQnt(),
    s = jsonObject.get("s")?.stringValue()?.toBigIntQnt(),
    v = jsonObject.get("v")?.stringValue()?.toBigIntQnt(),
    accessList = jsonObject.get("accessList")?.jsonArray?.map {
        val obj = it as JsonObject
        AccessListItem(
            Address.HexString(obj.get("address")!!.stringValue()),
            obj.get("storageKeys")!!.jsonArray.map { k -> k.stringValue() }
        )
    },
    maxPriorityFeePerGas = jsonObject.get("maxPriorityFeePerGas")
        ?.stringValue()
        ?.toBigIntQnt(),
    maxFeePerGas = jsonObject.get("maxFeePerGas")
        ?.stringValue()
        ?.toBigIntQnt(),
    blockHash = jsonObject.get("blockHash")?.stringValue(),
    blockNumber = jsonObject.get("blockNumber")
        ?.stringValue()
        ?.toBigIntQnt(),
    transactionIndex = jsonObject.get("transactionIndex")
        ?.stringValue()
        ?.toBigIntQnt(),
)