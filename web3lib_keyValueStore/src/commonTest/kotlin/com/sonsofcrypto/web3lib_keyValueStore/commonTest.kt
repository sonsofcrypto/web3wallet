package com.sonsofcrypto.keyvaluestore

import kotlinx.serialization.InternalSerializationApi
import kotlinx.serialization.Serializable
import kotlin.test.Test
import kotlin.test.assertTrue

@Serializable @OptIn(InternalSerializationApi::class)
class TestSerializable2 {
    @Serializable
    val foo: String

    constructor(foo: String) {
        this.foo = foo
    }
}

@OptIn(InternalSerializationApi::class)
class CommonKeyValueTest {

    @Test
    fun testExample() {
        val store = KeyValueStore.default()

        println("=== test")

        store.set("serializable", TestSerializable2("foo"))
        val deserialized: TestSerializable2? = store.get("serializable")

        println("=== des $deserialized")

        assertTrue(
            deserialized?.foo == "foo",
            "Failed to get serializable"
        )
    }
}