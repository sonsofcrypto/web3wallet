package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_core.AddressBytes
import com.sonsofcrypto.web3lib_utils.BigInt
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonArray

data class TransactionReceipt(
    val to: Address.HexString,
    val from: Address.HexString,
    val contractAddress: Address.HexString?,
    val transactionIndex: BigInt,
    val gasUsed: BigInt,
    val logsBloom: DataHexString,
    val blockHash: DataHexString,
    val transactionHash: DataHexString,
    val logs: List<Log>,
    val blockNumber: BigInt,
    val confirmations: BigInt?,
    val cumulativeGasUsed: BigInt,
    val effectiveGasPrice: BigInt,
    val root: DataHexString?,
    val type: TransactionType,
    val status: Int,
) {
    companion object {

        @Throws(Throwable::class)
        fun fromHexifiedJsonObject(
            jsonObject: JsonObject
        ) : TransactionReceipt = TransactionReceipt(
            to = Address.HexString(jsonObject.get("to")!!.stringValue()),
            from = Address.HexString(jsonObject.get("from")!!.stringValue()),
            contractAddress = Address.fromHexString(
                jsonObject.get("contractAddress")?.stringValue()
            ),
            transactionIndex = jsonObject.get("transactionIndex")
                !!.stringValue()
                .toBigIntQnt(),
            gasUsed = jsonObject.get("gasUsed")!!.stringValue().toBigIntQnt(),
            logsBloom = jsonObject.get("logsBloom")!!.stringValue(),
            blockHash = jsonObject.get("blockHash")!!.stringValue(),
            transactionHash = jsonObject.get("transactionHash")!!.stringValue(),
            logs = jsonObject.get("logs")?.jsonArray?.map {
                Log.fromHexifiedJsonObject(it as JsonObject)
            } ?: listOf(),
            blockNumber = jsonObject.get("blockNumber")
                !!.stringValue()
                .toBigIntQnt(),
            confirmations = jsonObject.get("confirmations")
                ?.stringValue()
                ?.toBigIntQnt(),
            cumulativeGasUsed = jsonObject.get("cumulativeGasUsed")
                !!.stringValue()
                .toBigIntQnt(),
            effectiveGasPrice = jsonObject.get("effectiveGasPrice")
                !!.stringValue()
                .toBigIntQnt(),
            root = jsonObject.get("root")?.stringValue(),
            type = TransactionType.from(
                jsonObject.get("type")!!.stringValue().toIntQnt()
            )!!,
            status = jsonObject.get("status")!!.stringValue().toIntQnt(),
        )
    }
}
