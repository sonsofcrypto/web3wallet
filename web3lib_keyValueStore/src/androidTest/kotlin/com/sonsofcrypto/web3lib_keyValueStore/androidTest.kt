package com.sonsofcrypto.keyvaluestore

import kotlinx.serialization.InternalSerializationApi
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import org.junit.Assert.assertTrue
import org.junit.Test

@Serializable @OptIn(InternalSerializationApi::class)
class TestSerializable {
    @Serializable
    val foo: String

    constructor(foo: String) {
        this.foo = foo
    }
}

@OptIn(InternalSerializationApi::class)
class AndroidKeyValueStoreTest {

    @Test
    fun testExample() {
        val store = KeyValueStore.default()

        println("=== test")

        store.set("serializable", TestSerializable("foo"))
        val deserialized: TestSerializable? = store.get("serializable")

        println("=== des $deserialized")

        assertTrue(
            "Failed to get serializable",
            deserialized?.foo == "foo"
        )
    }
}