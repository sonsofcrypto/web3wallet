package com.sonsofcrypto.web3lib.contract

import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

private val json = Json {
    encodeDefaults = true
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
//    private val fragments: ReadonlyArray<Fragment>;
//    private val errors: { [ name: string ]: ErrorFragment };
//    private val events: { [ name: string ]: EventFragment };
//    private val functions: { [ name: string ]: FunctionFragment };
//    private val structs: { [ name: string ]: any };
//    private val deploy: ConstructorFragment;
//    private val _abiCoder: AbiCoder;

    @Throws(Throwable::class)
    constructor(jsonString: String) {
        val jsonFrags = json.decodeFromString<List<JsonFragment>>(jsonString)

    }

    @Serializable
    data class JsonFragmentType(
        val name: String?,
        val indexed: Boolean,
        val type: String?,
        val internalType: String?,
        val components: List<JsonFragmentType>?,
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
    )

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
    }

    class ErrorFragment(
        type: String,
        name: String,
        inputs: List<Param>,
    ) : Fragment(type, name, inputs)

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
        val arrayLength: Int,
        var arrayChildren: Param,
    )

    // const paramTypeArray = new RegExp(/^(.*)\[([0-9]*)\]$/);
}
