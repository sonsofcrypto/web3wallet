package com.sonsofcrypto.web3lib_bip44

import com.sonsofcrypto.web3lib_crypto.*
import com.sonsofcrypto.web3lib_extensions.*
import kotlin.math.pow


class ExtKey(
    val version: Bip44.Version, // 4 Bytes
    val depth: Int,             // 1 Byte
    val fingerprint: ByteArray, // 4 Bytes
    val index: UInt,             // 4 Bytes
    val chainCode: ByteArray,   // 32 bytes
    val key: ByteArray,         // 33 bytes
    ) {

    /** Base58Check encoded xprv or xpub string */
    fun base58WithChecksumString(): String = bytes().encodeToBase58WithChecksum()

    /** Raw bytes **not** base58Check encoded*/
    fun bytes(): ByteArray {
        return version.hex() +
            depth.toByte() +
            fingerprint +
            index.toByteArray() +
            chainCode +
            if (isXprv()) ByteArray(1) + key else key
    }

    /** returns `Key` if `key` is private key else null */
    fun key(): Key? = if(isXprv()) Key(key) else null

    /** Is `ExtKey` is private or public key */
    fun isXprv(): Boolean = (key.size == 32)

//    companion object {
//
//        fun fromBytes(): ExtKey {
//            TODO("Implement and throw error in case parsing fails")
//            TODO("Throw error")
//        }
//    }
}

class Key(val prv: ByteArray) {

    fun pub(): ByteArray {
        TODO("Implement")
    }
}

class Bip44 {
    val seed: ByteArray
    val masterExtKey: ExtKey

    constructor(seed: ByteArray, version: Version) {
        val hmac = Crypto.hmacSha512("Bitcoin seed".encodeToByteArray(), seed)
        this.seed = seed
        this.masterExtKey = ExtKey(
            version,
            0,
            ByteArray(4),
            0.toUInt(),
            hmac.copyOfRange(32, 64), // R
            hmac.copyOfRange(0, 32)   // L
        )
        // TODO("Figure out what to do if key is not in range")

    }

//    def derive_ext_private_key(private_key, chain_code, child_number):
//    if child_number >= 2 ** 31:
//    # Generate a hardened key
//      data = b'\x00' + private_key.to_bytes(32, 'big')
//    else:
//    # Generate a non-hardened key
//       p = curve_point_from_int(private_key)
//       data = serialize_curve_point(p)
//
//    data += child_number.to_bytes(4, 'big')
//    hmac_bytes = hmac.new(chain_code, data, hashlib.sha512).digest()
//    L, R = hmac_bytes[:32], hmac_bytes[32:]
//    L_as_int = int.from_bytes(L, 'big')
//    child_private_key = (L_as_int + private_key) % SECP256k1_ORD
//    child_chain_code = R
//
//    return (child_private_key, child_chain_code)

    /** Derive key parsing path in format m/44'/60'/0'/0/0 */
    fun deviceChildKey(path: String): ExtKey? {
        val components = path.split("/")
        var parent = masterExtKey
        var depth = 0

        for (component in components.subList(1, components.size)) {
            val digitStr = component.filter { it.isDigit() }
            val hardened = component.length != digitStr.length
            val idx = digitStr.toUInt(10) +
                if (hardened) 2.toDouble().pow(31).toUInt() else 0.toUInt()

            println("=== $component ${digitStr.toUInt()} ${idx.toUInt()}")

            // 	if secretKeyNum.Cmp(btcec.S256().N) >= 0 || secretKeyNum.Sign() == 0 {
            //		return nil, ErrUnusableSeed
            //	}
            0.toLong()
        }

        return null
    }

    fun derivePrivateKey(privateKey: ByteArray, chainCode: ByteArray, childNumber: UInt) {
        val data = if (childNumber >= 2.toDouble().pow(31).toUInt()) {
            ByteArray(1) + privateKey
        } else {
            ByteArray(0)
        }
    }

    fun extendPublicKey() {

    }


    enum class Version {
        MAINNETPRV, MAINNETPUB, TESTNETPRV, TESTNETPUB;

        fun hex(): ByteArray {
            return when (this) {
                MAINNETPRV -> "0488ade4".hexStringToByteArray()
                MAINNETPUB -> "0488b21e".hexStringToByteArray()
                TESTNETPRV -> "04358394".hexStringToByteArray()
                TESTNETPUB -> "043587cf".hexStringToByteArray()
            }
        }
    }
}


