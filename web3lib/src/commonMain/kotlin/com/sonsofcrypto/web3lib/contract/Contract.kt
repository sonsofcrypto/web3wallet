package com.sonsofcrypto.web3lib.contract

import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.model.TransactionResponse
import com.sonsofcrypto.web3lib.signer.Signer
import com.sonsofcrypto.web3lib.types.Address

data class Contract(
    private var address: Address.HexString? = null,
    private var provider: Provider? = null,
    private var signer: Signer? = null,
) {
    private var params: List<Param> = emptyList()
    private var methods: List<Method> = emptyList()

    constructor(
        abis: List<String>,
        address: Address.HexString? = null,
        provider: Provider? = null,
        signer: Signer? = null
    ) : this(address, provider, signer) {
        this.params = abis.map { abiDecodeParams(it) }.flatten()
        this.methods= abis.map { abiDecodeMethods(it) }.flatten()
    }

    /** List of contract parameters */
    fun params(): List<Param> = params

    /** Methods optionally filtered by methods attributes */
    fun methods(attrs: List<Any>? = null): Method {
        if (attrs == null) return methods()
        TODO("Any to be replaced with contrate Method.Attribute type")
    }

    /** Find method by signature string, else throw eg `balance(address)` */
    fun method(string: String): Method {
        TODO("Throw if method not found, give hits similar method names")
    }

    /** When changing provider, signer or address we always create copy to
     * avoid potential inconsistent state / security issues */
    fun connect(
        address: Address.HexString? = null,
        provider: Provider? = null,
        signer: Signer? = null,
    ): Contract = this.copy(
        address ?: this.address,
        provider ?: this.provider,
        signer ?: this.signer
    )

    data class Method(
        val name: String,
        val params: List<Param>,
        val attributes: List<Any> // This needs to be concrete type
    ) {

        /** Encode method signature, params and return data */
        fun callData(params: List<AbiEncodable>): ByteArray {
            TODO("Encode signature and parameters")
        }

        /** Call view only functions. Throws if provider is not connected */
        @Throws(Throwable::class)
        fun call(params: List<AbiEncodable>): Any? {
            TODO("Encode signature and parameters")
            TODO("Figure out return type if any and decode it")
        }

        /** Contract state transition method call, provider needs to be
          * connected and signer needs to be unlocked, otherwise throws */
        @Throws(Throwable::class)
        fun send(params: List<AbiEncodable>): TransactionResponse {
            TODO("Implement")
        }

        /** Decodes contract return data to type */
        @Throws(Throwable::class)
        fun decodeReturnData(data: ByteArray): Any? {
            TODO("Implement")
        }

        fun signature(): ByteArray {
            TODO("Implement")
        }
    }

    data class Param(
        val name: String,
        // val type: ParamType,
        val value: Any
    )

    private fun abiDecodeParams(abi: String): List<Param> {
        TODO("Implement")
    }

    private fun abiDecodeMethods(abi: String): List<Method> {
        TODO("Implement")
    }
}

interface AbiEncodable {
    fun abiEncode(): ByteArray
}
