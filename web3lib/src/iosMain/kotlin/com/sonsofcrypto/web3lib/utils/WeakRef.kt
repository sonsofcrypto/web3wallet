package com.sonsofcrypto.web3lib.utils

import kotlin.experimental.ExperimentalNativeApi
import kotlin.native.ref.WeakReference

@OptIn(ExperimentalNativeApi::class)
actual class WeakRef<T : Any> {
    private val ref: WeakReference<T>

    actual constructor(referred: T) {
        ref = WeakReference(referred)
    }

    actual fun clear() = ref.clear()
    actual fun get(): T? = ref.get()
    actual val value: T?
        get() = ref.value
}
