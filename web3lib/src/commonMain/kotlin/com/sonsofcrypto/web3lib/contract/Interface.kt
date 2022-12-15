package com.sonsofcrypto.web3lib.contract

import com.sonsofcrypto.web3lib.utils.extensions.isHexString
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.keccak256
import io.ktor.utils.io.core.*

class Interface {
    val fragments: List<Fragment>
    val errors: Map<String, ErrorFragment>
    val events: Map<String, EventFragment>
    val functions: Map<String, FunctionFragment>
//    private val structs: { [ name: string ]: any }
    val deploy: ConstructorFragment?
//    private val _abiCoder: AbiCoder

    @Throws(Throwable::class)
    constructor(jsonString: String) {
        var errors = mutableListOf<ErrorFragment>()
        var events = mutableListOf<EventFragment>()
        var functions = mutableListOf<FunctionFragment>()
        var deploy: ConstructorFragment? = null
        this.fragments = fragmentsFrom(jsonString).map {
            when (it.type) {
                "function" -> FunctionFragment.from(it)
                "event" -> EventFragment.from(it)
                "constructor" -> ConstructorFragment.from(it)
                "error" -> ErrorFragment.from(it)
                "fallback", "receive" -> null
                else -> null
            }
        }.filterNotNull()
        fragments.forEach {
            when (it) {
                is ErrorFragment -> errors.add(it)
                is EventFragment -> events.add(it)
                is ConstructorFragment -> deploy = it
                is FunctionFragment -> {
                    if (it !is ConstructorFragment) functions.add(it)
                }
                else -> Unit
            }
        }
        this.errors = errors.map { (it.name to it) }.toMap() as Map<String, ErrorFragment>
        this.events = events.map { (it.name to it) }.toMap()
        this.functions = functions.map { (it.name to it) }.toMap()
        this.deploy = deploy
    }

    /** Find function by signature, selector/sighash, bare name if unambiguous */
    @Throws(Throwable::class)
    fun function(identifier: String): FunctionFragment {
        val id = identifier.trim().replace(" ", "")
        // By selector sighash (bytes4 hash) used by Solidity (eg 0xa9059cbb)
        if (id.isHexString()) {
            functions.forEach {
                if (sigHashString(it.key) == id.lowercase()) return it.value
            }
            throw Error.FunctionNotFound(id)
        }
        // By name only (eg transfer)
        if (!id.contains("(")) {
            val match = functions.filter { it.key.split("(").firstOrNull() == id }
            when (match.size) {
                0 -> throw Error.FunctionNotFound(id)
                1 -> return match.values.first()
                else -> throw Error.MultipleMatches(match.keys.toList())
            }
        }
        // By signature (eg transfer(address,uint256))
        return functions[id] ?: throw Error.FunctionNotFound(id)
    }

    /** Find event by signature, topic or bare name if unambiguous */
    @Throws(Throwable::class)
    fun event(identifier: String): EventFragment {
        val id = identifier.trim().replace(" ", "")
        // By topic (bytes32 hash) used by Solidity (eg 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef)
        if (id.isHexString()) {
            events.forEach {
                if (eventTopic(it.value).toHexString() == id) return it.value
            }
            throw Error.EventNotFound(id)
        }
        // By name only (eg Transfer)
        if (!id.contains("(")) {
            val match = events.filter { it.key.split("(").firstOrNull() == id }
            when (match.size) {
                0 -> throw Error.EventNotFound(id)
                1 -> return match.values.first()
                else -> throw Error.MultipleMatches(match.keys.toList())
            }
        }
        // By signature (eg Transfer(address,address,uint256))
        return events[id] ?: throw Error.EventNotFound(id)
    }

    @Throws(Throwable::class)
    fun decodeEventLogs(
        event: EventFragment,
        data: ByteArray,
        topics: List<String>
    ) {
        TODO("Implement")
    }

    /** Topic (the bytes32 hash) used by Solidity to identify an event from
     * signature (eg Transfer(address,uint256)) */
    fun eventTopic(sig: String): ByteArray = keccak256(sig.toByteArray())

    /** Topic (the bytes32 hash) used by Solidity to identify an event */
    fun eventTopic(event: EventFragment): ByteArray = eventTopic(event.format())

    private fun sigHash(sig: String): ByteArray = keccak256(sig.toByteArray())
        .copyOfRange(0, 4)

    private fun sigHashString(sig: String): String = sigHash(sig)
        .toHexString(true)

    /** Errors */
    sealed class Error(
        message: String? = null,
        cause: Throwable? = null
    ) : Exception(message, cause) {

        constructor(cause: Throwable) : this(null, cause)

        data class EventNotFound(val id: String) :
            Error("Event with identifier $id not found")
        data class FunctionNotFound(val id: String) :
            Error("Function with identifier $id not found")
        data class MultipleMatches(val matches: List<String>):
            Error("Multiple matches found $matches")
    }
}
