package com.sonsofcrypto.web3lib.contract

import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.extensions.isHexString
import com.sonsofcrypto.web3lib.utils.extensions.leftPadded
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.keccak256
import io.ktor.utils.io.core.*

class Interface {
    val fragments: List<Fragment>
    val errors: Map<String, ErrorFragment>
    val events: Map<String, EventFragment>
    val functions: Map<String, FunctionFragment>
    val deploy: ConstructorFragment?

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

    /** Find error by signature, selector/sighash, bare name if unambiguous */
    @Throws(Throwable::class)
    fun error(identifier: String): ErrorFragment {
        val id = identifier.trim().replace(" ", "")
        // By selector sighash (bytes4 hash) used by Solidity (eg 0x5cdc1d55)
        if (id.isHexString()) {
            errors.forEach {
                if (sigHashString(it.key) == id.lowercase()) return it.value
            }
            throw Error.ErrorNotFound(id)
        }
        // By name only (eg InsufficientBalance)
        if (!id.contains("(")) {
            val match = errors.filter { it.key.split("(").firstOrNull() == id }
            when (match.size) {
                0 -> throw Error.ErrorNotFound(id)
                1 -> return match.values.first()
                else -> throw Error.MultipleMatches(match.keys.toList())
            }
        }
        // By signature (eg InsufficientBalance(uint256,uint256))
        return errors[id] ?: throw Error.ErrorNotFound(id)
    }

    @Throws(Throwable::class)
    fun encodeDeploy(params: List<Param>, values: List<Any>) =
        abiCoder().encode(params, values)

    @Throws(Throwable::class)
    fun decodeError(fragment: ErrorFragment, data: ByteArray): List<Any> {
        val dataSigStr = data.copyOfRange(0, 4).toHexString(true)
        val fragSigStr = sigHashString(fragment.format())
        if (fragSigStr != dataSigStr)
            throw Error.FragDataSigMismatch(fragment, fragSigStr, dataSigStr)
        return decode(fragment.inputs, data.copyOfRange(4, data.size))
    }

    @Throws(Throwable::class)
    fun encodeError(
        fragment: ErrorFragment,
        values: List<Any> = emptyList()
    ): ByteArray = sigHash(fragment.format()) + encode(fragment.inputs, values)

    /** Decode the data for a function call (e.g. tx.data) */
    @Throws(Throwable::class)
    fun decodeFunction(fragment: FunctionFragment, data: ByteArray): List<Any> {
        val dataSigStr = data.copyOfRange(0, 4).toHexString(true)
        val fragSigStr = sigHashString(fragment.format())
        if (fragSigStr != dataSigStr)
            throw Error.FragDataSigMismatch(fragment, fragSigStr, dataSigStr)
        return decode(fragment.inputs, data.copyOfRange(4, data.size))
    }

    /** Encode the data for a function call (e.g. tx.data) */
    @Throws(Throwable::class)
    fun encodeFunction(
        fragment: FunctionFragment,
        values: List<Any> = emptyList()
    ): ByteArray = sigHash(fragment.format()) + encode(fragment.inputs, values)

    /** Decode the result from a function call (e.g. from eth_call) */
    @Throws(Throwable::class)
    fun decodeFunctionResult(
        fragment: FunctionFragment,
        data: ByteArray
    ): List<Any> {
        var args: List<Any> = emptyList()
        var error: Any? = null

        when (data.size % abiCoder().wordSize()) {
            0 -> try { return decode(fragment.output ?: emptyList(), data) }
                catch (err: Throwable) { error = err }
            4 -> {
                val selector = data.copyOfRange(0, 4).toHexString(true)
                val evmError = EVMError.error(selector)
                if (evmError != null) {
                    args = decode(evmError.inputs, data.copyOfRange(4, data.size))
                    error = evmError
                } else {
                    try {
                        val err = error(sigHashString(fragment.format()))
                        args = decode(err.inputs, data.copyOfRange(4, data.size))
                        error = err
                    } catch (err: Throwable) { error = err }
                }
            }
        }
        throw Error.Revert(error, args)
    }

    /** Encode the result for a function call (e.g. for eth_call) */
    @Throws(Throwable::class)
    fun encodeFunctionResult(
        fragment: FunctionFragment,
        values: List<Any> = emptyList()
    ): ByteArray = encode(fragment.output ?: emptyList(), values)

    /** Filter for the event with search criteria (e.g. for eth_filterLog) */
    @Throws(Throwable::class)
    fun encodeFilterTopic(
        fragment: EventFragment,
        values: List<Any?> = emptyList()
    ): List<ByteArray?> {
        if (values.size > fragment.inputs.size)
            throw Error.ArgCountMismatch(fragment, values)
        var topics: MutableList<ByteArray?> = mutableListOf()
        if (fragment.anonymous)
            topics.add(eventTopic(fragment))

        @Throws(Throwable::class)
        fun encodeTopic(param: Param, value: Any?): ByteArray {
            if (param.type == "string")
                return id(value as String)
            else if (param.type == "bytes")
                return keccak256(value as ByteArray)

            if (value == null)
                return ByteArray(32)

            var output = value
            if (param.type == "bool")
                 output = (if (value as Boolean) "0x01" else "0x00")
                     .hexStringToByteArray()

            if (Regex("^u?int").matchEntire(param.type) != null)
                output = encode(listOf(param), listOf(value))

            // Check addresses are valid ?? (I guess this would just throw)
            if (param.type == "address")
                encode(listOf(Param("","address", "address")), listOf(value))

            return (value as ByteArray).leftPadded(32)
        }

        for (i in 0..values.size) {
            val param = fragment.inputs[i]
            val value = values[i]
            val valueArray = values as? List<Any>
            if (!param.indexed) {
                if (value != null)
                    throw Error.CannotFilterUnIndexed(param.name, value)
                continue
            }
            if (value == null) {
                topics.add(null)
            } else if (param.baseType == "array" || param.baseType == "tuple") {

            } else if (valueArray != null) {
                topics.addAll(valueArray.map { encodeTopic(param, it) })
            } else {
                topics.add(encodeTopic(param, value))
            }
        }
        while (topics.size > 0 && topics.last() == null) topics.removeLast()
        return topics
    }

    /** Encode event log. Returns data, topics */
    @Throws(Throwable::class)
    fun encodeEventLog(
        fragment: EventFragment,
        values: List<Any> = emptyList()
    ): Pair<ByteArray, List<ByteArray>> {
        var topics: MutableList<ByteArray> = mutableListOf()
        var dataTypes: MutableList<Param> = mutableListOf()
        var dataValues: MutableList<Any> = mutableListOf()
        if (fragment.anonymous)
            topics.add(eventTopic(fragment))
        if (values.size != fragment.inputs.size)
            throw Error.ArgCountMismatch(fragment, values)
        fragment.inputs.forEachIndexed{ idx, param ->
            val value = values[idx]
            if (param.indexed) {
                when (param.type) {
                    "string" -> topics.add(id(value as String))
                    "bytes" -> topics.add(keccak256(value as ByteArray))
                    "tuple", "array" -> throw Error.CollectionLog(param, value)
                    else -> topics.add(encode(listOf(param), listOf(value)))
                }
            } else {
                dataTypes.add(param)
                dataValues.add(value)
            }
        }
        return Pair(encode(dataTypes, dataValues), topics)
    }

    /** Decode the result from a function call (e.g. from eth_call) */
    @Throws(Throwable::class)
    fun decodeEventLog(
        fragment: EventFragment,
        data: ByteArray,
        topics: List<ByteArray> = emptyList()
    ): List<Any> {
        if (topics.isNotEmpty() && !fragment.anonymous) {
            val topicHash = eventTopic(fragment)
            if (topics[0].toHexString(false) != topicHash.toHexString(false))
                throw Error.
        }
    }

    /** Override to provide custom coder */
    fun abiCoder(): AbiCoder = AbiCoder.default()

    /** Topic (the bytes32 hash) used by Solidity to identify an event from
     * signature (eg Transfer(address,uint256)) */
    fun eventTopic(sig: String): ByteArray = keccak256(sig.toByteArray())

    /** Topic (the bytes32 hash) used by Solidity to identify an event */
    fun eventTopic(event: EventFragment): ByteArray = eventTopic(event.format())

    private fun sigHash(sig: String): ByteArray = keccak256(sig.toByteArray())
        .copyOfRange(0, 4)

    private fun sigHashString(sig: String): String = sigHash(sig)
        .toHexString(true)

    private fun id(str: String): ByteArray = keccak256(str.toByteArray())

    @Throws(Throwable::class)
    private fun decode(params: List<Param>, data: ByteArray): List<Any> =
        abiCoder().decode(params, data)

    @Throws(Throwable::class)
    private fun encode(params: List<Param>, values: List<Any>): ByteArray =
        abiCoder().encode(params, values)

    /** Built in Solidity errors */
    sealed class EVMError(
        val selector: String,
        val signature: String,
        val inputs: List<Param>,
        val reason: Boolean = false,
    ) {
        object Error: EVMError("0x08c379a0", "Error(string)", errorParams, true)
        object Panic: EVMError("0x4e487b71", "Panic(uint256)", panicParams)

        fun name() = when(this) {
            is Error -> "Error"
            is Panic -> "Panic"
        }

        companion object {
            private val panicParams = listOf(Param("code", "uint256", "uint256"))
            private val errorParams = listOf(Param("message", "string", "string"))

            fun error(selector: String): EVMError? = when (selector) {
                Error.selector -> Error
                Panic.selector -> Panic
                else -> null
            }
        }
    }

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
        data class ErrorNotFound(val id: String) :
            Error("Error with identifier $id not found")
        data class MultipleMatches(val matches: List<String>):
            Error("Multiple matches found $matches")
        data class FragDataSigMismatch(
            val frag: Fragment,
            val fragSig: String,
            val dataSig: String,
        ): Error("Data sig $dataSig doesn't match fragment sig $fragSig, $frag")
        data class ArgCountMismatch(val frag: Fragment, val values: List<Any?>):
            Error("Fragment params values mismatch ${frag.format()}, $values")
        data class CannotFilterUnIndexed(val name: String, val value: Any):
            Error("Can not filter un-indexed $name, $value")
        data class FilteringWithCollection(val param: String, val value: Any):
            Error("Filtering on tuples or arrays not supported $param, $value")
        data class CollectionLog(val param: Param, val value: Any):
            Error("Tuples or arrays logs not supported $param, $value")
        data class Revert(val error: Any?, val args: List<Any>):
            Error(
                "Call revert $error, " +
                "${(error as? ErrorFragment)?.format() ?: ""}, " +
                "$args"
            )
        data class TopicFragmentMismatch(
            val frag: Fragment,
            val exp: String,
            val value: String
        ): Error("Fragment topic mismatch $frag, expected: $exp, got: $value")
    }
}
