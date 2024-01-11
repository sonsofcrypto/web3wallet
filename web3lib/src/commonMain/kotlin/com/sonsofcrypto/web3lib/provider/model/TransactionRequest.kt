package com.sonsofcrypto.web3lib.provider.model

import com.sonsofcrypto.web3lib.provider.model.TransactionType.EIP1559
import com.sonsofcrypto.web3lib.provider.model.TransactionType.EIP2930
import com.sonsofcrypto.web3lib.provider.model.TransactionType.LEGACY
import com.sonsofcrypto.web3lib.provider.utils.JsonPrimitiveQntHexStr
import com.sonsofcrypto.web3lib.provider.utils.Rlp
import com.sonsofcrypto.web3lib.provider.utils.RlpList
import com.sonsofcrypto.web3lib.provider.utils.RlpItem
import com.sonsofcrypto.web3lib.provider.utils.decode
import com.sonsofcrypto.web3lib.provider.utils.encode
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
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

) {

    @Throws(Throwable::class)
    fun encode(): ByteArray = when (type ?: EIP1559) {
        EIP1559 -> encodeEIP1559()
        EIP2930 -> encodeEIP2930()
        LEGACY -> encodeLegacy()
    }


    @Throws(Throwable::class)
    fun encodeLegacy(): ByteArray {
        var items = listOf(
            RlpItem(qntBigIntToByteArray(nonce)),
            RlpItem(qntBigIntToByteArray(gasPrice)),
            RlpItem(qntBigIntToByteArray(gasLimit)),
            RlpItem(to?.hexString?.toByteArrayData() ?: ByteArray(0)),
            RlpItem(qntBigIntToByteArray(value)),
            RlpItem(data?.toByteArrayData() ?: ByteArray(0)),
        )

        var chainId: BigInt = BigInt.zero

        // A chainId was provided; if non-zero we'll use EIP-155
        if (this.chainId != null)
            chainId = this.chainId
        // No chainId, but the signature is signing with EIP-155; derive chainId
        else if (v != null && v.isGreaterThan(BigInt.from(28)))
            chainId = BigInt.from(v.toDecimalString().toInt() - 35 / 2)

        // We have an EIP-155 transaction without signature
        if (r == null || s == null || v == null || r.isZero() || s.isZero()) {
            if (!chainId.isZero())
                items += listOf(chainId, BigInt.zero, BigInt.zero)
                    .map { RlpItem(qntBigIntToByteArray(it)) }
            return RlpList(items).encode()
        }

        var v = legacyRecId(this.v)
        if (!chainId.isZero())
            v = v.add(chainId.mul(2).add(8))

        items += listOf(v, r, s).map { RlpItem(it.toByteArray()) }
        return RlpList(items).encode()
    }

    private fun legacyRecId(v: BigInt): BigInt {
        val intV = v.toDecimalString().toInt()
        return if (intV == 0 || intV == 1) BigInt.from(intV + 27) else v
    }

    @Throws(Throwable::class)
    fun encodeEIP2930(): ByteArray {
        var items = listOf(
            RlpItem(QntHexStr(chainId!!).toByteArrayQnt()),
            RlpItem(qntBigIntToByteArray(nonce)),
            RlpItem(qntBigIntToByteArray(gasPrice)),
            RlpItem(qntBigIntToByteArray(gasLimit)),
            RlpItem(to?.hexString?.toByteArrayData() ?: ByteArray(0)),
            RlpItem(qntBigIntToByteArray(value)),
            RlpItem(data?.toByteArrayData() ?: ByteArray(0)),
            rlpListAccessList(),
        )

        if (r != null && s != null && v != null)
            items += listOf(v, r, s).map { RlpItem(it.toByteArray()) }

        return EIP2930.toByteArray() + RlpList(items).encode()
    }

    @Throws(Throwable::class)
    fun encodeEIP1559(): ByteArray {
        if (gasPrice != null && gasPrice != maxFeePerGas) {
            throw Exception("Mismatch EIP-1559 gasPrice != maxFeePerGas")
        }

        var items = listOf(
            RlpItem(QntHexStr(chainId!!).toByteArrayQnt()),
            RlpItem(qntBigIntToByteArray(nonce)),
            RlpItem(QntHexStr(maxPriorityFeePerGas ?: BigInt.zero).toByteArrayQnt()),
            RlpItem(QntHexStr(maxFeePerGas ?: BigInt.zero).toByteArrayQnt()),
            RlpItem(qntBigIntToByteArray(gasLimit)),
            RlpItem(to?.hexString?.toByteArrayData() ?: ByteArray(0)),
            RlpItem(qntBigIntToByteArray(value)),
            RlpItem(data?.toByteArrayData() ?: ByteArray(0)),
            rlpListAccessList(),
        )

        if (r != null && s != null && v != null)
            items += listOf(v, r, s).map { RlpItem(it.toByteArray()) }

        return EIP1559.toByteArray() + RlpList(items).encode()
    }

    private fun rlpListAccessList(): RlpList = RlpList(
        accessList?.map {
            RlpList(
                listOf(
                    RlpItem(it.address.hexString.toByteArrayData()),
                    RlpList(it.storageKeys.map { k -> RlpItem(k.toByteArrayData()) })
                )
            )
        } ?: emptyList()
    )

    private fun qntBigIntToByteArray(value: BigInt?): ByteArray =
        if (value == null || value.isZero()) ByteArray(0)
        else QntHexStr(value).toByteArrayQnt()

    fun toHexifiedJsonObject(): JsonObject = buildJsonObject {
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

    sealed class Error(message: String? = null) : Exception(message) {
        data class DecodeInvalidTypeByte(val byte: UInt) :
            Error("Can not decode transaction, invalid first byte $byte")
        data class DecodeInvalidRlp(val rlp: Rlp?):
            Error("Expected RlpList, got item $rlp")
    }

    companion object {

        @Throws(Throwable::class)
        fun decodeLegacy(bytes: ByteArray): TransactionRequest {
            val rlp = Rlp.decode(bytes) as? RlpList
            if (rlp == null) throw Error.DecodeInvalidRlp(rlp)
            val tx = TransactionRequest(
                type = LEGACY,
                nonce = BigInt.from((rlp.element[0] as RlpItem).bytes),
                gasPrice = BigInt.from((rlp.element[1] as RlpItem).bytes),
                gasLimit = BigInt.from((rlp.element[2] as RlpItem).bytes),
                to = if ((rlp.element[3] as RlpItem).bytes.isEmpty()) null
                    else Address.HexString(
                        (rlp.element[3] as RlpItem).bytes.toHexString(true)
                    ),
                value = BigInt.from((rlp.element[4] as RlpItem).bytes),
                data = DataHexStr((rlp.element[5] as RlpItem).bytes),
            )
            val v = bigIntOrNull((rlp.element.getOrNull(6) as? RlpItem)?.bytes)
            val r = bigIntOrNull((rlp.element.getOrNull(7) as? RlpItem)?.bytes)
            val s = bigIntOrNull((rlp.element.getOrNull(8) as? RlpItem)?.bytes)

            // EIP-155 unsigned transaction
            if (
                v?.isZero() == false &&
                r?.isZero() == true &&
                s?.isZero() == true
            )
                return tx.copy(
                    chainId = nullIfZero(v), v = BigInt.zero, r = r, s = s
                )

            // Signed legacy
            if (rlp.element.size == 9 && (v != null && r != null && s != null)) {
                var chainId = v.sub(35).div(2)
                var recId = v.sub(27)
                chainId = if (chainId.isLessThanZero()) BigInt.zero else chainId
                if (chainId.isGreaterThan(BigInt.zero))
                    recId = recId.sub(chainId.mul(2).add(8))

                // TODO: Recover `from` address
                return tx.copy(chainId = nullIfZero(chainId), v = recId, r = r, s = s)
            }

            return tx.copy(v = v, r = r, s = s)
        }

        @Throws(Throwable::class)
        fun decodeEIP2930(bytes: ByteArray): TransactionRequest {
            val rlp = Rlp.decode(bytes) as? RlpList
            if (rlp == null) throw Error.DecodeInvalidRlp(rlp)
            return TransactionRequest(
                type = EIP2930,
                chainId = BigInt.from((rlp.element[0] as RlpItem).bytes),
                nonce = BigInt.from((rlp.element[1] as RlpItem).bytes),
                gasPrice = BigInt.from((rlp.element[2] as RlpItem).bytes),
                gasLimit = BigInt.from((rlp.element[3] as RlpItem).bytes),
                to = if ((rlp.element[4] as RlpItem).bytes.isEmpty()) null
                    else Address.HexString(
                        (rlp.element[4] as RlpItem).bytes.toHexString(true)
                    ),
                value = BigInt.from((rlp.element[5] as RlpItem).bytes),
                data = DataHexStr((rlp.element[6] as RlpItem).bytes),
                accessList = decodeAccessList(rlp.element[7]),
                v = bigIntOrNull((rlp.element.getOrNull(8) as? RlpItem)?.bytes),
                r = bigIntOrNull((rlp.element.getOrNull(9) as? RlpItem)?.bytes),
                s = bigIntOrNull((rlp.element.getOrNull(10) as? RlpItem)?.bytes),
            )
        }

        @Throws(Throwable::class)
        private fun decodeAccessList(rlp: Rlp?): AccessList? {
            val topList = (rlp as? RlpList) ?: return null
            return topList.element.map {
                val item = it as RlpList
                AccessListItem(
                    Address.HexString(
                        (item.element[0] as RlpItem).bytes.toHexString(true)
                    ),
                    (item.element[1] as RlpList).element.map { sk ->
                        DataHexStr((sk as RlpItem).bytes)
                    }
                )

            }
        }

        @Throws(Throwable::class)
        fun decodeEIP1559(bytes: ByteArray): TransactionRequest {
            val rlp = Rlp.decode(bytes) as? RlpList
            if (rlp == null) throw Error.DecodeInvalidRlp(rlp)
            return TransactionRequest(
                type = EIP1559,
                chainId = BigInt.from((rlp.element[0] as RlpItem).bytes),
                nonce = BigInt.from((rlp.element[1] as RlpItem).bytes),
                maxPriorityFeePerGas = BigInt.from((rlp.element[2] as RlpItem).bytes),
                maxFeePerGas = BigInt.from((rlp.element[3] as RlpItem).bytes),
                gasLimit = BigInt.from((rlp.element[4] as RlpItem).bytes),
                to = if ((rlp.element[5] as RlpItem).bytes.isEmpty()) null
                else Address.HexString(
                    (rlp.element[5] as RlpItem).bytes.toHexString(true)
                ),
                value = BigInt.from((rlp.element[6] as RlpItem).bytes),
                data = DataHexStr((rlp.element[7] as RlpItem).bytes),
                accessList = decodeAccessList(rlp.element[8]),
                v = bigIntOrNull((rlp.element.getOrNull(9) as? RlpItem)?.bytes),
                r = bigIntOrNull((rlp.element.getOrNull(10) as? RlpItem)?.bytes),
                s = bigIntOrNull((rlp.element.getOrNull(11) as? RlpItem)?.bytes),
            )
        }

        @Throws(Throwable::class)
        fun decode(bytes: ByteArray): TransactionRequest {
            val firstByteInt = bytes[0].toUInt()
            if (firstByteInt >= 128u) return decodeLegacy(bytes)
            return when(firstByteInt) {
                1u -> decodeEIP2930(bytes.copyOfRange(1, bytes.size))
                2u -> decodeEIP1559(bytes.copyOfRange(1, bytes.size))
                else -> throw Error.DecodeInvalidTypeByte(firstByteInt)
            }
        }

        private fun bigIntOrNull(bytes: ByteArray?): BigInt? =
            bytes?.let { BigInt.from(it) }

        private fun bigIntOr0Null(bytes: ByteArray?): BigInt? =
            bytes?.let { nullIfZero(BigInt.from(it)) }

        private fun nullIfZero(value: BigInt) =
            if (value.isZero()) null else value
    }
}
