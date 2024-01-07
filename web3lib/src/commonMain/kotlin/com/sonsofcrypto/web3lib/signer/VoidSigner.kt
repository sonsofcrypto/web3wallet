package com.sonsofcrypto.web3lib.signer

import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.model.TransactionRequest
import com.sonsofcrypto.web3lib.types.Address

class VoidSigner(
    private val address: Address,
    provider: Provider? = null,
): Signer(provider) {

    override fun connect(provider: Provider): Signer =
        VoidSigner(this.address, provider)

    override suspend fun address(): Address = address

    @Throws(Throwable::class)
    override suspend fun signMessage(message: ByteArray): ByteArray =
        throw Error.VoidSign(address)

    @Throws(Throwable::class)
    override suspend fun signTransaction(
        transaction: TransactionRequest
    ): ByteArray = throw Error.VoidSign(address)

    sealed class Error(message: String? = null) : Exception(message) {
        data class VoidSign(val address: Address) :
            Error("Attempted to sign with void signer $address")
    }
}
