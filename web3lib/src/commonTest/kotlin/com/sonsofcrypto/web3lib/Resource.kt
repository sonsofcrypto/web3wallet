package com.sonsofcrypto.web3lib

expect class Resource(name: String) {
    val name: String

    fun exists(): Boolean
    fun readText(): String
}