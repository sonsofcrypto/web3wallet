package com.sonsofcrypto.web3lib.contract

import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

private val json = Json {
    encodeDefaults = false
    isLenient = true
    ignoreUnknownKeys = true
    coerceInputValues = true
    allowStructuredMapKeys = true
    useAlternativeNames = false
    prettyPrint = true
    useArrayPolymorphism = true
    explicitNulls = false
}

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
        val jsonFrags = json.decodeFromString<List<JsonFragment>>(jsonString)
        val fragments = jsonFrags.map {
            when (it.type) {
                "function" -> FunctionFragment.from(it)
                "event" -> EventFragment.from(it)
                "constructor" -> ConstructorFragment.from(it)
                "error" -> ErrorFragment.from(it)
                "fallback", "receive" -> null
                else -> null
            }
        }.filterNotNull()
        this.fragments = fragments
        this.errors = fragments
            .filter { it is ErrorFragment }
            .map { (it.name to it) }
            .toMap() as Map<String, ErrorFragment>
        this.events = fragments
            .filter { it is EventFragment }
            .map { (it.name to it) }
            .toMap() as Map<String, EventFragment>
        this.functions = fragments
            .filter { it is FunctionFragment && it !is ConstructorFragment }
            .map { (it.name to it) }
            .toMap() as Map<String, FunctionFragment>
        this.deploy = fragments
            .first { it is ConstructorFragment } as? ConstructorFragment
    }

    @Serializable
    data class JsonFragmentType(
        val name: String? = null,
        val indexed: Boolean? = null,
        val type: String? = null,
        val internalType: String? = null,
        val components: List<JsonFragmentType>? = null,
    )

    @Serializable
    data class JsonFragment(
        val name: String?,
        val type: String?,
        val anonymous: Boolean?,
        val payable: Boolean?,
        val constant: Boolean?,
        val stateMutability: String?,
        val inputs: List<JsonFragmentType>?,
        val output: List<JsonFragmentType>?
    )

    open class Fragment(
        val type: String,
        val name: String,
        val inputs: List<Param>
    ) {
        override fun toString(): String = "Fragment(" +
            "type=$type, " +
            "name=$name, " +
            "inputs=$inputs" +
            ")"
    }

    class EventFragment : Fragment {
        val anonymous: Boolean

        constructor(
            type: String,
            name: String,
            inputs: List<Param>,
            anonymous: Boolean
        ) : super(type, name, inputs) {
            this.anonymous = anonymous
        }

        override fun toString(): String = "EventFragment(" +
            "type=$type," +
            "name=$name," +
            "inputs=$inputs," +
            "anonymous=$anonymous" +
            ")"

        companion object {
            fun from(jsonFrag: JsonFragment): EventFragment {
                if (jsonFrag.type == null) throw Error.TypeMismatch(jsonFrag.type)
                return EventFragment(
                    type = jsonFrag.type,
                    name = verifiedIdentifier(jsonFrag.name),
                    inputs = Param.from(jsonFrag.inputs) ?: emptyList(),
                    anonymous = jsonFrag.anonymous ?: false,
                )
            }
        }
    }

    open class ConstructorFragment : Fragment {
        val stateMutability: String
        val payable: Boolean

        constructor(
            type: String,
            name: String,
            inputs: List<Param>,
            stateMutability: String,
            payable: Boolean
        ) : super(type, name, inputs) {
            this.stateMutability = stateMutability
            this.payable = payable
        }

        override fun toString(): String = "ConstructorFragment(" +
            "type=$type, " +
            "name=$name, " +
            "inputs=$inputs, " +
            "stateMutability=$stateMutability, " +
            "payable=$payable" +
            ")"

        companion object {
            @Throws(Throwable::class)
            fun from(jsonFrag: JsonFragment): ConstructorFragment {
                if (jsonFrag.type == null) throw Error.TypeMismatch(jsonFrag.type)
                val state = verifiedState(jsonFrag)
                return ConstructorFragment(
                    type = jsonFrag.type,
                    name = "",
                    inputs = Param.from(jsonFrag.inputs) ?: emptyList(),
                    stateMutability = state.stateMutability,
                    payable = state.payable,
                )
            }
        }
    }

    class FunctionFragment : ConstructorFragment {
        val constant: Boolean
        val output: List<Param>?

        constructor(
            type: String,
            name: String,
            inputs: List<Param>,
            stateMutability: String,
            payable: Boolean,
            constant: Boolean,
            output: List<Param>?,
        ) : super(type, name, inputs, stateMutability, payable) {
            this.constant = constant
            this.output = output
        }

        override fun toString(): String = "FunctionFragment(" +
            "type=$type, " +
            "name=$name, " +
            "inputs=$inputs, " +
            "stateMutability=$stateMutability, " +
            "payable=$payable, " +
            "constant=$constant, " +
            "output=$output" +
            ")"

        companion object {
            @Throws(Throwable::class)
            fun from(jsonFrag: JsonFragment): FunctionFragment {
                if (jsonFrag.type == null) throw Error.TypeMismatch(jsonFrag.type)
                val state = verifiedState(jsonFrag)
                return FunctionFragment(
                    type = jsonFrag.type,
                    name = verifiedIdentifier(jsonFrag.name),
                    inputs = Param.from(jsonFrag.inputs) ?: emptyList(),
                    stateMutability = state.stateMutability,
                    payable = state.payable,
                    constant = state.constant,
                    output = Param.from(jsonFrag.output) ?: emptyList(),
                )
            }
        }
    }

    class ErrorFragment(
        type: String,
        name: String,
        inputs: List<Param>,
    ) : Fragment(type, name, inputs) {
        override fun toString(): String = "ErrorFragment(" +
            "type=$type, " +
            "name=$name, " +
            "inputs=$inputs" +
            ")"

        companion object {
            @Throws(Throwable::class)
            fun from(jsonFrag: JsonFragment): ErrorFragment {
                if (jsonFrag.type == null) throw Error.TypeMismatch(jsonFrag.type)
                return ErrorFragment(
                    type = jsonFrag.type,
                    name = verifiedIdentifier(jsonFrag.name),
                    inputs = Param.from(jsonFrag.inputs) ?: emptyList(),
                )
            }
        }
    }

    data class Param(
        /** The local name of the parameter (of null if unbound) */
        val name: String,
        /** Fully qualified type e.g. address, tuple(address), uint256[3][]  */
        val type: String,
        /** The base type (e.g. "address", "tuple", "array") */
        val baseType: String,
        /** Indexable Paramters ONLY (otherwise null) */
        val indexed: Boolean,
        /** Tuples ONLY: (otherwise null)
         *  - sub-components */
        val components: List<Param>?,
        /** Arrays ONLY: (otherwise null)
         *  - length of the array (-1 for dynamic length)
         *  - child type */
        val arrayLength: Int?,
        var arrayChildren: Param?,
    ) {
        companion object {
            fun from(jsonFrag: JsonFragmentType): Param? {
                val match = Regex(ARRAY_PATTERN).matchEntire(jsonFrag.type ?: "")
                var arrayLength: Int? = null
                var arrayChildren: Param? = null
                var baseType: String = if (jsonFrag.components != null) "tuple"
                    else jsonFrag.type ?: ""
                if (match != null) {
                    baseType = "array"
                    arrayLength = match.groupValues.get(2)?.toIntOrNull() ?: -1
                    arrayChildren = from(
                        JsonFragmentType(
                            type = match.groupValues[1],
                            components = jsonFrag.components
                        )
                    )
                }
                return Param(
                    name = jsonFrag.name ?: "",
                    type = verifiedType(jsonFrag.type ?: ""),
                    baseType = baseType,
                    indexed = jsonFrag.indexed ?: false,
                    components = from(jsonFrag.components),
                    arrayLength = arrayLength,
                    arrayChildren = arrayChildren,
                )
            }

            fun from(jsonFrags: List<JsonFragmentType>?): List<Param>? = jsonFrags
                ?.map { from(it) }
                ?.filterNotNull()
        }
    }

    /** Errors */
    sealed class Error(
        message: String? = null,
        cause: Throwable? = null
    ) : Exception(message, cause) {

        constructor(cause: Throwable) : this(null, cause)

        /** See: https://github.com/ethereum/solidity/blob/1f8f1a3db93a548d0555e3e14cfc55a10e25b60e/docs/grammar/SolidityLexer.g4#L234 */
        data class InvalidIdentifier(val value: String?) :
            Error("Invalid identifier $value")
        /** State constancy mutability error*/
        data class InvalidMutability(val mutability: String?) :
            Error("Cannot have constant function with mutability $mutability")
        /** State constancy payable error*/
        data class InvalidPayable(val mutability: String?) :
            Error("Cannot have payable function with mutability $mutability")
        /** Unable to determine state mutability */
        data class UndeterminedStateMutability(val value: Any?) :
            Error("Unable to determine stateMutability $value")
        /** Creating fragment subclass with invalid type  */
        data class TypeMismatch(val type: String?) :
            Error("Fragment type mismatch $type")
    }
}

private const val ARRAY_PATTERN = "^(.*)\\[([0-9]*)\\]\$"
private const val ID_PATTERN = "^[a-zA-Z\$_][a-zA-Z0-9\$_]*\$"


private fun verifiedType(type: String): String {
    if (Regex("^uint(\$|[^1-9])").matchEntire(type) != null) {
        return "uint256" + type.substring(4)
    }
    if (Regex("^uint(\$|[^1-9])").matchEntire(type) != null) {
        return "int256" + type.substring(3)
    }
    return type
}

/** See: https://github.com/ethereum/solidity/blob/1f8f1a3db93a548d0555e3e14cfc55a10e25b60e/docs/grammar/SolidityLexer.g4#L234 */
@Throws(Throwable::class)
private fun verifiedIdentifier(value: String?): String {
    if (value == null || Regex(ID_PATTERN).matchEntire(value) == null)
        throw Interface.Error.InvalidIdentifier(value)
    return value
}

data class StateOutput(
    val constant: Boolean,
    val payable: Boolean,
    val stateMutability: String,
)

@Throws(Throwable::class)
private fun verifiedState(value: Interface.JsonFragment): StateOutput {
    var constant = false
    var payable = true
    var stateMutability = "payable"

    if (value.stateMutability != null) {
        stateMutability = value.stateMutability
        constant = stateMutability == "view" || stateMutability == "pure"
        if (value.constant != null && value.constant != constant)
            throw Interface.Error.InvalidMutability(value.stateMutability)
        payable = stateMutability == "payable"
        if (value.payable != null && value.payable != payable)
            throw Interface.Error.InvalidPayable(value.stateMutability)
    } else if (value.payable != null) {
        payable = value.payable
        if (value.constant == null && !payable && value.type != "constructor")
            throw Interface.Error.UndeterminedStateMutability(value)
        constant = value.constant ?: constant
        if (constant)
            stateMutability = "view"
        else
            stateMutability = if (payable) "payable" else "nonpayable"
        if (payable && constant)
            throw Interface.Error.InvalidMutability(value.stateMutability)
    } else if (value.constant != null) {
        constant = value.constant
        payable = !constant
        stateMutability = if (constant) "view" else "payable"
    } else if (value.type != "constructor") {
        throw Interface.Error.UndeterminedStateMutability(value)
    }

    return StateOutput(constant, payable, stateMutability)
}
