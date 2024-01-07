package com.sonsofcrypto.web3lib.signer

import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.model.TransactionRequest
import com.sonsofcrypto.web3lib.provider.model.encode
import com.sonsofcrypto.web3lib.provider.model.encodeEIP1559
import com.sonsofcrypto.web3lib.services.address.AddressService
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.types.Key
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.keccak256
import com.sonsofcrypto.web3lib.utils.sign

class KeySigner(
    private val key: Key,
    private val addressService: AddressService,
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
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun signTransaction(
        transaction: TransactionRequest
    ): ByteArray {
        val signature = sign(keccak256(transaction.encode()), key)
        return transaction.copy(
            r = BigInt.from(signature.copyOfRange(0, 32)),
            s = BigInt.from(signature.copyOfRange(32, 64)),
            v = BigInt.from(signature[64].toInt()),
        ).encode()
    }
}