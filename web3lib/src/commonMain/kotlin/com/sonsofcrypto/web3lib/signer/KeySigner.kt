package com.sonsofcrypto.web3lib.signer

import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.model.TransactionRequest
import com.sonsofcrypto.web3lib.services.address.AddressService
import com.sonsofcrypto.web3lib.services.address.DefaultAddressService
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.types.Key
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.keccak256
import com.sonsofcrypto.web3lib.utils.Signature
import com.sonsofcrypto.web3lib.utils.extensions.toHexString

class KeySigner(
    private val key: Key,
    private val addressService: AddressService = DefaultAddressService(),
    provider: Provider? = null
): Signer(provider) {

    override fun connect(provider: Provider): Signer =
        KeySigner(key, addressService, provider)

    @Throws(Throwable::class)
    override suspend fun address(): Address = Address.HexString(
        addressService.addressFromPrivKeyBytes(key)
    )

    @Throws(Throwable::class)
    override suspend fun signMessage(message: ByteArray): ByteArray {
        val payload = "\u0019Ethereum Signed Message:\n${message.size}"
            .encodeToByteArray() + message
        val sig = Signature.make(keccak256(payload), key)
        return sig.copy(v = sig.v.add(BigInt.from(27))).toByteArray()
    }

    @Throws(Throwable::class)
    override suspend fun signTransaction(
        transaction: TransactionRequest
    ): ByteArray {
        val sig = Signature.make(keccak256(transaction.encode()), key)
        return transaction.copy(r = sig.r, s = sig.s, v = sig.v).encode()
    }
}