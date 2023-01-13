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

@Throws(Throwable::class)
fun fragmentsFrom(jsonString: String): List<JsonFragment> = json
    .decodeFromString<List<JsonFragment>>(jsonString)

@Serializable
data class JsonFragmentType(
    var name: String? = null,
    var indexed: Boolean? = null,
    var type: String? = null,
    var internalType: String? = null,
    var components: List<JsonFragmentType>? = null,
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

    enum class Format {
        SIGNATURE, STRING
    }

    open fun format(format: Format = Format.SIGNATURE): String = when(format) {
        Format.STRING -> "Fragment(type=$type, name=$name, inputs=$inputs)"
        Format.SIGNATURE -> name + inputs.map { it.format(format) }
            .joinToString(prefix = "(", postfix = ")")
    }

    override fun toString(): String = this.format(Format.STRING)
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

    override fun format(format: Format): String = when (format) {
        Format.SIGNATURE -> super.format(format)
        Format.STRING -> "EventFragment(" +
            "type=$type, " +
            "name=$name, " +
            "inputs=$inputs, " +
            "anonymous=$anonymous)"
    }

    companion object {
        @Throws(Throwable::class)
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

    override fun format(format: Format): String = when (format) {
        Format.SIGNATURE -> super.format(format)
        Format.STRING -> "ConstructorFragment(" +
            "type=$type, " +
            "name=$name, " +
            "inputs=$inputs, " +
            "stateMutability=$stateMutability, " +
            "payable=$payable)"
    }

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

    override fun format(format: Format): String = when (format) {
        Format.SIGNATURE -> super.format(format)
        Format.STRING -> "FunctionFragment(" +
            "type=$type, " +
            "name=$name, " +
            "inputs=$inputs, " +
            "stateMutability=$stateMutability, " +
            "payable=$payable, " +
            "constant=$constant, " +
            "output=$output)"
    }

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

    override fun format(format: Format): String = when (format) {
        Format.SIGNATURE -> super.format(format)
        Format.STRING -> "ErrorFragment(type=$type, name=$name, inputs=$inputs)"
    }

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
    val indexed: Boolean = false,
    /** Tuples ONLY: (otherwise null)
     *  - sub-components */
    val components: List<Param>? = null,
    /** Arrays ONLY: (otherwise null)
     *  - length of the array (-1 for dynamic length)
     *  - child type */
    val arrayLength: Int? = null,
    var arrayChildren: Param? = null,
) {

    interface SourceObject {
        val type: String?
        val name: String?
        val indexed: Boolean?
        val components: List<SourceObject>?
    }

    fun format(format: Fragment.Format): String = when(format) {
        Fragment.Format.STRING -> "Param(" +
            "name=$name, " +
            "type=$type, " +
            "baseType=$baseType, " +
            "indexed=$indexed, " +
            "components=$components, " +
            "arrayLength=$arrayLength, " +
            "arrayChildren=$arrayChildren)" +
            ")"
        Fragment.Format.SIGNATURE -> when(baseType) {
            "array" -> {
                val length = if ((arrayLength ?: -1) < 0) "" else "$arrayLength"
                (this.arrayChildren?.format(format) ?: "") + "[$length]"
            }
            "tuple" -> components?.map { it.format(format) }
                ?.joinToString(prefix = "(", postfix = ")")
                ?: "()"
            else -> type
        }
    }

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

        fun from(string: String, allowIndexed: Boolean = false): Param? =
            from(parseParam(string, allowIndexed).toJsonFragmentType())

        @Throws(Throwable::class)
        fun fromStringParams(
            value: String,
            allowIndexed: Boolean = false
        ): List<Param?> = splitNesting(value).map { from(it, allowIndexed) }
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
    /** Failed to parse fragment from string  */
    data class FromString(val string: String?) :
        Error("Failed to parse fragment from string $string")
    /** Attempted unsupported operation */
    data class UnsupportedOp(val string: String):
        Error("Unsupported operation $string")
    /** Errors during parsing params from string */
    data class UnexpectedChar(val str: String, val idx: Int, val char: String):
        Error("Unexpected char $char at idx $idx in $str during parsing node")
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
        throw Error.InvalidIdentifier(value)
    return value
}

data class StateOutput(
    val constant: Boolean,
    val payable: Boolean,
    val stateMutability: String,
)

@Throws(Throwable::class)
private fun verifiedState(value: JsonFragment): StateOutput {
    var constant = false
    var payable = true
    var stateMutability = "payable"

    if (value.stateMutability != null) {
        stateMutability = value.stateMutability
        constant = stateMutability == "view" || stateMutability == "pure"
        if (value.constant != null && value.constant != constant)
            throw Error.InvalidMutability(value.stateMutability)
        payable = stateMutability == "payable"
        if (value.payable != null && value.payable != payable)
            throw Error.InvalidPayable(value.stateMutability)
    } else if (value.payable != null) {
        payable = value.payable
        if (value.constant == null && !payable && value.type != "constructor")
            throw Error.UndeterminedStateMutability(value)
        constant = value.constant ?: constant
        if (constant)
            stateMutability = "view"
        else
            stateMutability = if (payable) "payable" else "nonpayable"
        if (payable && constant)
            throw Error.InvalidMutability(value.stateMutability)
    } else if (value.constant != null) {
        constant = value.constant
        payable = !constant
        stateMutability = if (constant) "view" else "payable"
    } else if (value.type != "constructor") {
        throw Error.UndeterminedStateMutability(value)
    }

    return StateOutput(constant, payable, stateMutability)
}

private val modifiersBytes = listOf("calldata", "mememory", "storage")
private val modifiersNest = listOf("calldata", "mememory")

@Throws(Throwable::class)
private fun checkModifier(type: String, name: String): Boolean {
    if (type == "bytes" || type == "string") {
        if (modifiersBytes.contains(name))
            return true
    } else if (type == "address") {
        if (name == "payable")
            return true
    } else if (type.indexOf("[") >= 0 || type == "tuple") {
        if (modifiersNest.contains(name))
            return true
    }
    if(modifiersNest.contains(name) || name == "payable") {
        throw Error("Invalid modifier name $name")
    }
    return false
}

private data class ParseNode(
    var parent: ParseNode? = null,
    var type: String? = null,
    var name: String? = null,
    var state: State? = null,
    var indexed: Boolean? = null,
    var components: List<ParseNode>? = null,
) {
    data class State(
        var allowArray: Boolean = false,
        var allowName: Boolean = false,
        var allowParams: Boolean = false,
        var allowType: Boolean = false,
        var readArray: Boolean = false,
    )

    fun toJsonFragmentType(): JsonFragmentType = JsonFragmentType(
        name = this.name,
        indexed = this.indexed,
        type = this.type,
        components = this.components?.map { it.toJsonFragmentType() },
    )
}

@Throws(Throwable::class)
private fun splitNesting(value: String): List<String> {
    var value = value.trim()
    var result: MutableList<String> = mutableListOf()
    var accum = ""
    var depth = 0
    for (i in 0..value.length) {
        val c = value[i].toString()
        if (c == "," && depth == 0) {
            result.add(accum)
            accum = ""
        } else {
            accum += c
            if (c == "(") {
                depth += 1
            } else if (c == ")") {
                depth -= 1
                if (depth == -1) {
                    throw Error("unbalanced parenthesis $value")
                }
            }
        }
    }
    if (accum.isNotEmpty())
        result.add(accum)
    return result
}

@Throws(Throwable::class)
private fun parseParam(
    string: String,
    allowIndexed: Boolean = false
): ParseNode {
    val originalParam = string
    var param = string

    param = param.replace("\\s".toRegex(), " ")

    fun newNode(parent: ParseNode?): ParseNode {
        val stt = ParseNode.State(allowType = true)
        val node = ParseNode(type = "", name = "", parent = parent, state = stt)
        if (allowIndexed)
            node.indexed = false
        return node
    }

    val state = ParseNode.State(allowType = true)
    var parent = ParseNode(type = "", name = "", state = state)
    var node = parent

    for (i in 0..param.length) {
        val c = param[i].toString()
        when (c) {
            "(" -> {
                if (node.state?.allowType == true && node.type == "") {
                    node.type = "tuple"
                } else if (node.state?.allowParams != true) {
                    throw Error.UnexpectedChar(param, i, c)
                }
                node.state?.allowType = false
                node.type = verifiedType(node.type ?: "")
                node.components = listOf(node)
                node = node.components?.get(0) ?: node
            }
            ")" -> {
                node.state = null
                if (node.name == "indexed") {
                    if (!allowIndexed)
                        throw Error.UnexpectedChar(param, i, c)
                    node.indexed = true
                    node.name = ""
                }
                if (checkModifier(node.type ?: "", node.name ?: ""))
                    node.name = ""
                node.type = verifiedType(node.type ?: "")

                var child: ParseNode = node
                if (node.parent != null) node = node.parent!!
                else throw Error.UnexpectedChar(param, i, c)
                child.parent = null
                node.state?.allowParams = false
                node.state?.allowName = true
                node.state?.allowArray = true
            }
            "," -> {
                node.state = null
                if (node.name == "indexed") {
                    if (!allowIndexed)
                        throw Error.UnexpectedChar(param, i, c)
                    node.indexed = true
                    node.name = ""
                }
                if (checkModifier(node.type ?: "", node.name ?: ""))
                    node.name = ""
                node.type = verifiedType(node.type ?: "")
                val sibling: ParseNode = newNode(node.parent)
                //{ type: "", name: "", parent: node.parent, state: { allowType: true } };
                val comps = (node.parent?.components ?: emptyList()) +
                        listOf(sibling)
                node.parent?.components = comps
                node.parent = null
                node = sibling
            }
            " " -> {
                // If reading type, type is done and may read a param or name
                if (node.state?.allowType == true && node.type != "") {
                    node.type = verifiedType(node.type ?: "")
                    node.state?.allowType = false
                    node.state?.allowName = true
                    node.state?.allowParams = true
                }
                // If reading name, the name is done
                if (node.state?.allowName == true && node.name != "") {
                    if (node.name == "indexed") {
                        if (!allowIndexed)
                            throw Error.UnexpectedChar(param, i, c)
                        if (node?.indexed == true)
                            throw Error.UnexpectedChar(param, i, c)
                        node.indexed = true
                        node.name = ""
                    } else if (checkModifier(node.type ?: "", node.name ?: "")) {
                        node.name = ""
                    } else {
                        node.state?.allowName = false
                    }
                }
            }
            "[" -> {
                if (node.state?.allowArray != true)
                    throw Error.UnexpectedChar(param, i, c)
                node.type += c
                node.state?.allowArray = false
                node.state?.allowName = false
                node.state?.readArray = true
            }
            "]" -> {
                if (node.state?.allowArray != true)
                    throw Error.UnexpectedChar(param, i, c)
                node.type += c
                node.state?.readArray = false
                node.state?.allowName = true
                node.state?.allowArray = true
            }
            else -> {
                if (node.state?.allowType == true) {
                    node.type += c
                    node.state?.allowParams = true
                    node.state?.allowArray = true
                } else if (node.state?.allowName == true) {
                    node.type += c
                    node.state?.allowArray = false
                } else if (node.state?.readArray == true) {
                    node.type += c
                } else {
                    throw Error.UnexpectedChar(param, i, c)
                }
            }
        }
    }

    if (node.parent != null) throw Error("unexpected eof $param")

    parent.state = null

    if (node.name == "indexed") {
        if (!allowIndexed || node.indexed == true)
            throw Error.UnexpectedChar(param, originalParam.length - 7, "")
        node.indexed = true
        node.name = ""
    } else if (checkModifier(node.type ?: "", node.name ?: "")) {
        node.name = ""
    }

    parent.type = verifiedType(parent.type ?: "")
    return parent
}