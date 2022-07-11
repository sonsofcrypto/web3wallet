package com.sonsofcrypto.web3lib_core

import com.sonsofcrypto.web3lib_utils.*

private const val firstHardenedIdx: UInt = 2147483648u

/** Generates master key from seed. Validates that key is compliant */
class Bip44 {
    val seed: ByteArray
    val masterExtKey: ExtKey

    /** Generates master key from seed. Validates that key is compliant */
    @Throws(Error::class) constructor(seed: ByteArray, version: ExtKey.Version) {
        val hmac = hmacSha512("Bitcoin seed".encodeToByteArray(), seed)
        this.seed = seed
        this.masterExtKey = ExtKey(
            version,
            0u,
            ByteArray(4),
            0u,
            hmac.copyOfRange(32, 64), // R
            hmac.copyOfRange(0, 32)   // L
        )
        masterExtKey.validate()
    }

    /** Derive key parsing path in format m/44'/60'/0'/0/0 */
    @Throws(Error::class) fun deviceChildKey(path: String): ExtKey {
        val components = path.split("/")
        var parent = masterExtKey
        var retryCnt = 0

        for (component in components.subList(1, components.size)) {
            val digitStr = component.filter { it.isDigit() }
            val hardened = component.length != digitStr.length
            val idx = digitStr.toUInt(10) + if (hardened) firstHardenedIdx else 0.toUInt()
            try {
                val child = parent.deriveChildKey(parent, idx)
                parent = child
            } catch (e: Error) {
                retryCnt += 1
                if (retryCnt >= 5) {
                    throw e
                }
            }
        }
        parent.validate()
        return parent
    }
}
