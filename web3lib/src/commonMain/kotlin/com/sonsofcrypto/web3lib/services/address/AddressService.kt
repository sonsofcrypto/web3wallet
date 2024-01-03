package com.sonsofcrypto.web3lib.services.address

import com.sonsofcrypto.web3lib.types.ExtKey
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.Curve
import com.sonsofcrypto.web3lib.utils.compressedPubKey
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.keccak256
import com.sonsofcrypto.web3lib.utils.upcompressedPubKey

interface AddressService {
    /** Address for default network (Ethereum) */
    fun address(pubKey: ExtKey): String
    fun byteAddress(pubKey: ExtKey): ByteArray

    fun addressFromPrivKeyBytes(privKey: ByteArray): String
    fun byteAddressFromPrivKeyBytes(privKey: ByteArray): ByteArray

    fun isValid(address: String, network: Network = Network.ethereum()): Boolean

    companion object
}

class DefaultAddressService: AddressService {

    override fun address(pubKey: ExtKey): String =
        byteAddress(pubKey).toHexString(true)

    override fun byteAddress(pubKey: ExtKey): ByteArray {
        val uncompressed = pubKey.uncompressedPub()
        val bytes = uncompressed.copyOfRange(1, uncompressed.size) // (strip prefix 0x04)
        return keccak256(bytes).copyOfRange(12, 32)
    }

    override fun addressFromPrivKeyBytes(privKey: ByteArray): String =
        byteAddressFromPrivKeyBytes(privKey).toHexString(true)

    override fun byteAddressFromPrivKeyBytes(privKey: ByteArray): ByteArray {
        val uncompressed = upcompressedPubKey(
            Curve.SECP256K1,
            compressedPubKey(Curve.SECP256K1, privKey)
        )
        val bytes = uncompressed.copyOfRange(1, uncompressed.size) // (strip prefix 0x04)
        return keccak256(bytes).copyOfRange(12, 32)
    }

    override fun isValid(address: String, network: Network): Boolean {
        // TODO: Validate address
        return true
    }
}

