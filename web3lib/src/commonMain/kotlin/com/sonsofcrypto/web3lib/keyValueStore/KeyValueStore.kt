package com.sonsofcrypto.web3lib.keyValueStore

expect class KeyValueStore(name: String) {

    inline operator fun <reified T : Any> get(key: String): T?
    inline operator fun <reified T : Any> set(key: String, value: T?)

    fun allKeys(): Set<String>

    companion object {
        fun default(): KeyValueStore
    }
}
