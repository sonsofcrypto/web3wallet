package com.sonsofcrypto.web3lib.contract

import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.model.TransactionResponse
import com.sonsofcrypto.web3lib.signer.Signer
import com.sonsofcrypto.web3lib.types.Address

open class Contract{
    private var address: Address.HexString?
    private var provider: Provider?
    private var signer: Signer?
    private var params: List<Input> = emptyList()
    private var events: List<Event> = emptyList()
    private var methods: List<Method> = emptyList()

    @Throws(Throwable::class)
    constructor(
        abis: List<String>,
        address: Address.HexString? = null,
        provider: Provider? = null,
        signer: Signer? = null
    ) {
        this.address = address
        this.provider = provider
        this.signer = signer
        this.params = abis.map { abiDecodeParams(it) }.flatten()
        this.methods= abis.map { abiDecodeMethods(it) }.flatten()
        this.events = abis.map { abiDecodeEvents(it) }.flatten()
    }

    /** When changing provider, signer or address we always create copy to
     * avoid potential inconsistent state / security issues */
    fun connect(
        address: Address.HexString? = null,
        provider: Provider? = null,
        signer: Signer? = null,
    ): Contract {
        val copy = Contract(
            listOf(),
            address ?: this.address,
            provider ?: this.provider,
            signer ?: this.signer
        )
        copy.params = this.params
        copy.events = this.events
        copy.methods = this.methods
        return copy
    }

    /** List of contract parameters */
    fun params(): List<Input> = params

    /** List of events */
    fun events(): List<Event> = events

    /** Methods optionally filtered by stateMutability */
    @Throws(Throwable::class)
    fun methods(stateMutability: Method.StateMutability? = null): Method {
        if (stateMutability == null) return methods()
        TODO("Any to be replaced with contrate Method.Attribute type")
    }

    /** Find method by signature string, else throw eg `balance(address)` */
    @Throws(Throwable::class)
    fun method(string: String): Method {
        TODO("Throw if method not found, give hits similar method names")
    }

    /** Deploys smart contract, signer has to be unlocks & provider connected */
    @Throws(Throwable::class)
    suspend fun deploy(): Address.HexString {
        TODO("This will come later")
    }

    data class Method(
        val name: String,
        val inputs: List<Input>,
        val outputs: List<Any>,
        val stateMutability: StateMutability
    ) {

        /** Encode method signature, params and return data */
        fun callData(params: List<AbiEncodable>): ByteArray {
            TODO("Encode signature and parameters")
        }

        /** Call view only functions. Throws if provider is not connected */
        @Throws(Throwable::class)
        suspend fun call(params: List<AbiEncodable> = emptyList()): Any? {
            TODO("Encode signature and parameters")
            TODO("Figure out return type if any and decode it")
            // enconde abi
            // create transaction
            // val transaction = Transaction(to: ContratAddree, data: encodeData)
            // val resutl == provider?.call(trasaction)
            // parse to kotlin type
        }

        /** Contract state transition method call, provider needs to be
          * connected and signer needs to be unlocked, otherwise throws */
        @Throws(Throwable::class)
        suspend fun send(params: List<AbiEncodable> = emptyList()): TransactionResponse {
            TODO("Implement")
            // check if signer is unlocked
            // enconde abi
            // create transaction
            // val transaction = Transaction(to: ContratAddree, data: encodeData)
            // val resutl == provider?.call(trasaction)
            // parse to kotlin type
        }

        /** Decodes contract return data to type */
        @Throws(Throwable::class)
        fun decodeReturnData(data: ByteArray): Any? {
            TODO("Implement")
        }

        fun signature(): ByteArray {
            TODO("Implement")
        }

        enum class StateMutability {
            NONPAYABLE, PAYABLE, VIEW,
        }
    }

    data class Input(
        val name: String,
        val value: Any
    )

    data class Event(
        val name: String
    )

    private fun abiDecodeParams(abi: String): List<Input> {
        TODO("Implement")
    }

    private fun abiDecodeMethods(abi: String): List<Method> {
        TODO("Implement")
    }

    private fun abiDecodeEvents(abi: String): List<Event> {
        TODO("Implement")
    }

    private fun abiDecodeErrors(abi: String): List<Event> {
        TODO("Implement")
    }

    private fun abiDecodeStructs(abi: String): List<Event> {
        TODO("Implement")
    }
}

interface AbiEncodable {
    fun abiEncode(): ByteArray
}
