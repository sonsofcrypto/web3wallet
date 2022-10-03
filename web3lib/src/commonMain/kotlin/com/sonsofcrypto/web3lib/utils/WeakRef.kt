package com.sonsofcrypto.web3lib.utils

expect class WeakRef<T : Any> {
    constructor(referred: T)
    fun clear()
    fun get(): T?
    val value: T?
}