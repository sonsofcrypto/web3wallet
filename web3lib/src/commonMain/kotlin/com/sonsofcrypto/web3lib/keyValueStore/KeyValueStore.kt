package com.sonsofcrypto.web3lib.keyValueStore

import com.sonsofcrypto.web3lib.types.Currency
import kotlin.reflect.KClass

expect class KeyValueStore(name: String) {

    inline operator fun <reified T : Any> get(key: String): T?
    inline operator fun <reified T : Any> set(key: String, value: T?)

    fun allKeys(): Set<String>

    companion object {
        fun default(): KeyValueStore
    }
}
