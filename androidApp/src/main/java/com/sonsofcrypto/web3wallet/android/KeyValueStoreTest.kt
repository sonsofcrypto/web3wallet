package com.sonsofcrypto.web3wallet.android

import androidx.annotation.Keep
import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import kotlinx.serialization.*
import java.lang.Exception


@Keep @Serializable @OptIn(InternalSerializationApi::class)
class TestSerializable {
    @Keep @Serializable
    val foo: String

    constructor(foo: String) {
        this.foo = foo
    }
}

@OptIn(InternalSerializationApi::class)
class KeyValueStoreTest {

    fun runAll() {
        testKeyValueStore()
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun testKeyValueStore() {
        KeyValueStore.default()
        val store = KeyValueStore.default()

        store.set("int", 42)
        assertTrue(
            KeyValueStore.default().get<Int>("int") == 42,
            "Unexpected value in int test",
        )

        store.set("serKey", TestSerializable("foo"))
        assertTrue(
            store.get<TestSerializable>("serKey")?.foo == "foo",
            "Unexpected value in int test",
        )
    }
}

