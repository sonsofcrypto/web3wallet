package com.sonsofcrypto.web3lib.contract

import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

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
}

