package com.sonsofcrypto.web3lib.services.address

import com.sonsofcrypto.web3lib.types.ExtKey
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.keccak256

interface AddressService {
    /** Address for default network (Ethereum) */
    fun address(pubKey: ExtKey): String
    fun byteAddress(pubKey: ExtKey): ByteArray

    companion object
}

fun AddressService.Companion.defaultDerivationPath(): String
    = "m/44'/60'/0'/0/0"

class DefaultAddressService: AddressService {

    override fun address(pubKey: ExtKey): String
        = byteAddress(pubKey).toHexString(true)

    override fun byteAddress(pubKey: ExtKey): ByteArray {
        val uncompressed = pubKey.uncompressedPub()
        val bytes = uncompressed.copyOfRange(1, uncompressed.size) // (strip prefix 0x04)
        return keccak256(bytes).copyOfRange(12, 32)
    }
}

